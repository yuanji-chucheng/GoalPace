package com.yan.goalpace_server.controller;

import com.yan.goalpace_server.common.Result;
import com.yan.goalpace_server.dto.SaveTaskDTO;
import com.yan.goalpace_server.service.TaskService;
import com.yan.goalpace_server.util.UserContext;
import com.yan.goalpace_server.vo.TaskVO;
import com.yan.goalpace_server.vo.ToggleVO;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import java.util.List;

/**
 * 任务接口: 勾选完成走 /toggle, 由服务端结算积分并重算进度
 */
@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @GetMapping
    public Result<List<TaskVO>> list(@RequestParam(name = "goalId", required = false) Long goalId,
                                     @RequestParam(name = "status", required = false) Integer status,
                                     @RequestParam(name = "priority", required = false) Integer priority) {
        return Result.success(taskService.list(UserContext.getUserId(), goalId, status, priority));
    }

    @GetMapping("/today")
    public Result<List<TaskVO>> today() {
        return Result.success(taskService.today(UserContext.getUserId()));
    }

    @PostMapping
    public Result<TaskVO> create(@Valid @RequestBody SaveTaskDTO dto) {
        return Result.success(taskService.create(UserContext.getUserId(), dto));
    }

    @PutMapping("/{id}")
    public Result<TaskVO> update(@PathVariable("id") Long id, @Valid @RequestBody SaveTaskDTO dto) {
        return Result.success(taskService.update(UserContext.getUserId(), id, dto));
    }

    /**
     * 勾选 / 取消完成, 服务端结算积分并重算进度
     */
    @PutMapping("/{id}/toggle")
    public Result<ToggleVO> toggle(@PathVariable("id") Long id) {
        return Result.success(taskService.toggle(UserContext.getUserId(), id));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable("id") Long id) {
        taskService.delete(UserContext.getUserId(), id);
        return Result.success();
    }
}
