import { Cache } from '../model/Cache';
import { Prefs } from '../model/Prefs';
import { UserApi } from '../model/Api';
import { User } from '../model/Models';
import { Reminder } from '../common/Reminder';

/**
 * 全局会话: @ObservedV2 单例, 持有登录态与用户信息
 */
@ObservedV2
export class AppSession {
  private static sole: AppSession | null = null;

  static get inst(): AppSession {
    if (AppSession.sole === null) {
      AppSession.sole = new AppSession();
    }
    return AppSession.sole;
  }

  @Trace booted: boolean = false;
  @Trace logged: boolean = false;
  @Trace user: User = new User();

  private constructor() {
  }

  /**
   * 启动: 依据本地登录态拉取服务端用户信息(登录必须由服务端校验)
   */
  async boot(): Promise<void> {
    const token = await Prefs.getToken();
    if (token === '') {
      this.logged = false;
      this.booted = true;
      return;
    }
    try {
      const user = await UserApi.profile();
      this.applyUser(user);
      this.logged = true;
      await Cache.saveUser(user);
    } catch (error) {
      this.logged = false;
    }
    this.booted = true;
  }

  applyUser(user: User): void {
    this.user = user;
  }

  /**
   * 登录成功: 保存会话态并刷新每日打卡提醒
   */
  async onLoginSuccess(token: string, user: User): Promise<void> {
    await Prefs.setLogin(token, user.id.toString());
    this.applyUser(user);
    this.logged = true;
    await Cache.saveUser(user);
    const remindOn = await Prefs.getRemindOn();
    await Reminder.publishDailyCheckin(remindOn);
  }

  /**
   * 退出登录 / 改密成功: 清理登录态与本地缓存, 取消提醒
   */
  async logout(): Promise<void> {
    await Reminder.cancelDailyCheckin();
    await Prefs.clearLogin();
    await Cache.clearAll();
    this.logged = false;
    this.user = new User();
  }
}
