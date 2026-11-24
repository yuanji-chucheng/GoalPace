package com.yan.goalpace_server.service.impl;

import com.yan.goalpace_server.common.BusinessException;
import com.yan.goalpace_server.dto.UpdateProfileDTO;
import com.yan.goalpace_server.dto.UploadAvatarDTO;
import com.yan.goalpace_server.entity.User;
import com.yan.goalpace_server.mapper.UserMapper;
import com.yan.goalpace_server.service.UserService;
import com.yan.goalpace_server.vo.AvatarVO;
import com.yan.goalpace_server.vo.UserVO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Locale;
import java.util.UUID;

/**
 * 用户服务实现
 */
@Service
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;

    private final String uploadDir;

    public UserServiceImpl(UserMapper userMapper, @Value("${goalpace.upload-dir}") String uploadDir) {
        this.userMapper = userMapper;
        this.uploadDir = uploadDir;
    }

    @Override
    public UserVO getProfile(Long userId) {
        return toVO(requireUser(userId));
    }

    @Override
    public UserVO updateProfile(Long userId, UpdateProfileDTO dto) {
        User user = requireUser(userId);
        userMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<User>()
                .eq("id", userId)
                .set("nickname", dto.getNickname())
                .set("avatar", dto.getAvatar() == null ? user.getAvatar() : dto.getAvatar())
                .set("update_time", LocalDateTime.now()));
        return getProfile(userId);
    }

    @Override
    public AvatarVO uploadAvatar(Long userId, UploadAvatarDTO dto) {
        requireUser(userId);
        try {
            String ext = ".png";
            if (dto.getFilename() != null && dto.getFilename().contains(".")) {
                String candidate = dto.getFilename()
                        .substring(dto.getFilename().lastIndexOf('.')).toLowerCase(Locale.ROOT);
                if (candidate.length() > 1 && candidate.length() <= 6) {
                    ext = candidate;
                }
            }
            String filename = "avatar_" + userId + "_" + UUID.randomUUID().toString().replace("-", "") + ext;
            Path dir = Paths.get(uploadDir, "avatars");
            Files.createDirectories(dir);
            Files.write(dir.resolve(filename), Base64.getDecoder().decode(dto.getImageBase64()));
            String url = "/api/files/avatars/" + filename;
            userMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<User>()
                    .eq("id", userId)
                    .set("avatar", url)
                    .set("update_time", LocalDateTime.now()));
            return new AvatarVO(url);
        } catch (IOException | IllegalArgumentException e) {
            throw new BusinessException(400, "头像上传失败: " + e.getMessage());
        }
    }

    private User requireUser(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException(401, "用户不存在");
        }
        return user;
    }

    private UserVO toVO(User user) {
        UserVO vo = new UserVO();
        vo.setId(user.getId());
        vo.setUsername(user.getUsername());
        vo.setNickname(user.getNickname());
        vo.setAvatar(user.getAvatar());
        vo.setPoints(user.getPoints() == null ? 0 : user.getPoints());
        vo.setLevel(user.getLevel() == null ? 1 : user.getLevel());
        vo.setCheckinDays(user.getCheckinDays() == null ? 0 : user.getCheckinDays());
        return vo;
    }
}
