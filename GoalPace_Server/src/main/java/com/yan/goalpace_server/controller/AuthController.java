package com.yan.goalpace_server.controller;

import com.yan.goalpace_server.common.Result;
import com.yan.goalpace_server.dto.ChangePasswordDTO;
import com.yan.goalpace_server.dto.LoginDTO;
import com.yan.goalpace_server.dto.RegisterDTO;
import com.yan.goalpace_server.service.AuthService;
import com.yan.goalpace_server.util.UserContext;
import com.yan.goalpace_server.vo.LoginVO;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

/**
 * 认证接口: 登录凭据提交服务端校验, 返回会话态; 注册成功不自动登录
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * 登录, 服务端校验通过并下发会话态
     */
    @PostMapping("/login")
    public Result<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        return Result.success(authService.login(dto));
    }

    /**
     * 注册(成功后返回登录页登录, 不自动登录)
     */
    @PostMapping("/register")
    public Result<Void> register(@Valid @RequestBody RegisterDTO dto) {
        authService.register(dto);
        return Result.success();
    }

    /**
     * 修改密码(成功后服务端会话失效, 客户端需清登录态并重新登录)
     */
    @PutMapping("/password")
    public Result<Void> changePassword(@Valid @RequestBody ChangePasswordDTO dto) {
        authService.changePassword(UserContext.getUserId(), dto);
        return Result.success();
    }
}
