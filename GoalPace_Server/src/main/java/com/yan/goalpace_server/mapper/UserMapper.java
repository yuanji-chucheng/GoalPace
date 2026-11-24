package com.yan.goalpace_server.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yan.goalpace_server.entity.User;
import org.apache.ibatis.annotations.Mapper;

/**
 * 用户 Mapper
 */
@Mapper
public interface UserMapper extends BaseMapper<User> {
}
