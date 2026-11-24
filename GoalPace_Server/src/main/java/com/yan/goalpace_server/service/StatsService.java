package com.yan.goalpace_server.service;

import com.yan.goalpace_server.vo.StatsVO;

/**
 * 统计服务: 本周 / 本月口径与 tasks / point_logs 一致
 */
public interface StatsService {

    StatsVO stats(Long userId, String period);
}
