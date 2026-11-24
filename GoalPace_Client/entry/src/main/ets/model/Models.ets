/**
 * 实体 / DTO 模型与服务端响应归一化
 * 服务端字段与本地一一对应, from() 做空值归一
 */
export class User {
  id: number = 0;
  username: string = '';
  nickname: string = '';
  avatar: string = '';
  points: number = 0;
  level: number = 1;
  checkinDays: number = 0;

  static from(raw: User): User {
    const u = new User();
    u.id = raw.id ?? 0;
    u.username = raw.username ?? '';
    u.nickname = raw.nickname ?? '';
    u.avatar = raw.avatar ?? '';
    u.points = raw.points ?? 0;
    u.level = raw.level ?? 1;
    u.checkinDays = raw.checkinDays ?? 0;
    return u;
  }
}

export class LoginResult {
  token: string = '';
  user: User = new User();

  static from(raw: LoginResult): LoginResult {
    const r = new LoginResult();
    r.token = raw.token ?? '';
    if (raw.user !== undefined && raw.user !== null) {
      r.user = User.from(raw.user);
    }
    return r;
  }
}

export class Goal {
  id: number = 0;
  title: string = '';
  type: string = '习惯';
  category: string = '成长';
  priority: number = 2;
  startDate: string = '';
  endDate: string = '';
  description: string = '';
  remindOn: number = 0;
  remindTime: string = '';
  archived: number = 0;
  progress: number = 0;
  updateTime: string = '';
  taskTotal: number = 0;
  taskDone: number = 0;

  static from(raw: Goal): Goal {
    const g = new Goal();
    g.id = raw.id ?? 0;
    g.title = raw.title ?? '';
    g.type = raw.type ?? '习惯';
    g.category = raw.category ?? '成长';
    g.priority = raw.priority ?? 2;
    g.startDate = raw.startDate ?? '';
    g.endDate = raw.endDate ?? '';
    g.description = raw.description ?? '';
    g.remindOn = raw.remindOn ?? 0;
    g.remindTime = raw.remindTime ?? '';
    g.archived = raw.archived ?? 0;
    g.progress = raw.progress ?? 0;
    g.updateTime = raw.updateTime ?? '';
    g.taskTotal = raw.taskTotal ?? 0;
    g.taskDone = raw.taskDone ?? 0;
    return g;
  }
}

export class Task {
  id: number = 0;
  goalId: number = 0;
  goalTitle: string = '';
  title: string = '';
  dueDate: string = '';
  dueTime: string = '';
  priority: number = 2;
  note: string = '';
  remindOn: number = 0;
  remindAdvance: number = 30;
  status: number = 0;
  completeTime: string = '';
  updateTime: string = '';

  static from(raw: Task): Task {
    const t = new Task();
    t.id = raw.id ?? 0;
    t.goalId = raw.goalId ?? 0;
    t.goalTitle = raw.goalTitle ?? '';
    t.title = raw.title ?? '';
    t.dueDate = raw.dueDate ?? '';
    t.dueTime = raw.dueTime ?? '';
    t.priority = raw.priority ?? 2;
    t.note = raw.note ?? '';
    t.remindOn = raw.remindOn ?? 0;
    t.remindAdvance = raw.remindAdvance ?? 30;
    t.status = raw.status ?? 0;
    t.completeTime = raw.completeTime ?? '';
    t.updateTime = raw.updateTime ?? '';
    return t;
  }
}

export class PointLog {
  id: number = 0;
  change: number = 0;
  reason: string = '';
  taskId: number = 0;
  createTime: string = '';

  static from(raw: PointLog): PointLog {
    const p = new PointLog();
    p.id = raw.id ?? 0;
    p.change = raw.change ?? 0;
    p.reason = raw.reason ?? '';
    p.taskId = raw.taskId ?? 0;
    p.createTime = raw.createTime ?? '';
    return p;
  }
}

export class ReviewNote {
  id: number = 0;
  goalId: number = 0;
  goalTitle: string = '';
  content: string = '';
  createTime: string = '';

  static from(raw: ReviewNote): ReviewNote {
    const r = new ReviewNote();
    r.id = raw.id ?? 0;
    r.goalId = raw.goalId ?? 0;
    r.goalTitle = raw.goalTitle ?? '';
    r.content = raw.content ?? '';
    r.createTime = raw.createTime ?? '';
    return r;
  }
}

/** 勾选完成的服务端结算结果 */
export class ToggleResult {
  task: Task = new Task();
  pointsDelta: number = 0;
  userPoints: number = 0;
  userLevel: number = 1;
  userCheckinDays: number = 0;
  goalProgress: number = 0;

  static from(raw: ToggleResult): ToggleResult {
    const t = new ToggleResult();
    if (raw.task !== undefined && raw.task !== null) {
      t.task = Task.from(raw.task);
    }
    t.pointsDelta = raw.pointsDelta ?? 0;
    t.userPoints = raw.userPoints ?? 0;
    t.userLevel = raw.userLevel ?? 1;
    t.userCheckinDays = raw.userCheckinDays ?? 0;
    t.goalProgress = raw.goalProgress ?? 0;
    return t;
  }
}

export class DailyCount {
  date: string = '';
  done: number = 0;

  static from(raw: DailyCount): DailyCount {
    const d = new DailyCount();
    d.date = raw.date ?? '';
    d.done = raw.done ?? 0;
    return d;
  }
}

