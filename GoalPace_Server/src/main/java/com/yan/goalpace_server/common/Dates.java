package com.yan.goalpace_server.common;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * 日期与格式化工具
 */
public final class Dates {

    public static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public static final DateTimeFormatter DATETIME = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private Dates() {
    }

    public static String format(LocalDate date) {
        return date == null ? null : date.format(DATE);
    }

    public static String formatTime(LocalDateTime time) {
        return time == null ? null : time.format(DATETIME);
    }

    public static LocalDate parseDate(String text) {
        if (text == null || text.isEmpty()) {
            return null;
        }
        return LocalDate.parse(text, DATE);
    }
}
