package com.yan.goalpace_server.service;

import com.yan.goalpace_server.dto.SaveTaskDTO;
import com.yan.goalpace_server.vo.TaskVO;
import com.yan.goalpace_server.vo.ToggleVO;

import java.util.List;

/**
 * 任务服务: 勾选完成由服务端结算积分并重算目标进度
 */
public interface TaskService {

    List<TaskVO> list(Long userId, Long goalId, Integer status, Integer priority);

    List<TaskVO> today(Long userId);

    TaskVO create(Long userId, SaveTaskDTO dto);

    TaskVO update(Long userId, Long id, SaveTaskDTO dto);

    void delete(Long userId, Long id);

    ToggleVO toggle(Long userId, Long id);
}
