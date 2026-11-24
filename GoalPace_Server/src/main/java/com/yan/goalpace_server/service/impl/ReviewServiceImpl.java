package com.yan.goalpace_server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.yan.goalpace_server.common.BusinessException;
import com.yan.goalpace_server.common.Dates;
import com.yan.goalpace_server.dto.SaveReviewDTO;
import com.yan.goalpace_server.entity.Goal;
import com.yan.goalpace_server.entity.ReviewNote;
import com.yan.goalpace_server.mapper.GoalMapper;
import com.yan.goalpace_server.mapper.ReviewNoteMapper;
import com.yan.goalpace_server.service.ReviewService;
import com.yan.goalpace_server.vo.ReviewVO;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 复盘笔记服务实现: 内容经 POST /api/reviews 写入服务端 MySQL
 */
@Service
public class ReviewServiceImpl implements ReviewService {

    private final ReviewNoteMapper reviewNoteMapper;

    private final GoalMapper goalMapper;

    public ReviewServiceImpl(ReviewNoteMapper reviewNoteMapper, GoalMapper goalMapper) {
        this.reviewNoteMapper = reviewNoteMapper;
        this.goalMapper = goalMapper;
    }

    @Override
    public List<ReviewVO> list(Long userId, Long goalId) {
        List<Goal> goals = goalMapper.selectList(
                new QueryWrapper<Goal>().eq("user_id", userId));
        if (goals.isEmpty()) {
            return new ArrayList<>();
        }
        QueryWrapper<ReviewNote> wrapper = new QueryWrapper<ReviewNote>()
                .in("goal_id", goalIds(goals))
                .orderByDesc("create_time");
        if (goalId != null) {
            if (!goalIds(goals).contains(goalId)) {
                return new ArrayList<>();
            }
            wrapper.eq("goal_id", goalId);
        }
        List<ReviewNote> notes = reviewNoteMapper.selectList(wrapper);
        List<ReviewVO> result = new ArrayList<>();
        for (ReviewNote note : notes) {
            result.add(toVO(note, goals));
        }
        return result;
    }

    @Override
    public ReviewVO create(Long userId, SaveReviewDTO dto) {
        Goal goal = goalMapper.selectById(dto.getGoalId());
        if (goal == null || !goal.getUserId().equals(userId)) {
            throw new BusinessException(404, "目标不存在");
        }
        ReviewNote note = new ReviewNote();
        note.setGoalId(dto.getGoalId());
        note.setUserId(userId);
        note.setContent(dto.getContent());
        note.setCreateTime(LocalDateTime.now());
        reviewNoteMapper.insert(note);
        return toVO(note, new ArrayList<>(List.of(goal)));
    }

    private List<Long> goalIds(List<Goal> goals) {
        List<Long> ids = new ArrayList<>();
        for (Goal goal : goals) {
            ids.add(goal.getId());
        }
        return ids;
    }

    private ReviewVO toVO(ReviewNote note, List<Goal> goals) {
        ReviewVO vo = new ReviewVO();
        vo.setId(note.getId());
        vo.setGoalId(note.getGoalId());
        String goalTitle = "";
        for (Goal goal : goals) {
            if (goal.getId().equals(note.getGoalId())) {
                goalTitle = goal.getTitle();
                break;
            }
        }
        vo.setGoalTitle(goalTitle);
        vo.setContent(note.getContent());
        vo.setCreateTime(Dates.formatTime(note.getCreateTime()));
        return vo;
    }
}
