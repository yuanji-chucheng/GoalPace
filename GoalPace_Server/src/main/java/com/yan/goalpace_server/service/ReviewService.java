package com.yan.goalpace_server.service;

import com.yan.goalpace_server.dto.SaveReviewDTO;
import com.yan.goalpace_server.vo.ReviewVO;

import java.util.List;

/**
 * 复盘笔记服务
 */
public interface ReviewService {

    List<ReviewVO> list(Long userId, Long goalId);

    ReviewVO create(Long userId, SaveReviewDTO dto);
}
