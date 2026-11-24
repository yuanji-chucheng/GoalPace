package com.yan.goalpace_server.controller;

import com.yan.goalpace_server.common.Result;
import com.yan.goalpace_server.service.StatsService;
import com.yan.goalpace_server.util.UserContext;
import com.yan.goalpace_server.vo.StatsVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 统计接口: 本周 / 本月
 */
@RestController
@RequestMapping("/api/stats")
public class StatsController {

    private final StatsService statsService;

    public StatsController(StatsService statsService) {
        this.statsService = statsService;
    }

    @GetMapping
    public Result<StatsVO> stats(@RequestParam(name = "period", required = false,
            defaultValue = "week") String period) {
        return Result.success(statsService.stats(UserContext.getUserId(), period));
    }
}
