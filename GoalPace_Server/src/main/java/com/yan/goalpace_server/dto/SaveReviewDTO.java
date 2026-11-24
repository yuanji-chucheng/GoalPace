package com.yan.goalpace_server.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * 新建复盘笔记请求
 */
public class SaveReviewDTO {

    @NotNull(message = "缺少关联目标")
    private Long goalId;

    @NotBlank(message = "请输入复盘内容")
    @Size(max = 2000, message = "复盘内容不能超过2000字")
    private String content;

    public Long getGoalId() {
        return goalId;
    }

    public void setGoalId(Long goalId) {
        this.goalId = goalId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
