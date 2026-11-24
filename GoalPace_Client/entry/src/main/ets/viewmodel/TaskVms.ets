import { GoalApi, SyncApi, TaskApi } from '../model/Api';
import { Cache } from '../model/Cache';
import { Prefs } from '../model/Prefs';
import { Fmt } from '../common/Fmt';
import { Reminder } from '../common/Reminder';
import { Errors } from '../common/Errors';
import { AppSession } from './Session';
import { Goal, SaveTaskReq, Task, ToggleResult } from '../model/Models';

/**
 * 任务分组(按目标)
 */
export class TaskGroup {
  goalId: number = 0;
  goalTitle: string = '';
  items: Task[] = [];

  constructor(goalId: number, goalTitle: string) {
    this.goalId = goalId;
    this.goalTitle = goalTitle;
  }
}

/**
 * S2 今日 ViewModel
 */
@ObservedV2
export class TodayVm {
  @Trace loading: boolean = true;
  @Trace offline: boolean = false;
  @Trace tasks: Task[] = [];
  @Trace showDelta: boolean = false;
  @Trace deltaText: string = '';
  @Trace syncing: boolean = false;

  async refresh(): Promise<void> {
    this.loading = this.tasks.length === 0;
    try {
      const list = await TaskApi.today();
      this.tasks = list;
      this.offline = false;
    } catch (error) {
      const cached = await Cache.getTasks();
      const todayStr = Fmt.today();
      this.tasks = cached.filter((t: Task): boolean => {
        const pending = t.status === 0 && t.dueDate !== '' && t.dueDate <= todayStr;
        const doneToday = t.status === 1 && t.completeTime.startsWith(todayStr);
        return pending || doneToday;
      });
      this.offline = true;
    }
    this.loading = false;
  }

  /** Refresh 下拉: GET /sync 增量回刷缓存 */
  async sync(): Promise<void> {
    this.syncing = true;
    try {
      const since = await Prefs.getLastSync();
      const payload = await SyncApi.sync(since);
      if (payload.goals.length > 0) {
        await Cache.saveGoals(payload.goals);
      }
      if (payload.tasks.length > 0) {
        await Cache.saveTasks(payload.tasks);
      }
      if (payload.pointLogs.length > 0) {
        await Cache.savePointLogs(payload.pointLogs);
      }
      if (payload.reviewNotes.length > 0) {
        await Cache.saveReviews(payload.reviewNotes);
      }
      AppSession.inst.applyUser(payload.user);
      await Prefs.setLastSync(payload.serverTime);
    } catch (error) {
      // 静默
    }
    this.syncing = false;
    await this.refresh();
  }

  /** 按目标分组 */
  groups(): TaskGroup[] {
    const result: TaskGroup[] = [];
    for (const t of this.tasks) {
      let group: TaskGroup | null = null;
      for (const g of result) {
        if (g.goalId === t.goalId) {
          group = g;
          break;
        }
      }
      if (group === null) {
        group = new TaskGroup(t.goalId, t.goalTitle);
        result.push(group);
      }
      group.items.push(t);
    }
    return result;
  }

  todayDoneCount(): number {
    const todayStr = Fmt.today();
    return this.tasks.filter((t: Task): boolean =>
      t.status === 1 && t.completeTime.startsWith(todayStr)).length;
  }

  todayPendingCount(): number {
    return this.tasks.filter((t: Task): boolean => t.status === 0).length;
  }

  /** 勾选完成: 服务端结算积分 + 进度重算, 客户端回刷 */
  async toggle(task: Task): Promise<void> {
    try {
      const result = await TaskApi.toggle(task.id);
      const next: Task[] = [];
      for (const t of this.tasks) {
        if (t.id === task.id) {
          next.push(result.task);
        } else {
          next.push(t);
        }
      }
      this.tasks = next;
      this.syncUser(result);
      if (result.pointsDelta > 0) {
        this.deltaText = '+' + result.pointsDelta.toString();
        this.showDelta = true;
        setTimeout(() => {
          this.showDelta = false;
        }, 1400);
      }
    } catch (error) {
      // 调用方不提示, 保守静默; 列表状态未变更
    }
  }

  private syncUser(result: ToggleResult): void {
    const user = AppSession.inst.user;
    user.points = result.userPoints;
    user.level = result.userLevel;
    user.checkinDays = result.userCheckinDays;
    AppSession.inst.applyUser(user);
  }
}

/**
 * S6 全部任务 ViewModel
 */
@ObservedV2
export class TasksVm {
  @Trace loading: boolean = true;
  @Trace offline: boolean = false;
  @Trace statusChip: number = 0;
  @Trace priorityChip: number = 0;
  @Trace tasks: Task[] = [];