export class GoalProgress {
  goalId: number = 0;
  title: string = '';
  progress: number = 0;
  taskDone: number = 0;
  taskTotal: number = 0;

  static from(raw: GoalProgress): GoalProgress {
    const g = new GoalProgress();
    g.goalId = raw.goalId ?? 0;
    g.title = raw.title ?? '';
    g.progress = raw.progress ?? 0;
    g.taskDone = raw.taskDone ?? 0;
    g.taskTotal = raw.taskTotal ?? 0;
    return g;
  }
}

export class StatsData {
  period: string = 'week';
  startDate: string = '';
  endDate: string = '';
  taskDone: number = 0;
  pointsGained: number = 0;
  checkinDays: number = 0;
  dailyCounts: DailyCount[] = [];
  goalProgress: GoalProgress[] = [];

  static from(raw: StatsData): StatsData {
    const s = new StatsData();
    s.period = raw.period ?? 'week';
    s.startDate = raw.startDate ?? '';
    s.endDate = raw.endDate ?? '';
    s.taskDone = raw.taskDone ?? 0;
    s.pointsGained = raw.pointsGained ?? 0;
    s.checkinDays = raw.checkinDays ?? 0;
    if (raw.dailyCounts !== undefined && raw.dailyCounts !== null) {
      s.dailyCounts = raw.dailyCounts.map((d: DailyCount): DailyCount => DailyCount.from(d));
    }
    if (raw.goalProgress !== undefined && raw.goalProgress !== null) {
      s.goalProgress = raw.goalProgress.map((g: GoalProgress): GoalProgress => GoalProgress.from(g));
    }
    return s;
  }
}

/** 积分规则条目 */
export class RuleItem {
  name: string = '';
  points: number = 0;
  desc: string = '';

  static from(raw: RuleItem): RuleItem {
    const r = new RuleItem();
    r.name = raw.name ?? '';
    r.points = raw.points ?? 0;
    r.desc = raw.desc ?? '';
    return r;
  }
}

/** /api/sync 与 /api/export 载荷 */
export class SyncPayload {
  goals: Goal[] = [];
  tasks: Task[] = [];
  pointLogs: PointLog[] = [];
  reviewNotes: ReviewNote[] = [];
  user: User = new User();
  serverTime: number = 0;

  static from(raw: SyncPayload): SyncPayload {
    const s = new SyncPayload();
    if (raw.goals !== undefined && raw.goals !== null) {
      s.goals = raw.goals.map((g: Goal): Goal => Goal.from(g));
    }
    if (raw.tasks !== undefined && raw.tasks !== null) {
      s.tasks = raw.tasks.map((t: Task): Task => Task.from(t));
    }
    if (raw.pointLogs !== undefined && raw.pointLogs !== null) {
      s.pointLogs = raw.pointLogs.map((p: PointLog): PointLog => PointLog.from(p));
    }
    if (raw.reviewNotes !== undefined && raw.reviewNotes !== null) {
      s.reviewNotes = raw.reviewNotes.map((r: ReviewNote): ReviewNote => ReviewNote.from(r));
    }
    if (raw.user !== undefined && raw.user !== null) {
      s.user = User.from(raw.user);
    }
    s.serverTime = raw.serverTime ?? 0;
    return s;
  }
}

/** 头像上传结果 */
export class AvatarResult {
  url: string = '';

  static from(raw: AvatarResult): AvatarResult {
    const a = new AvatarResult();
    a.url = raw.url ?? '';
    return a;
  }
}

/* ---------- 请求 DTO ---------- */

export class LoginReq {
  username: string = '';
  password: string = '';
}

export class RegisterReq {
  username: string = '';
  password: string = '';
  nickname: string = '';
}

export class ChangePwdReq {
  oldPassword: string = '';
  newPassword: string = '';
}

export class SaveGoalReq {
  title: string = '';
  type: string = '习惯';
  category: string = '成长';
  priority: number = 2;
  startDate: string = '';
  endDate: string = '';
  description: string = '';
  remindOn: number = 0;
  remindTime: string = '19:00';
  archived: number = 0;
}

export class SaveTaskReq {
  goalId: number = 0;
  title: string = '';
  dueDate: string = '';
  dueTime: string = '';
  priority: number = 2;
  note: string = '';
  remindOn: number = 0;
  remindAdvance: number = 30;
}

export class SaveReviewReq {
  goalId: number = 0;
  content: string = '';
}

export class UpdateProfileReq {
  nickname: string = '';
  avatar: string = '';
}

export class UploadAvatarReq {
  imageBase64: string = '';
  filename: string = '';
}

/* ---------- 路由参数 ---------- */

export class GoalDetailParam {
  goalId: number = 0;

  constructor(goalId: number) {
    this.goalId = goalId;
  }
}

export class GoalFormParam {
  goalId: number = 0;

  constructor(goalId: number) {
    this.goalId = goalId;
  }
}

export class TaskFormParam {
  goalId: number = 0;
  taskId: number = 0;

  constructor(goalId: number, taskId: number) {
    this.goalId = goalId;
    this.taskId = taskId;
  }
}

export class ReviewParam {
  goalId: number = 0;

  constructor(goalId: number) {
    this.goalId = goalId;
  }
}
