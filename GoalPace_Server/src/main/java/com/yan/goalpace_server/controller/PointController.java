package com.yan.goalpace_server.controller;

import com.yan.goalpace_server.common.Result;
import com.yan.goalpace_server.service.PointService;
import com.yan.goalpace_server.util.UserContext;
import com.yan.goalpace_server.vo.PointLogVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

/**
 * 积分接口: 规则表 + 流水
 */
@RestController
@RequestMapping("/api/points")
public class PointController {

    private final PointService pointService;

    public PointController(PointService pointService) {
        this.pointService = pointService;
    }

    @GetMapping("/rules")
    public Result<List<Map<String, Object>>> rules() {
        return Result.success(pointService.rules());
    }

    @GetMapping("/logs")
    public Result<List<PointLogVO>> logs() {
        return Result.success(pointService.logs(UserContext.getUserId()));
    }
}
