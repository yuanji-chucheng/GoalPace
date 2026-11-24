package com.yan.goalpace_server.vo;

/**
 * 统计: 单日完成量
 */
public class DailyCountVO {

    private String date;

    private int done;

    public DailyCountVO() {
    }

    public DailyCountVO(String date, int done) {
        this.date = date;
        this.done = done;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public int getDone() {
        return done;
    }

    public void setDone(int done) {
        this.done = done;
    }
}
