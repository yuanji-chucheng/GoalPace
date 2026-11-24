package com.yan.goalpace_server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.yan.goalpace_server.common.BusinessException;
import com.yan.goalpace_server.common.Dates;
import com.yan.goalpace_server.dto.SaveGoalDTO;
import com.yan.goalpace_server.entity.Goal;
import com.yan.goalpace_server.entity.ReviewNote;
import com.yan.goalpace_server.entity.Task;
import com.yan.goalpace_server.mapper.GoalMapper;
import com.yan.goalpace_server.mapper.ReviewNoteMapper;
import com.yan.goalpace_server.mapper.TaskMapper;
import com.yan.goalpace_server.service.GoalService;
import com.yan.goalpace_server.vo.GoalVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 目标服务实现
 */
@Service
public class GoalServiceImpl implements GoalService {

    private final GoalMapper goalMapper;

    private final TaskMapper taskMapper;

    private final ReviewNoteMapper reviewNoteMapper;

    private final ProgressService progressService;

    public GoalServiceImpl(GoalMapper goalMapper, TaskMapper taskMapper,
                           ReviewNoteMapper reviewNoteMapper, ProgressService progressService) {
        this.goalMapper = goalMapper;
        this.taskMapper = taskMapper;
        this.reviewNoteMapper = reviewNoteMapper;
        this.progressService = progressService;
    }

    @Override
    public List<GoalVO> list(Long userId, boolean archived) {
        List<Goal> goals = goalMapper.selectList(
                new QueryWrapper<Goal>().eq("user_id", userId)
                        .eq("archived", archived ? 1 : 0)
                        .orderByDesc("update_time"));
        List<GoalVO> result = new ArrayList<>();
        for (Goal goal : goals) {
            result.add(toVO(goal, false));
        }
        return result;
    }

    @Override
    public GoalVO get(Long userId, Long id) {
        return toVO(requireOwned(userId, id), true);
    }

    @Override
    public GoalVO create(Long userId, SaveGoalDTO dto) {
        Goal goal = new Goal();
        applyDto(goal, dto);
        goal.setUserId(userId);
        goal.setArchived(dto.getArchived() != null && dto.getArchived() == 1 ? 1 : 0);
        goal.setProgress(0);
        goal.setUpdateTime(LocalDateTime.now());
        goalMapper.insert(goal);
        return toVO(goal, true);
    }

    @Override
    public GoalVO update(Long userId, Long id, SaveGoalDTO dto) {
        Goal goal = requireOwned(userId, id);
        applyDto(goal, dto);
        if (dto.getArchived() != null) {
            goal.setArchived(dto.getArchived() == 1 ? 1 : 0);
        }
        goal.setUpdateTime(LocalDateTime.now());
        goalMapper.updateById(goal);
        progressService.recalc(id);
        return toVO(goalMapper.selectById(id), true);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long userId, Long id) {
        requireOwned(userId, id);
        taskMapper.delete(new QueryWrapper<Task>().eq("goal_id", id));
        reviewNoteMapper.delete(new QueryWrapper<ReviewNote>().eq("goal_id", id));
        goalMapper.deleteById(id);
    }

    @Override
    public GoalVO setArchived(Long userId, Long id, boolean archived) {
        requireOwned(userId, id);
        goalMapper.update(null, new UpdateWrapper<Goal>()
                .eq("id", id)
                .set("archived", archived ? 1 : 0)
                .set("update_time", LocalDateTime.now()));
        return toVO(goalMapper.selectById(id), true);
    }

    private void applyDto(Goal goal, SaveGoalDTO dto) {
        goal.setTitle(dto.getTitle());
        goal.setType(dto.getType());
        goal.setCategory(dto.getCategory());
        goal.setPriority(dto.getPriority());
        LocalDate start = Dates.parseDate(dto.getStartDate());
        if (start == null) {
            throw new BusinessException(400, "开始日期格式应为 yyyy-MM-dd");
        }
        goal.setStartDate(start);
        goal.setEndDate(Dates.parseDate(dto.getEndDate()));
        goal.setDescription(dto.getDescription());
        goal.setRemindOn(dto.getRemindOn() != null && dto.getRemindOn() == 1 ? 1 : 0);
        goal.setRemindTime(dto.getRemindTime() == null || dto.getRemindTime().isEmpty()
                ? "19:00" : dto.getRemindTime());
    }

    private Goal requireOwned(Long userId, Long id) {
        Goal goal = goalMapper.selectById(id);
        if (goal == null || !goal.getUserId().equals(userId)) {
            throw new BusinessException(404, "目标不存在");
        }
        return goal;
    }

    private GoalVO toVO(Goal goal, boolean withCounts) {
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
        if (withCounts && goal.getId() != null) {
            Long total = taskMapper.selectCount(new QueryWrapper<Task>().eq("goal_id", goal.getId()));
            Long done = taskMapper.selectCount(
                    new QueryWrapper<Task>().eq("goal_id", goal.getId()).eq("status", 1));
            vo.setTaskTotal(total == null ? 0 : total.intValue());
            vo.setTaskDone(done == null ? 0 : done.intValue());
        }
        return vo;
    }
}
