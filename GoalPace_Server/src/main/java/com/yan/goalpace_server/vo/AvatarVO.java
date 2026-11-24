package com.yan.goalpace_server.vo;

/**
 * 头像上传结果
 */
public class AvatarVO {

    private String url;

    public AvatarVO() {
    }

    public AvatarVO(String url) {
        this.url = url;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}
