package com.yan.goalpace_server.vo;

/**
 * 统计: 目标进度榜条目
 */
public class GoalProgressVO {

    private Long goalId;

    private String title;

    private int progress;

    private int taskDone;

    private int taskTotal;

    public GoalProgressVO() {
    }

    public GoalProgressVO(Long goalId, String title, int progress, int taskDone, int taskTotal) {
        this.goalId = goalId;
        this.title = title;
        this.progress = progress;
        this.taskDone = taskDone;
        this.taskTotal = taskTotal;
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

    public int getProgress() {
        return progress;
    }

    public void setProgress(int progress) {
        this.progress = progress;
    }

    public int getTaskDone() {
        return taskDone;
    }

    public void setTaskDone(int taskDone) {
        this.taskDone = taskDone;
    }

    public int getTaskTotal() {
        return taskTotal;
    }

    public void setTaskTotal(int taskTotal) {
        this.taskTotal = taskTotal;
    }
}
