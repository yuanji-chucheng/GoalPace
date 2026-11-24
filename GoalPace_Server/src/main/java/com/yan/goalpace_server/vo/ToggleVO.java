package com.yan.goalpace_server.vo;

/**
 * 勾选完成任务的结算结果: 客户端据此展示 +10/+15 微动效并回刷缓存
 */
public class ToggleVO {

    private TaskVO task;

    private Integer pointsDelta;

    private Integer userPoints;

    private Integer userLevel;

    private Integer userCheckinDays;

    private Integer goalProgress;

    public ToggleVO() {
    }

    public ToggleVO(TaskVO task, Integer pointsDelta, Integer userPoints, Integer userLevel,
                     Integer userCheckinDays, Integer goalProgress) {
        this.task = task;
        this.pointsDelta = pointsDelta;
        this.userPoints = userPoints;
        this.userLevel = userLevel;
        this.userCheckinDays = userCheckinDays;
        this.goalProgress = goalProgress;
    }

    public TaskVO getTask() {
        return task;
    }

    public void setTask(TaskVO task) {
        this.task = task;
    }

    public Integer getPointsDelta() {
        return pointsDelta;
    }

    public void setPointsDelta(Integer pointsDelta) {
        this.pointsDelta = pointsDelta;
    }

    public Integer getUserPoints() {
        return userPoints;
    }

    public void setUserPoints(Integer userPoints) {
        this.userPoints = userPoints;
    }

    public Integer getUserLevel() {
        return userLevel;
    }

    public void setUserLevel(Integer userLevel) {
        this.userLevel = userLevel;
    }

    public Integer getUserCheckinDays() {
        return userCheckinDays;
    }

    public void setUserCheckinDays(Integer userCheckinDays) {
        this.userCheckinDays = userCheckinDays;
    }

    public Integer getGoalProgress() {
        return goalProgress;
    }

    public void setGoalProgress(Integer goalProgress) {
        this.goalProgress = goalProgress;
    }
}
