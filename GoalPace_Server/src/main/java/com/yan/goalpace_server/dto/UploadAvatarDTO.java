package com.yan.goalpace_server.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 头像上传请求(客户端选图后 base64 上传)
 */
public class UploadAvatarDTO {

    @NotBlank(message = "头像数据不能为空")
    private String imageBase64;

    private String filename;

    public String getImageBase64() {
        return imageBase64;
    }

    public void setImageBase64(String imageBase64) {
        this.imageBase64 = imageBase64;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }
}
