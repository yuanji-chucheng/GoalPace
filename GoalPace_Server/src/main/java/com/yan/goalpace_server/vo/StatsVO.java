package com.yan.goalpace_server.vo;

import java.util.List;

/**
 * 统计结果(本周/本月)
 */
public class StatsVO {

    private String period;

    private String startDate;

    private String endDate;

    private int taskDone;

    private int pointsGained;

    private int checkinDays;

    private List<DailyCountVO> dailyCounts;

    private List<GoalProgressVO> goalProgress;

    public String getPeriod() {
        return period;
    }

    public void setPeriod(String period) {
        this.period = period;
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

    public int getTaskDone() {
        return taskDone;
    }

    public void setTaskDone(int taskDone) {
        this.taskDone = taskDone;
    }

    public int getPointsGained() {
        return pointsGained;
    }

    public void setPointsGained(int pointsGained) {
        this.pointsGained = pointsGained;
    }

    public int getCheckinDays() {
        return checkinDays;
    }

    public void setCheckinDays(int checkinDays) {
        this.checkinDays = checkinDays;
    }

    public List<DailyCountVO> getDailyCounts() {
        return dailyCounts;
    }

    public void setDailyCounts(List<DailyCountVO> dailyCounts) {
        this.dailyCounts = dailyCounts;
    }

    public List<GoalProgressVO> getGoalProgress() {
        return goalProgress;
    }

    public void setGoalProgress(List<GoalProgressVO> goalProgress) {
        this.goalProgress = goalProgress;
    }
}
