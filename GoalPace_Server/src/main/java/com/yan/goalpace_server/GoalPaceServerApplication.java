package com.yan.goalpace_server;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.yan.goalpace_server.mapper")
public class GoalPaceServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(GoalPaceServerApplication.class, args);
    }

}
