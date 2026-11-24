export class Theme {
  /** 暖米底 */
  static readonly BG: string = '#F8F6F2';
  /** 白卡 */
  static readonly CARD: string = '#FFFFFF';
  /** 输入底 */
  static readonly INPUT_BG: string = '#FFFFFF';
  /** 主色 鼠尾草青 */
  static readonly PRIMARY: string = '#6BA8A0';
  /** 深青 */
  static readonly PRIMARY_DEEP: string = '#3F7570';
  /** 主色浅底 */
  static readonly PRIMARY_SOFT: string = '#E7F1EF';
  /** 主文本 */
  static readonly TEXT: string = '#31403E';
  /** 次要文本 */
  static readonly TEXT_LIGHT: string = '#8B9794';
  /** 分隔线 */
  static readonly DIVIDER: string = '#ECE8E0';
  /** 高优先级 红 */
  static readonly PRIORITY_HIGH: string = '#D96A5F';
  /** 中优先级 黄 */
  static readonly PRIORITY_MID: string = '#D9A13B';
  /** 低优先级 灰 */
  static readonly PRIORITY_LOW: string = '#9AA5A3';
  /** 危险/删除 */
  static readonly DANGER: string = '#C75B50';
  /** 进度条轨道 */
  static readonly TRACK: string = '#EFECE5';
  /** 白卡圆角 16px */
  static readonly RADIUS: number = 16;
  static readonly RADIUS_SM: number = 10;
  static readonly FONT_TITLE: number = 20;
  static readonly FONT_BODY: number = 15;
  static readonly FONT_CAPTION: number = 12;

  static priorityColor(priority: number): string {
    if (priority === 3) {
      return Theme.PRIORITY_HIGH;
    }
    if (priority === 2) {
      return Theme.PRIORITY_MID;
    }
    return Theme.PRIORITY_LOW;
  }

  static priorityLabel(priority: number): string {
    if (priority === 3) {
      return '高';
    }
    if (priority === 2) {
      return '中';
    }
    return '低';
  }
}
