package com.yan.goalpace_server.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.yan.goalpace_server.common.BusinessException;
import com.yan.goalpace_server.dto.ChangePasswordDTO;
import com.yan.goalpace_server.dto.LoginDTO;
import com.yan.goalpace_server.dto.RegisterDTO;
import com.yan.goalpace_server.entity.User;
import com.yan.goalpace_server.mapper.UserMapper;
import com.yan.goalpace_server.service.AuthService;
import com.yan.goalpace_server.util.JwtUtil;
import com.yan.goalpace_server.vo.LoginVO;
import com.yan.goalpace_server.vo.UserVO;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.regex.Pattern;

/**
 * 认证服务实现: 登录凭据由服务端校验并下发会话态; 注册成功不自动登录
 */
@Service
public class AuthServiceImpl implements AuthService {

    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{8,20}$");

    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z0-9_\\u4e00-\\u9fa5]{3,20}$");

    private final UserMapper userMapper;

    private final JwtUtil jwtUtil;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public AuthServiceImpl(UserMapper userMapper, JwtUtil jwtUtil) {
        this.userMapper = userMapper;
        this.jwtUtil = jwtUtil;
    }

    @Override
    public LoginVO login(LoginDTO dto) {
        User user = userMapper.selectOne(
                new QueryWrapper<User>().eq("username", dto.getUsername()));
        if (user == null) {
            throw new BusinessException(404, "该账号未注册");
        }
        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new BusinessException(400, "密码错误");
        }
        return new LoginVO(jwtUtil.generateToken(user.getId()), toVO(user));
    }

    @Override
    public void register(RegisterDTO dto) {
        if (!USERNAME_PATTERN.matcher(dto.getUsername()).matches()) {
            throw new BusinessException(400, "用户名需为3-20位字母、数字、下划线或中文");
        }
        if (!PASSWORD_PATTERN.matcher(dto.getPassword()).matches()) {
            throw new BusinessException(400, "密码需8-20位且同时包含字母和数字");
        }
        Long count = userMapper.selectCount(
                new QueryWrapper<User>().eq("username", dto.getUsername()));
        if (count != null && count > 0) {
            throw new BusinessException(400, "用户名已被占用");
        }
        User user = new User();
        user.setUsername(dto.getUsername());
        user.setNickname(dto.getNickname() == null || dto.getNickname().isEmpty()
                ? dto.getUsername() : dto.getNickname());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setPoints(0);
        user.setLevel(1);
        user.setCheckinDays(0);
        LocalDateTime now = LocalDateTime.now();
        user.setCreateTime(now);
        user.setUpdateTime(now);
        userMapper.insert(user);
    }

    @Override
    public void changePassword(Long userId, ChangePasswordDTO dto) {
        User user = requireUser(userId);
        if (!passwordEncoder.matches(dto.getOldPassword(), user.getPassword())) {
            throw new BusinessException(400, "原密码错误");
        }
        if (!PASSWORD_PATTERN.matcher(dto.getNewPassword()).matches()) {
            throw new BusinessException(400, "新密码需8-20位且同时包含字母和数字");
        }
        userMapper.update(null, new com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper<User>()
                .eq("id", userId)
                .set("password", passwordEncoder.encode(dto.getNewPassword()))
                .set("update_time", LocalDateTime.now()));
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
