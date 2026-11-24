import { GoalApi, TaskApi } from '../model/Api';
import { Cache } from '../model/Cache';
import { Fmt } from '../common/Fmt';
import { Errors } from '../common/Errors';
import { AppSession } from './Session';
import { Goal, SaveGoalReq, Task, ToggleResult } from '../model/Models';

/**
 * 目标模块 ViewModel: 列表 / 详情 / 表单
 */
@ObservedV2
export class GoalsVm {
  @Trace loading: boolean = true;
  @Trace offline: boolean = false;
  @Trace chipIdx: number = 0;
  @Trace goals: Goal[] = [];

  async refresh(): Promise<void> {
    this.loading = this.goals.length === 0;
    try {
      const list = this.chipIdx === 3 ? await GoalApi.archivedList() : await GoalApi.list();
      this.goals = list;
      this.offline = false;
      await Cache.saveGoals(list);
    } catch (error) {
      const cached = await Cache.getGoals();
      this.goals = cached.filter((g: Goal): boolean => this.chipIdx === 3 ? g.archived === 1 : g.archived === 0);
      this.offline = true;
    }
    this.loading = false;
  }

  /** 全部/进行中/已达成 过滤(已归档单独 chip) */
  displayed(): Goal[] {
    if (this.chipIdx === 1) {
      return this.goals.filter((g: Goal): boolean => g.progress < 100);
    }
    if (this.chipIdx === 2) {
      return this.goals.filter((g: Goal): boolean => g.progress >= 100);
    }
    return this.goals;
  }

  async setArchived(goalId: number, archived: boolean): Promise<string> {
    try {
      await GoalApi.setArchived(goalId, archived);
      await this.refresh();
      return '';
    } catch (error) {
      return Errors.text(error);
    }
  }

  async remove(goalId: number): Promise<string> {
    try {
      await GoalApi.remove(goalId);
      await this.refresh();
      return '';
    } catch (error) {
      return Errors.text(error);
    }
  }
}

@ObservedV2
export class GoalDetailVm {
  @Trace loading: boolean = true;
  @Trace goal: Goal = new Goal();
  @Trace tasks: Task[] = [];
  @Trace offline: boolean = false;

  async load(goalId: number): Promise<void> {
    this.loading = true;
    try {
      const goal = await GoalApi.get(goalId);
      this.goal = goal;
      await Cache.saveUser(AppSession.inst.user);
      const tasks = await TaskApi.list(goalId, -1, 0);
      this.tasks = tasks;
      this.offline = false;
    } catch (error) {
      const cached = await Cache.getGoals();
      const matched = cached.find((g: Goal): boolean => g.id === goalId);
      if (matched !== undefined) {
        this.goal = matched;
      }
      const cachedTasks = await Cache.getTasks();
      this.tasks = cachedTasks.filter((t: Task): boolean => t.goalId === goalId);
      this.offline = true;
    }
    this.loading = false;
  }

  async toggle(task: Task): Promise<ToggleResult | null> {
    try {
      const result = await TaskApi.toggle(task.id);
      this.applyToggle(result, task.id);
      return result;
    } catch (error) {
      return null;
    }
  }

  async deleteTask(taskId: number): Promise<string> {
    try {
      await TaskApi.remove(taskId);
      this.tasks = this.tasks.filter((t: Task): boolean => t.id !== taskId);
      const goal = await GoalApi.get(this.goal.id);
      this.goal = goal;
      return '';
    } catch (error) {
      return Errors.text(error);
    }
  }

  private applyToggle(result: ToggleResult, taskId: number): void {
    const next: Task[] = [];
    for (const t of this.tasks) {
      if (t.id === taskId) {
        next.push(result.task);
      } else {
        next.push(t);
      }
    }
    this.tasks = next;
    this.goal.progress = result.goalProgress;
    AppSession.inst.applyUser(AppSession.inst.user);
    this.syncUserFromToggle(result);
  }

  private syncUserFromToggle(result: ToggleResult): void {
    const user = AppSession.inst.user;
    user.points = result.userPoints;
    user.level = result.userLevel;
    user.checkinDays = result.userCheckinDays;
    AppSession.inst.applyUser(user);
  }

  async archiveGoal(archived: boolean): Promise<string> {
    try {
      await GoalApi.setArchived(this.goal.id, archived);
      await this.load(this.goal.id);
      return '';
    } catch (error) {
      return Errors.text(error);
    }
  }

  async removeGoal(): Promise<string> {
    try {
      await GoalApi.remove(this.goal.id);
      return '';
    } catch (error) {
      return Errors.text(error);
    }
  }
}

@ObservedV2
export class GoalFormVm {
  @Trace loading: boolean = false;
  @Trace saving: boolean = false;
  @Trace goalId: number = 0;
  @Trace title: string = '';
  @Trace type: string = '习惯';
  @Trace category: string = '成长';
  @Trace priority: number = 2;
  @Trace startDate: string = Fmt.today();
  @Trace endDate: string = '';
  @Trace description: string = '';
  @Trace remindOn: boolean = false;
  @Trace remindTime: string = '19:00';
  @Trace archived: boolean = false;

  static readonly TYPES: string[] = ['长期', '短期', '习惯'];
  static readonly CATEGORIES: string[] = ['成长', '学习', '健康', '事业', '生活', '其他'];

  async load(goalId: number): Promise<string> {
    if (goalId <= 0) {
      return '';
    }
    this.goalId = goalId;
    this.loading = true;
    try {
      const goal = await GoalApi.get(goalId);
      this.title = goal.title;
      this.type = goal.type;
      this.category = goal.category;
      this.priority = goal.priority;
      this.startDate = goal.startDate;
      this.endDate = goal.endDate;
      this.description = goal.description;
      this.remindOn = goal.remindOn === 1;
      this.remindTime = goal.remindTime === '' ? '19:00' : goal.remindTime;
      this.archived = goal.archived === 1;
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.loading = false;
    }
  }

  async save(): Promise<string> {
    if (this.title.trim() === '') {
      return '请输入目标标题';
    }
    const req = new SaveGoalReq();
    req.title = this.title.trim();
    req.type = this.type;
    req.category = this.category;
    req.priority = this.priority;
    req.startDate = this.startDate;
    req.endDate = this.endDate;
    req.description = this.description;
    req.remindOn = this.remindOn ? 1 : 0;
    req.remindTime = this.remindTime;
    req.archived = this.archived ? 1 : 0;
    this.saving = true;
    try {
      if (this.goalId > 0) {
        await GoalApi.update(this.goalId, req);
      } else {
        await GoalApi.create(req);
      }
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.saving = false;
    }
  }
}
