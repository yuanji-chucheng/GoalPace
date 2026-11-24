package com.yan.goalpace_server.service.impl;

/**
 * 积分与等级规则(积分体系只做「规则表 + 累计 + 展示」)
 */
public final class Rules {

    /** 普通任务完成 */
    public static final int POINTS_TASK = 10;

    /** 高优任务完成 */
    public static final int POINTS_TASK_HIGH = 15;

    /** 连续打卡满 7 天 */
    public static final int POINTS_STREAK_7 = 50;

    /** 达成目标 */
    public static final int POINTS_GOAL_DONE = 200;

    /** 台阶等级: 每满 100 积升一级 */
    public static final int LEVEL_STEP = 100;

    private Rules() {
    }

    public static int levelOf(int points) {
        return Math.max(1, points / LEVEL_STEP + 1);
    }

    public static int taskPoints(int priority) {
        return priority == 3 ? POINTS_TASK_HIGH : POINTS_TASK;
    }
}
