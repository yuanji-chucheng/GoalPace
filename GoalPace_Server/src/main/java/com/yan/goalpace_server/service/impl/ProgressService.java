package com.yan.goalpace_server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.yan.goalpace_server.common.BusinessException;
import com.yan.goalpace_server.entity.Goal;
import com.yan.goalpace_server.entity.Task;
import com.yan.goalpace_server.mapper.GoalMapper;
import com.yan.goalpace_server.mapper.TaskMapper;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 目标进度重算: 进度 = 已完成任务数 / 关联任务总数 (由服务端重算并回写 MySQL)
 */
@Service
public class ProgressService {

    private final GoalMapper goalMapper;

    private final TaskMapper taskMapper;

    public ProgressService(GoalMapper goalMapper, TaskMapper taskMapper) {
        this.goalMapper = goalMapper;
        this.taskMapper = taskMapper;
    }

    /**
     * 重算目标进度并回写, 返回新的进度值(0-100)
     */
    public int recalc(Long goalId) {
        Goal goal = goalMapper.selectById(goalId);
        if (goal == null) {
            throw new BusinessException(404, "目标不存在");
        }
        Long total = taskMapper.selectCount(
                new QueryWrapper<Task>().eq("goal_id", goalId));
        Long done = taskMapper.selectCount(
                new QueryWrapper<Task>().eq("goal_id", goalId).eq("status", 1));
        long totalCount = total == null ? 0 : total;
        long doneCount = done == null ? 0 : done;
        int progress = totalCount == 0 ? 0 : (int) (doneCount * 100 / totalCount);
        goalMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<Goal>()
                .eq("id", goalId)
                .set("progress", progress)
                .set("update_time", LocalDateTime.now()));
        return progress;
    }
}
