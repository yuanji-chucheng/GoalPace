package com.yan.goalpace_server.vo;

/**
 * 任务视图(带目标标题冗余, 便于客户端分组展示)
 */
public class TaskVO {

    private Long id;

    private Long goalId;

    private String goalTitle;

    private String title;

    private String dueDate;

    private String dueTime;

    private Integer priority;

    private String note;

    private Integer remindOn;

    private Integer remindAdvance;

    private Integer status;

    private String completeTime;

    private String updateTime;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getGoalId() {
        return goalId;
    }

    public void setGoalId(Long goalId) {
        this.goalId = goalId;
    }

    public String getGoalTitle() {
        return goalTitle;
    }

    public void setGoalTitle(String goalTitle) {
        this.goalTitle = goalTitle;
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

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public String getCompleteTime() {
        return completeTime;
    }

    public void setCompleteTime(String completeTime) {
        this.completeTime = completeTime;
    }

    public String getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime;
    }
}
