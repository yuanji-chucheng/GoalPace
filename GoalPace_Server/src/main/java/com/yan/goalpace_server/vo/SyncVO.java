package com.yan.goalpace_server.vo;

import java.util.List;

/**
 * 增量同步结果: GET /api/sync?since=
 */
public class SyncVO {

    private List<GoalVO> goals;

    private List<TaskVO> tasks;

    private List<PointLogVO> pointLogs;

    private List<ReviewVO> reviewNotes;

    private UserVO user;

    private Long serverTime;

    public List<GoalVO> getGoals() {
        return goals;
    }

    public void setGoals(List<GoalVO> goals) {
        this.goals = goals;
    }

    public List<TaskVO> getTasks() {
        return tasks;
    }

    public void setTasks(List<TaskVO> tasks) {
        this.tasks = tasks;
    }

    public List<PointLogVO> getPointLogs() {
        return pointLogs;
    }

    public void setPointLogs(List<PointLogVO> pointLogs) {
        this.pointLogs = pointLogs;
    }

    public List<ReviewVO> getReviewNotes() {
        return reviewNotes;
    }

    public void setReviewNotes(List<ReviewVO> reviewNotes) {
        this.reviewNotes = reviewNotes;
    }

    public UserVO getUser() {
        return user;
    }

    public void setUser(UserVO user) {
        this.user = user;
    }

    public Long getServerTime() {
        return serverTime;
    }

    public void setServerTime(Long serverTime) {
        this.serverTime = serverTime;
    }
}