  async refresh(): Promise<void> {
    this.loading = this.tasks.length === 0;
    try {
      const status = this.statusChip === 0 ? -1 : this.statusChip - 1;
      const priority = this.priorityChip === 0 ? 0 : 4 - this.priorityChip;
      const list = await TaskApi.list(0, status, priority);
      this.tasks = list;
      this.offline = false;
      await Cache.saveTasks(list);
    } catch (error) {
      const cached = await Cache.getTasks();
      this.tasks = cached;
      this.offline = true;
    }
    this.loading = false;
  }

  groups(): TaskGroup[] {
    const result: TaskGroup[] = [];
    for (const t of this.tasks) {
      let group: TaskGroup | null = null;
      for (const g of result) {
        if (g.goalId === t.goalId) {
          group = g;
          break;
        }
      }
      if (group === null) {
        group = new TaskGroup(t.goalId, t.goalTitle);
        result.push(group);
      }
      group.items.push(t);
    }
    return result;
  }

  async toggle(task: Task): Promise<void> {
    try {
      const result = await TaskApi.toggle(task.id);
      const next: Task[] = [];
      for (const t of this.tasks) {
        if (t.id === task.id) {
          next.push(result.task);
        } else {
          next.push(t);
        }
      }
      this.tasks = next;
      const user = AppSession.inst.user;
      user.points = result.userPoints;
      user.level = result.userLevel;
      user.checkinDays = result.userCheckinDays;
      AppSession.inst.applyUser(user);
      // 状态筛选下刷新过滤结果
      if (this.statusChip !== 0) {
        await this.refresh();
      }
    } catch (error) {
      // 静默
    }
  }

  async remove(taskId: number): Promise<string> {
    try {
      await TaskApi.remove(taskId);
      this.tasks = this.tasks.filter((t: Task): boolean => t.id !== taskId);
      return '';
    } catch (error) {
      return Errors.text(error);
    }
  }
}

/**
 * S14 任务表单 ViewModel
 */
@ObservedV2
export class TaskFormVm {
  @Trace loading: boolean = false;
  @Trace saving: boolean = false;
  @Trace goalId: number = 0;
  @Trace taskId: number = 0;
  @Trace goals: Goal[] = [];
  @Trace title: string = '';
  @Trace dueDate: string = '';
  @Trace dueTime: string = '';
  @Trace priority: number = 2;
  @Trace note: string = '';
  @Trace remindOn: boolean = false;
  @Trace remindAdvance: number = 30;
  @Trace goalLocked: boolean = false;

  static readonly ADVANCES: number[] = [5, 15, 30, 60];

  async load(goalId: number, taskId: number): Promise<string> {
    this.goalId = goalId;
    this.taskId = taskId;
    this.goalLocked = goalId > 0;
    this.loading = true;
    try {
      const goals = await GoalApi.list();
      this.goals = goals;
      if (this.goalId === 0 && goals.length > 0) {
        this.goalId = goals[0].id;
      }
      if (taskId > 0) {
        const tasks = await TaskApi.list(0, -1, 0);
        const matched = tasks.find((t: Task): boolean => t.id === taskId);
        if (matched !== undefined) {
          this.goalId = matched.goalId;
          this.title = matched.title;
          this.dueDate = matched.dueDate;
          this.dueTime = matched.dueTime;
          this.priority = matched.priority;
          this.note = matched.note;
          this.remindOn = matched.remindOn === 1;
          this.remindAdvance = matched.remindAdvance;
          if (goalId > 0) {
            this.goalLocked = true;
          }
        }
      }
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.loading = false;
    }
  }

  goalTitle(): string {
    const matched = this.goals.find((g: Goal): boolean => g.id === this.goalId);
    return matched === undefined ? '' : matched.title;
  }

  async save(): Promise<string> {
    if (this.title.trim() === '') {
      return '请输入任务标题';
    }
    if (this.goalId <= 0) {
      return '请选择关联目标';
    }
    const req = new SaveTaskReq();
    req.goalId = this.goalId;
    req.title = this.title.trim();
    req.dueDate = this.dueDate;
    req.dueTime = this.dueTime;
    req.priority = this.priority;
    req.note = this.note;
    req.remindOn = this.remindOn ? 1 : 0;
    req.remindAdvance = this.remindAdvance;
    this.saving = true;
    try {
      if (this.taskId > 0) {
        const updated = await TaskApi.update(this.taskId, req);
        await Reminder.publishTaskReminder(updated);
      } else {
        const created = await TaskApi.create(req);
        await Reminder.publishTaskReminder(created);
        const cached = await Cache.getTasks();
        cached.push(created);
        await Cache.saveTasks(cached);
      }
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.saving = false;
    }
  }
}
