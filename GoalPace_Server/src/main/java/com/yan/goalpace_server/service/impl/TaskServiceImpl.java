package com.yan.goalpace_server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.yan.goalpace_server.common.BusinessException;
import com.yan.goalpace_server.common.Dates;
import com.yan.goalpace_server.dto.SaveTaskDTO;
import com.yan.goalpace_server.entity.Goal;
import com.yan.goalpace_server.entity.PointLog;
import com.yan.goalpace_server.entity.Task;
import com.yan.goalpace_server.entity.User;
import com.yan.goalpace_server.mapper.GoalMapper;
import com.yan.goalpace_server.mapper.PointLogMapper;
import com.yan.goalpace_server.mapper.TaskMapper;
import com.yan.goalpace_server.mapper.UserMapper;
import com.yan.goalpace_server.service.TaskService;
import com.yan.goalpace_server.vo.TaskVO;
import com.yan.goalpace_server.vo.ToggleVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 任务服务实现: 勾选完成由服务端结算积分(+10/+15, 连打7天+50, 达成目标+200)并重算进度,
 * 客户端只展示服务端返回值后回刷缓存
 */
@Service
public class TaskServiceImpl implements TaskService {

    private final TaskMapper taskMapper;

    private final GoalMapper goalMapper;

    private final UserMapper userMapper;

    private final PointLogMapper pointLogMapper;

    private final ProgressService progressService;

    public TaskServiceImpl(TaskMapper taskMapper, GoalMapper goalMapper, UserMapper userMapper,
                           PointLogMapper pointLogMapper, ProgressService progressService) {
        this.taskMapper = taskMapper;
        this.goalMapper = goalMapper;
        this.userMapper = userMapper;
        this.pointLogMapper = pointLogMapper;
        this.progressService = progressService;
    }

    @Override
    public List<TaskVO> list(Long userId, Long goalId, Integer status, Integer priority) {
        List<Goal> goals = goalMapper.selectList(
                new QueryWrapper<Goal>().eq("user_id", userId));
        if (goals.isEmpty()) {
            return new ArrayList<>();
        }
        List<Long> goalIds = new ArrayList<>();
        for (Goal goal : goals) {
            goalIds.add(goal.getId());
        }
        QueryWrapper<Task> wrapper = new QueryWrapper<Task>()
                .in("goal_id", goalIds)
                .orderByAsc("status")
                .orderByAsc("due_date")
                .orderByDesc("priority");
        if (goalId != null) {
            if (!goalIds.contains(goalId)) {
                return new ArrayList<>();
            }
            wrapper.eq("goal_id", goalId);
        }
        if (status != null) {
            wrapper.eq("status", status);
        }
        if (priority != null) {
            wrapper.eq("priority", priority);
        }
        return toVOList(taskMapper.selectList(wrapper), goals);
    }

    @Override
    public List<TaskVO> today(Long userId) {
        LocalDate today = LocalDate.now();
        LocalDateTime todayStart = today.atStartOfDay();
        LocalDateTime todayEnd = today.plusDays(1).atStartOfDay();
        List<Goal> goals = goalMapper.selectList(
                new QueryWrapper<Goal>().eq("user_id", userId));
        if (goals.isEmpty()) {
            return new ArrayList<>();
        }
        List<Long> goalIds = new ArrayList<>();
        for (Goal goal : goals) {
            goalIds.add(goal.getId());
        }
        List<Task> pending = taskMapper.selectList(new QueryWrapper<Task>()
                .in("goal_id", goalIds)
                .eq("status", 0)
                .isNotNull("due_date")
                .le("due_date", today)
                .orderByAsc("due_date").orderByAsc("due_time").orderByDesc("priority"));
        List<Task> doneToday = taskMapper.selectList(new QueryWrapper<Task>()
                .in("goal_id", goalIds)
                .eq("status", 1)
                .ge("complete_time", todayStart)
                .lt("complete_time", todayEnd)
                .orderByDesc("complete_time"));
        List<Task> merged = new ArrayList<>(pending);
        for (Task task : doneToday) {
            merged.add(task);
        }
        return toVOList(merged, goals);
    }

    @Override
    public TaskVO create(Long userId, SaveTaskDTO dto) {
        Goal goal = requireGoal(userId, dto.getGoalId());
        Task task = new Task();
        applyDto(task, dto);
        task.setGoalId(goal.getId());
        task.setStatus(0);
        task.setUpdateTime(LocalDateTime.now());
        taskMapper.insert(task);
        progressService.recalc(goal.getId());
        return toVO(task, goal);
    }

