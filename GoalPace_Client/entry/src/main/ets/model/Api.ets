import { Http } from './Http';
import {
  AvatarResult, ChangePwdReq, DailyCount, Goal, GoalProgress, LoginReq, LoginResult,
  PointLog, RegisterReq, ReviewNote, RuleItem, SaveGoalReq, SaveReviewReq, SaveTaskReq,
  StatsData, SyncPayload, Task, ToggleResult, UpdateProfileReq, UploadAvatarReq, User
} from './Models';

/**
 * 接口层: 与服务端 /api 一一对应
 */
export class AuthApi {
  static async login(req: LoginReq): Promise<LoginResult> {
    const raw = await Http.post<LoginResult>('/api/auth/login', req);
    return LoginResult.from(raw);
  }

  static async register(req: RegisterReq): Promise<void> {
    await Http.postVoid('/api/auth/register', req);
  }

  static async changePassword(req: ChangePwdReq): Promise<void> {
    await Http.putVoid('/api/auth/password', req);
  }
}

export class UserApi {
  static async profile(): Promise<User> {
    const raw = await Http.get<User>('/api/users/profile');
    return User.from(raw);
  }

  static async updateProfile(req: UpdateProfileReq): Promise<User> {
    const raw = await Http.put<User>('/api/users/profile', req);
    return User.from(raw);
  }

  static async uploadAvatar(req: UploadAvatarReq): Promise<AvatarResult> {
    const raw = await Http.post<AvatarResult>('/api/users/avatar', req);
    return AvatarResult.from(raw);
  }
}

export class GoalApi {
  static async list(): Promise<Goal[]> {
    const raw = await Http.get<Goal[]>('/api/goals');
    return raw.map((g: Goal): Goal => Goal.from(g));
  }

  static async archivedList(): Promise<Goal[]> {
    const raw = await Http.get<Goal[]>('/api/goals/archived');
    return raw.map((g: Goal): Goal => Goal.from(g));
  }

  static async get(id: number): Promise<Goal> {
    const raw = await Http.get<Goal>('/api/goals/' + id.toString());
    return Goal.from(raw);
  }

  static async create(req: SaveGoalReq): Promise<Goal> {
    const raw = await Http.post<Goal>('/api/goals', req);
    return Goal.from(raw);
  }

  static async update(id: number, req: SaveGoalReq): Promise<Goal> {
    const raw = await Http.put<Goal>('/api/goals/' + id.toString(), req);
    return Goal.from(raw);
  }

  static async setArchived(id: number, archived: boolean): Promise<Goal> {
    const raw = await Http.put<Goal>('/api/goals/' + id.toString() + '/archive?archived='
      + (archived ? 'true' : 'false'), null);
    return Goal.from(raw);
  }

  static async remove(id: number): Promise<void> {
    await Http.delVoid('/api/goals/' + id.toString());
  }
}

export class TaskApi {
  static async list(goalId: number, status: number, priority: number): Promise<Task[]> {
    const query: string[] = [];
    if (goalId > 0) {
      query.push('goalId=' + goalId.toString());
    }
    if (status >= 0) {
      query.push('status=' + status.toString());
    }
    if (priority > 0) {
      query.push('priority=' + priority.toString());
    }
    const suffix = query.length > 0 ? '?' + query.join('&') : '';
    const raw = await Http.get<Task[]>('/api/tasks' + suffix);
    return raw.map((t: Task): Task => Task.from(t));
  }

  static async today(): Promise<Task[]> {
    const raw = await Http.get<Task[]>('/api/tasks/today');
    return raw.map((t: Task): Task => Task.from(t));
  }

  static async create(req: SaveTaskReq): Promise<Task> {
    const raw = await Http.post<Task>('/api/tasks', req);
    return Task.from(raw);
  }

  static async update(id: number, req: SaveTaskReq): Promise<Task> {
    const raw = await Http.put<Task>('/api/tasks/' + id.toString(), req);
    return Task.from(raw);
  }

  static async toggle(id: number): Promise<ToggleResult> {
    const raw = await Http.put<ToggleResult>('/api/tasks/' + id.toString() + '/toggle', null);
    return ToggleResult.from(raw);
  }

  static async remove(id: number): Promise<void> {
    await Http.delVoid('/api/tasks/' + id.toString());
  }
}

export class ReviewApi {
  static async list(goalId: number): Promise<ReviewNote[]> {
    const suffix = goalId > 0 ? '?goalId=' + goalId.toString() : '';
    const raw = await Http.get<ReviewNote[]>('/api/reviews' + suffix);
    return raw.map((r: ReviewNote): ReviewNote => ReviewNote.from(r));
  }

  static async create(req: SaveReviewReq): Promise<ReviewNote> {
    const raw = await Http.post<ReviewNote>('/api/reviews', req);
    return ReviewNote.from(raw);
  }
}

export class StatsApi {
  static async stats(period: string): Promise<StatsData> {
    const raw = await Http.get<StatsData>('/api/stats?period=' + period);
    return StatsData.from(raw);
  }
}

export class PointApi {
  static async rules(): Promise<RuleItem[]> {
    const raw = await Http.get<RuleItem[]>('/api/points/rules');
    return raw.map((r: RuleItem): RuleItem => RuleItem.from(r));
  }

  static async logs(): Promise<PointLog[]> {
    const raw = await Http.get<PointLog[]>('/api/points/logs');
    return raw.map((p: PointLog): PointLog => PointLog.from(p));
  }
}

export class SyncApi {
  static async sync(since: number): Promise<SyncPayload> {
    const raw = await Http.get<SyncPayload>('/api/sync?since=' + since.toString());
    return SyncPayload.from(raw);
  }

  static async exportAll(): Promise<SyncPayload> {
    const raw = await Http.get<SyncPayload>('/api/export');
    return SyncPayload.from(raw);
  }
}
