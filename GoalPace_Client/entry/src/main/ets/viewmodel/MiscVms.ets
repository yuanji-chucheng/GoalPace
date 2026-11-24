import { PointApi, ReviewApi, StatsApi, GoalApi } from '../model/Api';
import { Cache } from '../model/Cache';
import { Prefs } from '../model/Prefs';
import { Reminder } from '../common/Reminder';
import { Errors } from '../common/Errors';
import { AppSession } from './Session';
import { DailyCount, Goal, GoalProgress, PointLog, ReviewNote, RuleItem,
  SaveReviewReq, StatsData } from '../model/Models';

/**
 * S7 统计 ViewModel
 */
@ObservedV2
export class StatsVm {
  @Trace loading: boolean = true;
  @Trace period: string = 'week';
  @Trace data: StatsData = new StatsData();
  @Trace offline: boolean = false;

  async refresh(): Promise<void> {
    this.loading = this.data.dailyCounts.length === 0;
    try {
      const data = await StatsApi.stats(this.period);
      this.data = data;
      this.offline = false;
    } catch (error) {
      this.offline = true;
    }
    this.loading = false;
  }

  async setPeriod(period: string): Promise<void> {
    this.period = period;
    await this.refresh();
  }

  maxDaily(): number {
    let max = 0;
    for (const d of this.data.dailyCounts) {
      if (d.done > max) {
        max = d.done;
      }
    }
    return max < 1 ? 1 : max;
  }
}

/**
 * S10 积分激励 ViewModel
 */
@ObservedV2
export class PointsVm {
  @Trace loading: boolean = true;
  @Trace offline: boolean = false;
  @Trace rules: RuleItem[] = [];
  @Trace logs: PointLog[] = [];

  /** 规则表默认(离线兜底) */
  static readonly DEFAULT_RULES: string[][] = [
    ['完成任务', '+10'], ['完成高优任务', '+15'], ['连续打卡7天', '+50'], ['达成目标', '+200']
  ];

  async refresh(): Promise<void> {
    this.loading = this.logs.length === 0;
    try {
      const rules = await PointApi.rules();
      const logs = await PointApi.logs();
      this.rules = rules;
      this.logs = logs;
      this.offline = false;
      await Cache.savePointLogs(logs);
    } catch (error) {
      const cached = await Cache.getPointLogs();
      this.logs = cached;
      this.offline = true;
    }
    this.loading = false;
  }

  /** 12 周热力图: 日期 → 当日正向积分 */
  heatmap(): Map<string, number> {
    const map = new Map<string, number>();
    for (const log of this.logs) {
      if (log.change <= 0 || log.createTime.length < 10) {
        continue;
      }
      const day = log.createTime.substring(0, 10);
      const prev = map.get(day);
      map.set(day, (prev === undefined ? 0 : prev) + log.change);
    }
    return map;
  }

  hasLogReason(reason: string): boolean {
    return this.logs.find((l: PointLog): boolean => l.reason === reason) !== undefined;
  }

  /** 徽章墙(仅展示) */
  badges(): string[][] {
    const user = AppSession.inst.user;
    const result: string[][] = [];
    result.push(['🌱', '初拾台阶', this.logs.length > 0 ? '已获得' : '完成首个任务']);
    result.push(['🔥', '连续七日', this.hasLogReason('连续打卡7天') ? '已获得' : '连续打卡7天']);
    result.push(['🏔', '登顶目标', this.hasLogReason('达成目标奖励') ? '已获得' : '达成一个目标']);
    result.push(['🪜', '三级台阶', user.level >= 3 ? '已获得' : '等级达到 Lv.3']);
    return result;
  }
}

/**
 * S8 我的 ViewModel
 */
@ObservedV2
export class ProfileVm {
  @Trace loading: boolean = true;
  @Trace goalCount: number = 0;
  @Trace remindOn: boolean = true;
  @Trace exporting: boolean = false;

  async refresh(): Promise<void> {
    this.remindOn = await this.getRemind();
    try {
      const goals = await GoalApi.list();
      this.goalCount = goals.length;
    } catch (error) {
      const cached = await Cache.getGoals();
      this.goalCount = cached.length;
    }
    this.loading = false;
  }

  private async getRemind(): Promise<boolean> {
    return Prefs.getRemindOn();
  }

  async setRemind(on: boolean): Promise<void> {
    this.remindOn = on;
    await Reminder.setRemindPref(on);
  }
}

/**
 * S9 复盘笔记 ViewModel
 */
@ObservedV2
export class ReviewVm {
  @Trace loading: boolean = true;
  @Trace saving: boolean = false;
  @Trace goalId: number = 0;
  @Trace goalLocked: boolean = false;
  @Trace goals: Goal[] = [];
  @Trace content: string = '';
  @Trace notes: ReviewNote[] = [];
  @Trace offline: boolean = false;

  async load(goalId: number): Promise<void> {
    this.goalId = goalId;
    this.goalLocked = goalId > 0;
    await this.refresh();
  }

  async refresh(): Promise<void> {
    this.loading = this.notes.length === 0;
    try {
      const goals = await GoalApi.list();
      if (!this.goalLocked && this.goalId === 0 && goals.length > 0) {
        this.goalId = goals[0].id;
      }
      this.goals = goals;
      const notes = await ReviewApi.list(this.goalLocked ? this.goalId : 0);
      this.notes = notes;
      this.offline = false;
      await Cache.saveReviews(notes);
    } catch (error) {
      const cached = await Cache.getReviews();
      this.notes = cached;
      this.offline = true;
    }
    this.loading = false;
  }

  goalTitle(): string {
    const matched = this.goals.find((g: Goal): boolean => g.id === this.goalId);
    return matched === undefined ? '' : matched.title;
  }

  /** 自由文本写入 review_notes(经 POST /api/reviews) */
  async save(): Promise<string> {
    if (this.content.trim() === '') {
      return '请输入复盘内容';
    }
    if (this.goalId <= 0) {
      return '请选择关联目标';
    }
    const req = new SaveReviewReq();
    req.goalId = this.goalId;
    req.content = this.content.trim();
    this.saving = true;
    try {
      await ReviewApi.create(req);
      this.content = '';
      await this.refresh();
      return '';
    } catch (error) {
      return Errors.text(error);
    } finally {
      this.saving = false;
    }
  }
}

/**
 * 供 S7 进度榜展示的轻量条目转换
 */
export function toProgressRows(list: GoalProgress[]): GoalProgress[] {
  return list;
}

/**
 * 供 S7 柱状图展示的轻量条目转换
 */
export function toDailyRows(list: DailyCount[]): DailyCount[] {
  return list;
}
