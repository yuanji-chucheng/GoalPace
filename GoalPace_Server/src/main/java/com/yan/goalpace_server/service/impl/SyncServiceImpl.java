package com.yan.goalpace_server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.yan.goalpace_server.common.Dates;
import com.yan.goalpace_server.entity.Goal;
import com.yan.goalpace_server.entity.PointLog;
import com.yan.goalpace_server.entity.ReviewNote;
import com.yan.goalpace_server.entity.Task;
import com.yan.goalpace_server.entity.User;
import com.yan.goalpace_server.mapper.GoalMapper;
import com.yan.goalpace_server.mapper.PointLogMapper;
import com.yan.goalpace_server.mapper.ReviewNoteMapper;
import com.yan.goalpace_server.mapper.TaskMapper;
import com.yan.goalpace_server.mapper.UserMapper;
import com.yan.goalpace_server.service.SyncService;
import com.yan.goalpace_server.vo.GoalVO;
import com.yan.goalpace_server.vo.PointLogVO;
import com.yan.goalpace_server.vo.ReviewVO;
import com.yan.goalpace_server.vo.SyncVO;
import com.yan.goalpace_server.vo.TaskVO;
import com.yan.goalpace_server.vo.UserVO;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 增量同步与备份导出实现: 服务端 MySQL 为唯一数据源, 客户端据此回刷缓存
 */
@Service
public class SyncServiceImpl implements SyncService {

    private final GoalMapper goalMapper;

    private final TaskMapper taskMapper;

    private final PointLogMapper pointLogMapper;

    private final ReviewNoteMapper reviewNoteMapper;

    private final UserMapper userMapper;

    public SyncServiceImpl(GoalMapper goalMapper, TaskMapper taskMapper,
                           PointLogMapper pointLogMapper, ReviewNoteMapper reviewNoteMapper,
                           UserMapper userMapper) {
        this.goalMapper = goalMapper;
        this.taskMapper = taskMapper;
        this.pointLogMapper = pointLogMapper;
        this.reviewNoteMapper = reviewNoteMapper;
        this.userMapper = userMapper;
    }

    @Override
    public SyncVO sync(Long userId, Long since) {
        SyncVO vo = new SyncVO();
        vo.setUser(userVO(userId));
        LocalDateTime sinceTime = since == null || since <= 0
                ? LocalDateTime.of(1970, 1, 1, 0, 0)
                : LocalDateTime.ofInstant(
                        java.time.Instant.ofEpochMilli(since),
                        java.time.ZoneId.systemDefault());
        List<Goal> goals = goalMapper.selectList(new QueryWrapper<Goal>()
                .eq("user_id", userId).ge("update_time", sinceTime)
                .orderByAsc("id"));
        List<GoalVO> goalVOs = new ArrayList<>();
        List<Long> goalIds = new ArrayList<>();
        for (Goal goal : goals) {
            goalVOs.add(goalVO(goal));
            goalIds.add(goal.getId());
        }
        vo.setGoals(goalVOs);

        List<Task> tasks;
        List<ReviewNote> reviews;
        if (goalIds.isEmpty()) {
            tasks = new ArrayList<>();
            reviews = new ArrayList<>();
        } else {
            tasks = taskMapper.selectList(new QueryWrapper<Task>()
                    .in("goal_id", goalIds).ge("update_time", sinceTime)
                    .orderByAsc("id"));
            reviews = reviewNoteMapper.selectList(new QueryWrapper<ReviewNote>()
                    .in("goal_id", goalIds).ge("create_time", sinceTime)
                    .orderByAsc("id"));
        }
        List<TaskVO> taskVOs = new ArrayList<>();
        for (Task task : tasks) {
            taskVOs.add(taskVO(task));
        }
        vo.setTasks(taskVOs);

        List<ReviewVO> reviewVOs = new ArrayList<>();
        for (ReviewNote note : reviews) {
            reviewVOs.add(reviewVO(note));
        }
        vo.setReviewNotes(reviewVOs);

        List<PointLog> logs = pointLogMapper.selectList(new QueryWrapper<PointLog>()
                .eq("user_id", userId).ge("create_time", sinceTime)
                .orderByDesc("create_time").orderByDesc("id")
                .last("limit 1000"));
        List<PointLogVO> logVOs = new ArrayList<>();
        for (PointLog logEntry : logs) {
            PointLogVO item = new PointLogVO();
            item.setId(logEntry.getId());
            item.setChange(logEntry.getChange());
            item.setReason(logEntry.getReason());
            item.setTaskId(logEntry.getTaskId());
            item.setCreateTime(Dates.formatTime(logEntry.getCreateTime()));
            logVOs.add(item);
        }
        vo.setPointLogs(logVOs);
        vo.setServerTime(System.currentTimeMillis());
        return vo;
    }

    @Override
    public SyncVO export(Long userId) {
        return sync(userId, 0L);
    }

    private UserVO userVO(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return new UserVO();
        }
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setNickname(user.getNickname());
        vo.setAvatar(user.getAvatar());
        vo.setPoints(user.getPoints() == null ? 0 : user.getPoints());
        vo.setLevel(user.getLevel() == null ? 1 : user.getLevel());
        vo.setCheckinDays(user.getCheckinDays() == null ? 0 : user.getCheckinDays());
        return vo;
    }

    private GoalVO goalVO(Goal goal) {
        GoalVO vo = new GoalVO();
        vo.setId(goal.getId());
        vo.setTitle(goal.getTitle());
        vo.setType(goal.getType());
        vo.setCategory(goal.getCategory());
        vo.setPriority(goal.getPriority());
        vo.setStartDate(Dates.format(goal.getStartDate()));
        vo.setEndDate(Dates.format(goal.getEndDate()));
        vo.setDescription(goal.getDescription());
        vo.setRemindOn(goal.getRemindOn());
        vo.setRemindTime(goal.getRemindTime());
        vo.setArchived(goal.getArchived());
        vo.setProgress(goal.getProgress() == null ? 0 : goal.getProgress());
        vo.setUpdateTime(Dates.formatTime(goal.getUpdateTime()));
        return vo;
    }

    private TaskVO taskVO(Task task) {
        TaskVO vo = new TaskVO();
        vo.setId(task.getId());
        vo.setGoalId(task.getGoalId());
        vo.setTitle(task.getTitle());
        vo.setDueDate(Dates.format(task.getDueDate()));
        vo.setDueTime(task.getDueTime());
        vo.setPriority(task.getPriority());
        vo.setNote(task.getNote());
        vo.setRemindOn(task.getRemindOn());
        vo.setRemindAdvance(task.getRemindAdvance());
        vo.setStatus(task.getStatus());
        vo.setCompleteTime(Dates.formatTime(task.getCompleteTime()));
        vo.setUpdateTime(Dates.formatTime(task.getUpdateTime()));
        return vo;
    }

    private ReviewVO reviewVO(ReviewNote note) {
        ReviewVO vo = new ReviewVO();
        vo.setId(note.getId());
        vo.setGoalId(note.getGoalId());
        vo.setContent(note.getContent());
        vo.setCreateTime(Dates.formatTime(note.getCreateTime()));
        return vo;
    }
}
