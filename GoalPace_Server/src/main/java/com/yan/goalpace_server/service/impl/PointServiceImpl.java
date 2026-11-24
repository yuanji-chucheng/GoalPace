package com.yan.goalpace_server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.yan.goalpace_server.common.Dates;
import com.yan.goalpace_server.entity.PointLog;
import com.yan.goalpace_server.mapper.PointLogMapper;
import com.yan.goalpace_server.service.PointService;
import com.yan.goalpace_server.vo.PointLogVO;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 积分服务实现: 规则表 + 流水展示(不做积分消费兑换)
 */
@Service
public class PointServiceImpl implements PointService {

    private final PointLogMapper pointLogMapper;

    public PointServiceImpl(PointLogMapper pointLogMapper) {
        this.pointLogMapper = pointLogMapper;
    }

    @Override
    public List<Map<String, Object>> rules() {
        List<Map<String, Object>> rules = new ArrayList<>();
        rules.add(rule("完成任务", Rules.POINTS_TASK, "勾选完成一个普通或中优先级任务"));
        rules.add(rule("完成高优任务", Rules.POINTS_TASK_HIGH, "勾选完成一个高优先级任务"));
        rules.add(rule("连续打卡7天", Rules.POINTS_STREAK_7, "连续打卡按自然日, 每满7天发放"));
        rules.add(rule("达成目标", Rules.POINTS_GOAL_DONE, "目标下任务全部完成, 每个目标仅一次"));
        return rules;
    }

    @Override
    public List<PointLogVO> logs(Long userId) {
        List<PointLog> logs = pointLogMapper.selectList(
                new QueryWrapper<PointLog>().eq("user_id", userId)
                        .orderByDesc("create_time").orderByDesc("id")
                        .last("limit 500"));
        List<PointLogVO> result = new ArrayList<>();
        for (PointLog logEntry : logs) {
            PointLogVO vo = new PointLogVO();
            vo.setId(logEntry.getId());
            vo.setChange(logEntry.getChange());
            vo.setReason(logEntry.getReason());
            vo.setTaskId(logEntry.getTaskId());
            vo.setCreateTime(Dates.formatTime(logEntry.getCreateTime()));
            result.add(vo);
        }
        return result;
    }

    private Map<String, Object> rule(String name, int points, String desc) {
        Map<String, Object> map = new LinkedHashMap<>();
        map.put("name", name);
        map.put("points", points);
        map.put("desc", desc);
        return map;
    }
}
