package com.yan.goalpace_server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yan.goalpace_server.entity.Task;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;

@Mapper
public interface TaskMapper extends BaseMapper<Task> {

    /**
     * 统计用户自 start 以来已完成的任务数(用于当日首次打卡判定)
     */
    @Select("SELECT COUNT(*) FROM tasks t JOIN goals g ON t.goal_id = g.id "
            + "WHERE g.user_id = #{userId} AND t.complete_time >= #{start}")
    long countCompletedSince(@Param("userId") Long userId, @Param("start") LocalDateTime start);

    /**
     * 用户在 start 之前最近一次任务完成时间
     */
    @Select("SELECT MAX(t.complete_time) FROM tasks t JOIN goals g ON t.goal_id = g.id "
            + "WHERE g.user_id = #{userId} AND t.complete_time < #{start}")
    LocalDateTime lastCompleteBefore(@Param("userId") Long userId, @Param("start") LocalDateTime start);

    /**
     * 统计用户在 [start, end) 区间内完成的任务数(统计口径与 tasks 表一致)
     */
    @Select("SELECT COUNT(*) FROM tasks t JOIN goals g ON t.goal_id = g.id "
            + "WHERE g.user_id = #{userId} AND t.complete_time >= #{start} AND t.complete_time < #{end}")
    long countCompletedBetween(@Param("userId") Long userId,
                               @Param("start") LocalDateTime start,
                               @Param("end") LocalDateTime end);
}
