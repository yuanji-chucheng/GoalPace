package com.yan.goalpace_server.service;

import com.yan.goalpace_server.dto.ChangePasswordDTO;
import com.yan.goalpace_server.dto.LoginDTO;
import com.yan.goalpace_server.dto.RegisterDTO;
import com.yan.goalpace_server.vo.LoginVO;

/**
 * 认证服务: 登录 / 注册(不自动登录) / 修改密码
 */
public interface AuthService {

    LoginVO login(LoginDTO dto);

    void register(RegisterDTO dto);

    void changePassword(Long userId, ChangePasswordDTO dto);
}