    @Override
    public TaskVO update(Long userId, Long id, SaveTaskDTO dto) {
        Task task = requireTask(userId, id);
        Long oldGoalId = task.getGoalId();
        Goal goal = requireGoal(userId, dto.getGoalId());
        task.setGoalId(goal.getId());
        applyDto(task, dto);
        task.setUpdateTime(LocalDateTime.now());
        taskMapper.updateById(task);
        progressService.recalc(goal.getId());
        if (!oldGoalId.equals(goal.getId())) {
            progressService.recalc(oldGoalId);
        }
        return toVO(taskMapper.selectById(id), goal);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long userId, Long id) {
        Task task = requireTask(userId, id);
        taskMapper.deleteById(id);
        progressService.recalc(task.getGoalId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ToggleVO toggle(Long userId, Long id) {
        Task task = requireTask(userId, id);
        Goal goal = goalMapper.selectById(task.getGoalId());
        if (goal == null) {
            throw new BusinessException(404, "关联目标不存在");
        }
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(401, "用户不存在");
        }
        LocalDateTime now = LocalDateTime.now();
        LocalDate today = now.toLocalDate();
        int pointsDelta = 0;
        if (task.getStatus() == null || task.getStatus() == 0) {
            // 勾选完成: 服务端结算积分
            task.setStatus(1);
            task.setCompleteTime(now);
            pointsDelta = award(user, Rules.taskPoints(task.getPriority()),
                    "完成任务", task.getId(), now);
            // 连续打卡按自然日: 当日首次完成时判定
            long completedToday = taskMapper.countCompletedSince(userId, today.atStartOfDay());
            if (completedToday <= 1) {
                LocalDateTime lastTime = taskMapper.lastCompleteBefore(userId, today.atStartOfDay());
                int days = 1;
                if (lastTime != null && lastTime.toLocalDate().equals(today.minusDays(1))) {
                    days = (user.getCheckinDays() == null ? 0 : user.getCheckinDays()) + 1;
                }
                user.setCheckinDays(days);
                if (days % 7 == 0) {
                    pointsDelta += award(user, Rules.POINTS_STREAK_7, "连续打卡7天", null, now);
                }
            }
            // 保存并重算进度, 达成目标一次性 +200
            task.setUpdateTime(now);
            taskMapper.updateById(task);
            int progress = progressService.recalc(goal.getId());
            if (progress >= 100 && pointLogMapper.countGoalBonus(goal.getId()) == 0) {
                pointsDelta += award(user, Rules.POINTS_GOAL_DONE, "达成目标奖励", null, now);
            }
            persistUser(user);
            return buildToggle(task, goal, user, pointsDelta, progress);
        }
        // 取消完成: 回退对应积分并重算进度
        task.setStatus(0);
        task.setCompleteTime(null);
        task.setUpdateTime(now);
        taskMapper.updateById(task);
        pointsDelta = award(user, -Rules.taskPoints(task.getPriority()),
                "取消完成任务", task.getId(), now);
        int progress = progressService.recalc(goal.getId());
        persistUser(user);
        return buildToggle(task, goal, user, pointsDelta, progress);
    }

    /**
     * 结算积分并写 point_logs 流水, 返回实际变动值(负向结算时积分不小于 0)
     */
    private int award(User user, int change, String reason, Long taskId, LocalDateTime now) {
        int current = user.getPoints() == null ? 0 : user.getPoints();
        int actual = change;
        if (current + change < 0) {
            actual = -current;
        }
        if (actual != 0) {
            user.setPoints(current + actual);
            user.setLevel(Rules.levelOf(current + actual));
            PointLog logEntry = new PointLog();
            logEntry.setUserId(user.getId());
            logEntry.setChange(actual);
            logEntry.setReason(reason);
            logEntry.setTaskId(taskId);
            logEntry.setCreateTime(now);
            pointLogMapper.insert(logEntry);
        }
        return actual;
    }

    private void persistUser(User user) {
        userMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<User>()
                .eq("id", user.getId())
                .set("points", user.getPoints())
                .set("level", user.getLevel())
                .set("checkin_days", user.getCheckinDays())
                .set("update_time", LocalDateTime.now()));
    }

    private ToggleVO buildToggle(Task task, Goal goal, User user, int pointsDelta, int progress) {
        TaskVO taskVO = toVO(taskMapper.selectById(task.getId()), goal);
        return new ToggleVO(taskVO, pointsDelta,
                user.getPoints(), user.getLevel(), user.getCheckinDays(), progress);
    }

    private void applyDto(Task task, SaveTaskDTO dto) {
        if (dto.getTitle() == null || dto.getTitle().trim().isEmpty()) {
            throw new BusinessException(400, "请输入任务标题");
        }
        task.setTitle(dto.getTitle().trim());
        task.setDueDate(Dates.parseDate(dto.getDueDate()));
        task.setDueTime(dto.getDueTime());
        task.setPriority(dto.getPriority());
        task.setNote(dto.getNote());
        task.setRemindOn(dto.getRemindOn() != null && dto.getRemindOn() == 1 ? 1 : 0);
        task.setRemindAdvance(dto.getRemindAdvance() == null ? 30 : dto.getRemindAdvance());
    }

    private Goal requireGoal(Long userId, Long goalId) {
        Goal goal = goalMapper.selectById(goalId);
        if (goal == null || !goal.getUserId().equals(userId)) {
            throw new BusinessException(404, "目标不存在");
        }
        return goal;
    }

    private Task requireTask(Long userId, Long id) {
        Task task = taskMapper.selectById(id);
        if (task == null) {
            throw new BusinessException(404, "任务不存在");
        }
        requireGoal(userId, task.getGoalId());
        return task;
    }

    private List<TaskVO> toVOList(List<Task> tasks, List<Goal> goals) {
        List<TaskVO> result = new ArrayList<>();
        for (Task task : tasks) {
            Goal matched = null;
            for (Goal goal : goals) {
                if (goal.getId().equals(task.getGoalId())) {
                    matched = goal;
                    break;
                }
            }
            result.add(toVO(task, matched));
        }
        return result;
    }

    private TaskVO toVO(Task task, Goal goal) {
        TaskVO vo = new TaskVO();
        vo.setId(task.getId());
        vo.setGoalId(task.getGoalId());
        vo.setGoalTitle(goal == null ? "" : goal.getTitle());
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
}
