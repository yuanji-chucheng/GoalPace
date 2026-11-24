package com.yan.goalpace_server.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * 新建/编辑任务请求
 */
public class SaveTaskDTO {

    @NotNull(message = "请选择关联目标")
    private Long goalId;

    @Size(min = 1, max = 100, message = "任务标题为1-100字")
    private String title;

    private String dueDate;

    private String dueTime;

    @NotNull(message = "请选择优先级")
    @Min(value = 1, message = "优先级不合法")
    @Max(value = 3, message = "优先级不合法")
    private Integer priority;

    @Size(max = 500, message = "备注不能超过500字")
    private String note;

    private Integer remindOn;

    private Integer remindAdvance;

    public Long getGoalId() {
        return goalId;
    }

    public void setGoalId(Long goalId) {
        this.goalId = goalId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDueDate() {
        return dueDate;
    }

    public void setDueDate(String dueDate) {
        this.dueDate = dueDate;
    }

    public String getDueTime() {
        return dueTime;
    }

    public void setDueTime(String dueTime) {
        this.dueTime = dueTime;
    }

    public Integer getPriority() {
        return priority;
    }

    public void setPriority(Integer priority) {
        this.priority = priority;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public Integer getRemindOn() {
        return remindOn;
    }

    public void setRemindOn(Integer remindOn) {
        this.remindOn = remindOn;
    }

    public Integer getRemindAdvance() {
        return remindAdvance;
    }

    public void setRemindAdvance(Integer remindAdvance) {
        this.remindAdvance = remindAdvance;
    }
}
