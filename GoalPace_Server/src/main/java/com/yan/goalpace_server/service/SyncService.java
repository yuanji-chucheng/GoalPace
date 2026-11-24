package com.yan.goalpace_server.service;

import com.yan.goalpace_server.vo.SyncVO;

/**
 * 增量同步与备份导出
 */
public interface SyncService {

    SyncVO sync(Long userId, Long since);

    SyncVO export(Long userId);
}
