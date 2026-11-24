package com.yan.goalpace_server.controller;

import com.yan.goalpace_server.common.Result;
import com.yan.goalpace_server.dto.SaveGoalDTO;
import com.yan.goalpace_server.service.GoalService;
import com.yan.goalpace_server.util.UserContext;
import com.yan.goalpace_server.vo.GoalVO;
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
 * 目标接口
 */
@RestController
@RequestMapping("/api/goals")
public class GoalController {

    private final GoalService goalService;

    public GoalController(GoalService goalService) {
        this.goalService = goalService;
    }

    /**
     * 进行中的目标列表(archived=false)
     */
    @GetMapping
    public Result<List<GoalVO>> list(@RequestParam(name = "archived", required = false,
            defaultValue = "false") boolean archived) {
        return Result.success(goalService.list(UserContext.getUserId(), archived));
    }

    /**
     * 已归档目标列表
     */
    @GetMapping("/archived")
    public Result<List<GoalVO>> archivedList() {
        return Result.success(goalService.list(UserContext.getUserId(), true));
    }

    @GetMapping("/{id}")
    public Result<GoalVO> get(@PathVariable("id") Long id) {
        return Result.success(goalService.get(UserContext.getUserId(), id));
    }

    @PostMapping
    public Result<GoalVO> create(@Valid @RequestBody SaveGoalDTO dto) {
        return Result.success(goalService.create(UserContext.getUserId(), dto));
    }

    @PutMapping("/{id}")
    public Result<GoalVO> update(@PathVariable("id") Long id, @Valid @RequestBody SaveGoalDTO dto) {
        return Result.success(goalService.update(UserContext.getUserId(), id, dto));
    }

    /**
     * 归档 / 取消归档
     */
    @PutMapping("/{id}/archive")
    public Result<GoalVO> setArchived(@PathVariable("id") Long id,
                                      @RequestParam("archived") boolean archived) {
        return Result.success(goalService.setArchived(UserContext.getUserId(), id, archived));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable("id") Long id) {
        goalService.delete(UserContext.getUserId(), id);
        return Result.success();
    }
}
