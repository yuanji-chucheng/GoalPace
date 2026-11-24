package com.yan.goalpace_server.service;

import com.yan.goalpace_server.dto.UpdateProfileDTO;
import com.yan.goalpace_server.dto.UploadAvatarDTO;
import com.yan.goalpace_server.vo.AvatarVO;
import com.yan.goalpace_server.vo.UserVO;

/**
 * 用户服务
 */
public interface UserService {

    UserVO getProfile(Long userId);

    UserVO updateProfile(Long userId, UpdateProfileDTO dto);

    AvatarVO uploadAvatar(Long userId, UploadAvatarDTO dto);
}
