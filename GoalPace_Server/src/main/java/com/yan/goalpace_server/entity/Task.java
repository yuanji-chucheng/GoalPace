package com.yan.goalpace_server.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 任务实体, 映射 tasks 表
 */
@TableName("tasks")
public class Task {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    @TableField("goal_id")
    private Long goalId;

    @TableField("title")
    private String title;

    @TableField("due_date")
    private LocalDate dueDate;

    @TableField("due_time")
    private String dueTime;

    @TableField("priority")
    private Integer priority;

    @TableField("note")
    private String note;

    @TableField("remind_on")
    private Integer remindOn;

    @TableField("remind_advance")
    private Integer remindAdvance;

    @TableField("status")
    private Integer status;

    @TableField("complete_time")
    private LocalDateTime completeTime;

    @TableField("update_time")
    private LocalDateTime updateTime;

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

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDate dueDate) {
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

    public LocalDateTime getCompleteTime() {
        return completeTime;
    }

    public void setCompleteTime(LocalDateTime completeTime) {
        this.completeTime = completeTime;
    }

    public LocalDateTime getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(LocalDateTime updateTime) {
        this.updateTime = updateTime;
    }
}
