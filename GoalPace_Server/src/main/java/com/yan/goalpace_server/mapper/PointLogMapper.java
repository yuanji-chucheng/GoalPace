package com.yan.goalpace_server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yan.goalpace_server.entity.PointLog;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;

@Mapper
public interface PointLogMapper extends BaseMapper<PointLog> {

    /**
     * 目标是否已发放过「达成目标奖励」(防止反复勾选重复 +200)
     */
    @Select("SELECT COUNT(*) FROM point_logs pl JOIN tasks t ON pl.task_id = t.id "
            + "WHERE pl.reason = '达成目标奖励' AND t.goal_id = #{goalId}")
    long countGoalBonus(@Param("goalId") Long goalId);

    /**
     * 用户在 start 之后新增的正向积分合计
     */
    @Select("SELECT COALESCE(SUM(`change`), 0) FROM point_logs "
            + "WHERE user_id = #{userId} AND `change` > 0 AND create_time >= #{start}")
    long sumPositiveSince(@Param("userId") Long userId, @Param("start") LocalDateTime start);
}
