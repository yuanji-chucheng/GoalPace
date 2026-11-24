package com.yan.goalpace_server.vo;

/**
 * 登录结果(会话态)
 */
public class LoginVO {

    private String token;

    private UserVO user;

    public LoginVO() {
    }

    public LoginVO(String token, UserVO user) {
        this.token = token;
        this.user = user;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public UserVO getUser() {
        return user;
    }

    public void setUser(UserVO user) {
        this.user = user;
    }
}
