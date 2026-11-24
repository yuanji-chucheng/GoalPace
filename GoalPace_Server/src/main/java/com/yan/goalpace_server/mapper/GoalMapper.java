package com.yan.goalpace_server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yan.goalpace_server.entity.Goal;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface GoalMapper extends BaseMapper<Goal> {
}
