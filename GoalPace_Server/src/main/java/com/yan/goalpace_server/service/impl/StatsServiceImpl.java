package com.yan.goalpace_server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.yan.goalpace_server.common.BusinessException;
import com.yan.goalpace_server.common.Dates;
import com.yan.goalpace_server.entity.Goal;
import com.yan.goalpace_server.entity.Task;
import com.yan.goalpace_server.entity.User;
import com.yan.goalpace_server.mapper.GoalMapper;
import com.yan.goalpace_server.mapper.TaskMapper;
import com.yan.goalpace_server.mapper.UserMapper;
import com.yan.goalpace_server.service.StatsService;
import com.yan.goalpace_server.vo.DailyCountVO;
import com.yan.goalpace_server.vo.GoalProgressVO;
import com.yan.goalpace_server.vo.StatsVO;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 统计服务实现: 本周(周一起) / 本月(1 日起), 口径与 tasks / point_logs 一致
 */
@Service
public class StatsServiceImpl implements StatsService {

    private final TaskMapper taskMapper;

    private final GoalMapper goalMapper;

    private final UserMapper userMapper;

    public StatsServiceImpl(TaskMapper taskMapper, GoalMapper goalMapper, UserMapper userMapper) {
        this.taskMapper = taskMapper;
        this.goalMapper = goalMapper;
        this.userMapper = userMapper;
    }

    @Override
    public StatsVO stats(Long userId, String period) {
        LocalDate today = LocalDate.now();
        LocalDate start;
        LocalDate end;
        if ("month".equals(period)) {
            start = today.withDayOfMonth(1);
            end = today.withDayOfMonth(today.lengthOfMonth());
        } else if ("week".equals(period)) {
            start = today.with(DayOfWeek.MONDAY);
            end = today.with(DayOfWeek.SUNDAY);
        } else {
            throw new BusinessException(400, "period 仅支持 week / month");
        }
        StatsVO vo = new StatsVO();
        vo.setPeriod(period);
        vo.setStartDate(Dates.format(start));
        vo.setEndDate(Dates.format(end));

        List<DailyCountVO> dailyCounts = new ArrayList<>();
        int taskDone = 0;
        LocalDate cursor = start;
        while (!cursor.isAfter(end)) {
            long count = 0;
            if (!cursor.isAfter(today)) {
                count = taskMapper.countCompletedBetween(userId,
                        cursor.atStartOfDay(), cursor.plusDays(1).atStartOfDay());
            }
            dailyCounts.add(new DailyCountVO(Dates.format(cursor), (int) count));
            taskDone += (int) count;
            cursor = cursor.plusDays(1);
        }
        vo.setTaskDone(taskDone);
        vo.setDailyCounts(dailyCounts);

        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(401, "用户不存在");
        }
        vo.setCheckinDays(user.getCheckinDays() == null ? 0 : user.getCheckinDays());
        vo.setPointsGained(0);

        List<Goal> goals = goalMapper.selectList(new QueryWrapper<Goal>()
                .eq("user_id", userId).eq("archived", 0)
                .orderByDesc("progress").orderByDesc("update_time"));
        List<GoalProgressVO> progressList = new ArrayList<>();
        for (Goal goal : goals) {
            Long total = taskCount(goal.getId(), null);
            Long done = taskCount(goal.getId(), 1);
            progressList.add(new GoalProgressVO(goal.getId(), goal.getTitle(),
                    goal.getProgress() == null ? 0 : goal.getProgress(),
                    done == null ? 0 : done.intValue(),
                    total == null ? 0 : total.intValue()));
        }
        vo.setGoalProgress(progressList);
        return vo;
    }

    private long taskCount(Long goalId, Integer status) {
        QueryWrapper<Task> wrapper = new QueryWrapper<Task>().eq("goal_id", goalId);
        if (status != null) {
            wrapper.eq("status", status);
        }
        Long count = taskMapper.selectCount(wrapper);
        return count == null ? 0 : count;
    }
}
