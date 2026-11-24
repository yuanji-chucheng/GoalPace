package com.yan.goalpace_server.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 更新个人资料请求(账号只读, 不允许修改)
 */
public class UpdateProfileDTO {

    @NotBlank(message = "请输入昵称")
    @Size(max = 50, message = "昵称不能超过50字")
    private String nickname;

    private String avatar;

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }
}
