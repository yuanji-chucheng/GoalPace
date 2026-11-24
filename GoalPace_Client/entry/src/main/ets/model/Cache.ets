import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { Goal, PointLog, ReviewNote, Task, User } from './Models';

/**
 * 本地缓存 / 离线镜像: relationalStore 五张缓存表(与 MySQL 同名同构)。
 * 红线: 缓存不得参与业务判定, 仅作离线展示镜像, 可随时由服务端 /sync 重建。
 */
export class Cache {
  private static rdb: relationalStore.RdbStore | null = null;

  private static readonly TABLES: Record<string, string[]> = {
    'users': ['id', 'username', 'nickname', 'avatar', 'points', 'level', 'checkin_days'],
    'goals': ['id', 'title', 'type', 'category', 'priority', 'start_date', 'end_date',
      'description', 'remind_on', 'remind_time', 'archived', 'progress', 'update_time'],
    'tasks': ['id', 'goal_id', 'title', 'due_date', 'due_time', 'priority', 'note',
      'remind_on', 'remind_advance', 'status', 'complete_time', 'update_time'],
    'point_logs': ['id', 'user_id', 'change', 'reason', 'task_id', 'create_time'],
    'review_notes': ['id', 'goal_id', 'content', 'create_time']
  };

  static async init(context: common.Context): Promise<void> {
    if (Cache.rdb !== null) {
      return;
    }
    const config: relationalStore.StoreConfig = {
      name: 'goalpace_cache.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    Cache.rdb = await relationalStore.getRdbStore(context, config);
    await Cache.exec('CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, username TEXT, '
      + 'nickname TEXT, avatar TEXT, points TEXT, level TEXT, checkin_days TEXT)');
    await Cache.exec('CREATE TABLE IF NOT EXISTS goals (id TEXT PRIMARY KEY, title TEXT, '
      + 'type TEXT, category TEXT, priority TEXT, start_date TEXT, end_date TEXT, '
      + 'description TEXT, remind_on TEXT, remind_time TEXT, archived TEXT, progress TEXT, '
      + 'update_time TEXT)');
    await Cache.exec('CREATE TABLE IF NOT EXISTS tasks (id TEXT PRIMARY KEY, goal_id TEXT, '
      + 'title TEXT, due_date TEXT, due_time TEXT, priority TEXT, note TEXT, remind_on TEXT, '
      + 'remind_advance TEXT, status TEXT, complete_time TEXT, update_time TEXT)');
    await Cache.exec('CREATE TABLE IF NOT EXISTS point_logs (id TEXT PRIMARY KEY, user_id TEXT, '
      + 'change TEXT, reason TEXT, task_id TEXT, create_time TEXT)');
    await Cache.exec('CREATE TABLE IF NOT EXISTS review_notes (id TEXT PRIMARY KEY, goal_id TEXT, '
      + 'content TEXT, create_time TEXT)');
  }

  private static async exec(sql: string, args: Array<string | null> | null = null): Promise<void> {
    const rdb = Cache.rdb;
    if (rdb === null) {
      return;
    }
    await rdb.executeSql(sql, args === null ? undefined : args);
  }

  private static async replaceTable(table: string, rows: Array<Array<string | null>>): Promise<void> {
    await Cache.exec('DELETE FROM ' + table);
    const cols = Cache.TABLES[table];
    const placeholders: string[] = [];
    for (let i = 0; i < cols.length; i++) {
      placeholders.push('?');
    }
    const sql = 'INSERT INTO ' + table + ' (' + cols.join(',') + ') VALUES ('
      + placeholders.join(',') + ')';
    for (const row of rows) {
      await Cache.exec(sql, row);
    }
  }

  private static async upsertRow(table: string, row: Array<string | null>): Promise<void> {
    const cols = Cache.TABLES[table];
    const placeholders: string[] = [];
    for (let i = 0; i < cols.length; i++) {
      placeholders.push('?');
    }
    await Cache.exec('INSERT OR REPLACE INTO ' + table + ' (' + cols.join(',') + ') VALUES ('
      + placeholders.join(',') + ')', row);
  }

  private static async queryRows(table: string): Promise<Array<Array<string | null>>> {
    const rdb = Cache.rdb;
    const rows: Array<Array<string | null>> = [];
    if (rdb === null) {
      return rows;
    }
    const cols = Cache.TABLES[table];
    const rs = await rdb.querySql('SELECT ' + cols.join(',') + ' FROM ' + table);
    while (rs.goToNextRow()) {
      const row: Array<string | null> = [];
      for (let i = 0; i < cols.length; i++) {
        if (rs.isColumnNull(i)) {
          row.push(null);
        } else {
          row.push(rs.getString(i));
        }
      }
      rows.push(row);
    }
    rs.close();
    return rows;
  }

  private static str(val: string | null): string {
    return val === null ? '' : val;
  }

  private static num(val: string | null): number {
    if (val === null || val === '') {
      return 0;
    }
    const n = Number(val);
    return Number.isNaN(n) ? 0 : n;
  }

  private static nvl(val: string): string | null {
    return val === '' ? null : val;
  }

  /* ---------- 写入(服务端响应成功后回刷) ---------- */

  static async saveUser(user: User): Promise<void> {
    await Cache.upsertRow('users', [user.id.toString(), user.username, user.nickname,
      user.avatar, user.points.toString(), user.level.toString(), user.checkinDays.toString()]);
  }

  static async saveGoals(list: Goal[]): Promise<void> {
    const rows: Array<Array<string | null>> = [];
    for (const g of list) {
      rows.push([g.id.toString(), g.title, g.type, g.category, g.priority.toString(),
        g.startDate, Cache.nvl(g.endDate), Cache.nvl(g.description), g.remindOn.toString(),
        g.remindTime, g.archived.toString(), g.progress.toString(), g.updateTime]);
    }
    await Cache.replaceTable('goals', rows);
  }

  static async saveTasks(list: Task[]): Promise<void> {
    const rows: Array<Array<string | null>> = [];
    for (const t of list) {
      rows.push([t.id.toString(), t.goalId.toString(), t.title, Cache.nvl(t.dueDate),
        Cache.nvl(t.dueTime), t.priority.toString(), Cache.nvl(t.note), t.remindOn.toString(),
        t.remindAdvance.toString(), t.status.toString(), Cache.nvl(t.completeTime), t.updateTime]);
    }
    await Cache.replaceTable('tasks', rows);
  }

  static async savePointLogs(list: PointLog[]): Promise<void> {
    const rows: Array<Array<string | null>> = [];
    for (const p of list) {
      rows.push([p.id.toString(), '', p.change.toString(), p.reason,
        p.taskId > 0 ? p.taskId.toString() : null, p.createTime]);
    }
    await Cache.replaceTable('point_logs', rows);
  }

  static async saveReviews(list: ReviewNote[]): Promise<void> {
    const rows: Array<Array<string | null>> = [];
    for (const r of list) {
      rows.push([r.id.toString(), r.goalId.toString(), r.content, r.createTime]);
    }
    await Cache.replaceTable('review_notes', rows);
  }

  /* ---------- 离线镜像读取(仅网络失败兜底展示) ---------- */

  static async getGoals(): Promise<Goal[]> {
    const rows = await Cache.queryRows('goals');
    return rows.map((row: Array<string | null>): Goal => {
      const g = new Goal();
      g.id = Cache.num(row[0]);
      g.title = Cache.str(row[1]);
      g.type = Cache.str(row[2]);
      g.category = Cache.str(row[3]);
      g.priority = Cache.num(row[4]);
      g.startDate = Cache.str(row[5]);
      g.endDate = Cache.str(row[6]);
      g.description = Cache.str(row[7]);
      g.remindOn = Cache.num(row[8]);
      g.remindTime = Cache.str(row[9]);
      g.archived = Cache.num(row[10]);
      g.progress = Cache.num(row[11]);
      g.updateTime = Cache.str(row[12]);
      return g;
    });
  }

  static async getTasks(): Promise<Task[]> {
    const rows = await Cache.queryRows('tasks');
    return rows.map((row: Array<string | null>): Task => {
      const t = new Task();
      t.id = Cache.num(row[0]);
      t.goalId = Cache.num(row[1]);
      t.title = Cache.str(row[2]);
      t.dueDate = Cache.str(row[3]);
      t.dueTime = Cache.str(row[4]);
      t.priority = Cache.num(row[5]);
      t.note = Cache.str(row[6]);
      t.remindOn = Cache.num(row[7]);
      t.remindAdvance = Cache.num(row[8]);
      t.status = Cache.num(row[9]);
      t.completeTime = Cache.str(row[10]);
      t.updateTime = Cache.str(row[11]);
      return t;
    });
  }

  static async getPointLogs(): Promise<PointLog[]> {
    const rows = await Cache.queryRows('point_logs');
    return rows.map((row: Array<string | null>): PointLog => {
      const p = new PointLog();
      p.id = Cache.num(row[0]);
      p.change = Cache.num(row[2]);
      p.reason = Cache.str(row[3]);
      p.taskId = Cache.num(row[4]);
      p.createTime = Cache.str(row[5]);
      return p;
    });
  }

  static async getReviews(): Promise<ReviewNote[]> {
    const rows = await Cache.queryRows('review_notes');
    return rows.map((row: Array<string | null>): ReviewNote => {
      const r = new ReviewNote();
      r.id = Cache.num(row[0]);
      r.goalId = Cache.num(row[1]);
      r.content = Cache.str(row[2]);
      r.createTime = Cache.str(row[3]);
      return r;
    });
  }

  /** 退出登录 / 重建缓存时清空 */
  static async clearAll(): Promise<void> {
    await Cache.exec('DELETE FROM users');
    await Cache.exec('DELETE FROM goals');
    await Cache.exec('DELETE FROM tasks');
    await Cache.exec('DELETE FROM point_logs');
    await Cache.exec('DELETE FROM review_notes');
  }
}
