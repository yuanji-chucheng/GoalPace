package com.yan.goalpace_server.service;

import com.yan.goalpace_server.dto.SaveGoalDTO;
import com.yan.goalpace_server.vo.GoalVO;

import java.util.List;

/**
 * 目标服务
 */
public interface GoalService {

    List<GoalVO> list(Long userId, boolean archived);

    GoalVO get(Long userId, Long id);

    GoalVO create(Long userId, SaveGoalDTO dto);

    GoalVO update(Long userId, Long id, SaveGoalDTO dto);

    void delete(Long userId, Long id);

    GoalVO setArchived(Long userId, Long id, boolean archived);
}
