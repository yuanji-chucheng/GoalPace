package com.yan.goalpace_server.controller;

import com.yan.goalpace_server.common.Result;
import com.yan.goalpace_server.dto.SaveReviewDTO;
import com.yan.goalpace_server.service.ReviewService;
import com.yan.goalpace_server.util.UserContext;
import com.yan.goalpace_server.vo.ReviewVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import java.util.List;

/**
 * 复盘笔记接口
 */
@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @GetMapping
    public Result<List<ReviewVO>> list(@RequestParam(name = "goalId", required = false) Long goalId) {
        return Result.success(reviewService.list(UserContext.getUserId(), goalId));
    }

    @PostMapping
    public Result<ReviewVO> create(@Valid @RequestBody SaveReviewDTO dto) {
        return Result.success(reviewService.create(UserContext.getUserId(), dto));
    }
}
