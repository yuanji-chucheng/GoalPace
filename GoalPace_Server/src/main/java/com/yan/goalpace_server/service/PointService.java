package com.yan.goalpace_server.service;

import com.yan.goalpace_server.vo.PointLogVO;

import java.util.List;
import java.util.Map;

/**
 * 积分服务: 规则表 + 流水展示
 */
public interface PointService {

    List<Map<String, Object>> rules();

    List<PointLogVO> logs(Long userId);
}
