import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * 偏好存储: 仅存登录态、userId 与提醒偏好, 不参与业务判定
 */
export class Prefs {
  private static store: preferences.Preferences | null = null;

  static async init(context: common.Context): Promise<void> {
    if (Prefs.store === null) {
      Prefs.store = await preferences.getPreferences(context, 'goalpace_prefs');
    }
  }

  private static async get(key: string, def: string): Promise<string> {
    const store = Prefs.store;
    if (store === null) {
      return def;
    }
    const val = await store.get(key, def);
    if (typeof val === 'string') {
      return val;
    }
    return def;
  }

  private static async put(key: string, val: string): Promise<void> {
    const store = Prefs.store;
    if (store === null) {
      return;
    }
    await store.put(key, val);
    await store.flush();
  }

  static async getToken(): Promise<string> {
    return Prefs.get('token', '');
  }

  static async getUserId(): Promise<string> {
    return Prefs.get('userId', '');
  }

  static async setLogin(token: string, userId: string): Promise<void> {
    await Prefs.put('token', token);
    await Prefs.put('userId', userId);
  }

  static async getLastSync(): Promise<number> {
    const text = await Prefs.get('lastSync', '0');
    const num = Number(text);
    return Number.isNaN(num) ? 0 : num;
  }

  static async setLastSync(val: number): Promise<void> {
    await Prefs.put('lastSync', val.toString());
  }

  static async getRemindOn(): Promise<boolean> {
    return (await Prefs.get('remindOn', '1')) === '1';
  }

  static async setRemindOn(on: boolean): Promise<void> {
    await Prefs.put('remindOn', on ? '1' : '0');
  }

  static async clearLogin(): Promise<void> {
    await Prefs.put('token', '');
    await Prefs.put('userId', '');
    await Prefs.put('lastSync', '0');
  }

  /** 扩展键值(提醒 ID 等非业务偏好) */
  static async getExtra(key: string, def: string): Promise<string> {
    return Prefs.get(key, def);
  }

  static async setExtra(key: string, val: string): Promise<void> {
    await Prefs.put(key, val);
  }
}
