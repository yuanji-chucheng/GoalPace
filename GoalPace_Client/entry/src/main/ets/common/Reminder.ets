import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { Prefs } from '../model/Prefs';
import { Task } from '../model/Models';

/**
 * 提醒服务: @ohos.reminderAgentManager 后台代理提醒
 * (任务到期提醒 + 每日 19:00 打卡提醒)
 */
export class Reminder {
  private static readonly CHECKIN_ID_KEY: string = 'checkinReminderId';

  /**
   * 每日 19:00 打卡提醒
   */
  static async publishDailyCheckin(on: boolean): Promise<void> {
    try {
      await Reminder.cancelDailyCheckin();
      if (!on) {
        return;
      }
      const reminder: reminderAgentManager.ReminderRequestAlarm = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
        hour: 19,
        minute: 0,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        title: '拾阶 · 每日打卡',
        content: '今天还没打卡，去完成今日任务拾级而上吧',
        expiredContent: '今日打卡提醒已结束',
        notificationId: 1001,
        slotType: notificationManager.SlotType.CONTENT_INFORMATION
      };
      const id = await reminderAgentManager.publishReminder(reminder);
      await Reminder.saveId(Reminder.CHECKIN_ID_KEY, id);
    } catch (error) {
      // 提醒失败不阻断主流程
    }
  }

  static async cancelDailyCheckin(): Promise<void> {
    try {
      const id = await Reminder.loadId(Reminder.CHECKIN_ID_KEY);
      if (id > 0) {
        await reminderAgentManager.cancelReminder(id);
      }
      await Reminder.saveId(Reminder.CHECKIN_ID_KEY, 0);
    } catch (error) {
      // 忽略
    }
  }

  /**
   * 任务到期提醒: 到期时间前 remindAdvance 分钟触发
   */
  static async publishTaskReminder(task: Task): Promise<void> {
    try {
      if (task.remindOn !== 1 || task.dueDate === '') {
        return;
      }
      const parts = task.dueDate.split('-');
      const timeParts = task.dueTime === '' ? ['9', '0'] : task.dueTime.split(':');
      const fire = new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]),
        Number(timeParts[0]), Number(timeParts[1]));
      fire.setMinutes(fire.getMinutes() - task.remindAdvance);
      if (fire.getTime() <= Date.now()) {
        return;
      }
      const reminder: reminderAgentManager.ReminderRequestCalendar = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_CALENDAR,
        dateTime: {
          year: fire.getFullYear(),
          month: fire.getMonth() + 1,
          day: fire.getDate(),
          hour: fire.getHours(),
          minute: fire.getMinutes()
        },
        title: '拾阶 · 任务提醒',
        content: '「' + task.title + '」即将到期',
        expiredContent: '任务提醒已结束',
        notificationId: 1002 + (task.id % 1000),
        slotType: notificationManager.SlotType.CONTENT_INFORMATION
      };
      await reminderAgentManager.publishReminder(reminder);
    } catch (error) {
      // 提醒失败不阻断主流程
    }
  }

  /**
   * 提醒偏好开关(S8)
   */
  static async setRemindPref(on: boolean): Promise<void> {
    await Prefs.setRemindOn(on);
    await Reminder.publishDailyCheckin(on);
  }

  private static async saveId(key: string, id: number): Promise<void> {
    await Prefs.setExtra(key, id.toString());
  }

  private static async loadId(key: string): Promise<number> {
    const text = await Prefs.getExtra(key, '0');
    const id = Number(text);
    return Number.isNaN(id) ? 0 : id;
  }
}
