package com.yan.goalpace_server.controller;

import com.yan.goalpace_server.common.Result;
import com.yan.goalpace_server.dto.UpdateProfileDTO;
import com.yan.goalpace_server.dto.UploadAvatarDTO;
import com.yan.goalpace_server.service.UserService;
import com.yan.goalpace_server.util.UserContext;
import com.yan.goalpace_server.vo.AvatarVO;
import com.yan.goalpace_server.vo.UserVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;

/**
 * 用户接口
 */
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/profile")
    public Result<UserVO> getProfile() {
        return Result.success(userService.getProfile(UserContext.getUserId()));
    }

    @PutMapping("/profile")
    public Result<UserVO> updateProfile(@Valid @RequestBody UpdateProfileDTO dto) {
        return Result.success(userService.updateProfile(UserContext.getUserId(), dto));
    }

    /**
     * 头像上传(客户端从本地相册选择后上传)
     */
    @PostMapping("/avatar")
    public Result<AvatarVO> uploadAvatar(@Valid @RequestBody UploadAvatarDTO dto) {
        return Result.success(userService.uploadAvatar(UserContext.getUserId(), dto));
    }
}
