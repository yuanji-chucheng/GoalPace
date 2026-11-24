package com.yan.goalpace_server.controller;

import com.yan.goalpace_server.common.Result;
import com.yan.goalpace_server.service.SyncService;
import com.yan.goalpace_server.util.UserContext;
import com.yan.goalpace_server.vo.SyncVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 同步与备份接口
 */
@RestController
@RequestMapping("/api")
public class SyncController {

    private final SyncService syncService;

    public SyncController(SyncService syncService) {
        this.syncService = syncService;
    }

    /**
     * 增量同步: 客户端 Refresh 下拉触发, since 为 epoch 毫秒(空则全量)
     */
    @GetMapping("/sync")
    public Result<SyncVO> sync(@RequestParam(name = "since", required = false,
            defaultValue = "0") Long since) {
        return Result.success(syncService.sync(UserContext.getUserId(), since));
    }

    /**
     * 备份导出: 由服务端生成备份, 客户端保存到用户选择路径
     */
    @GetMapping("/export")
    public Result<SyncVO> export() {
        return Result.success(syncService.export(UserContext.getUserId()));
    }
}
