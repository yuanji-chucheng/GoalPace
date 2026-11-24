package com.yan.goalpace_server.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * 新建/编辑目标请求
 */
public class SaveGoalDTO {

    @NotBlank(message = "请输入目标标题")
    @Size(max = 100, message = "目标标题不能超过100字")
    private String title;

    @NotBlank(message = "请选择目标类型")
    private String type;

    @NotBlank(message = "请选择目标分类")
    private String category;

    @NotNull(message = "请选择优先级")
    @Min(value = 1, message = "优先级不合法")
    @Max(value = 3, message = "优先级不合法")
    private Integer priority;

    @NotBlank(message = "请选择开始日期")
    private String startDate;

    private String endDate;

    @Size(max = 500, message = "目标描述不能超过500字")
    private String description;

    private Integer remindOn;

    private String remindTime;

    private Integer archived;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Integer getPriority() {
        return priority;
    }

    public void setPriority(Integer priority) {
        this.priority = priority;
    }

    public String getStartDate() {
        return startDate;
    }

    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }

    public String getEndDate() {
        return endDate;
    }

    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getRemindOn() {
        return remindOn;
    }

    public void setRemindOn(Integer remindOn) {
        this.remindOn = remindOn;
    }

    public String getRemindTime() {
        return remindTime;
    }

    public void setRemindTime(String remindTime) {
        this.remindTime = remindTime;
    }

    public Integer getArchived() {
        return archived;
    }

    public void setArchived(Integer archived) {
        this.archived = archived;
    }
}
