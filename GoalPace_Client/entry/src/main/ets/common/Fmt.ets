/**
 * 日期工具: 全站日期格式统一 YYYY-MM-DD
 */
export class Fmt {
  static today(): string {
    return Fmt.dateString(new Date());
  }

  static dateString(d: Date): string {
    const y = d.getFullYear();
    const m = d.getMonth() + 1;
    const day = d.getDate();
    return y.toString() + '-' + (m < 10 ? '0' + m.toString() : m.toString())
      + '-' + (day < 10 ? '0' + day.toString() : day.toString());
  }

  static timeString(d: Date): string {
    const h = d.getHours();
    const m = d.getMinutes();
    return (h < 10 ? '0' + h.toString() : h.toString()) + ':'
      + (m < 10 ? '0' + m.toString() : m.toString());
  }

  static parseDate(text: string): Date {
    if (text === '') {
      return new Date();
    }
    const parts = text.split('-');
    if (parts.length === 3) {
      const y = Number(parts[0]);
      const m = Number(parts[1]);
      const d = Number(parts[2]);
      if (!Number.isNaN(y) && !Number.isNaN(m) && !Number.isNaN(d)) {
        return new Date(y, m - 1, d);
      }
    }
    return new Date();
  }

  static parseTime(text: string): Date {
    const d = new Date();
    if (text !== '') {
      const parts = text.split(':');
      if (parts.length === 2) {
        d.setHours(Number(parts[0]));
        d.setMinutes(Number(parts[1]));
      }
    }
    return d;
  }

  static shortDate(text: string): string {
    if (text.length >= 10) {
      return text.substring(5, 10).replace('-', '月') + '日';
    }
    return text;
  }

  static weekdayLabel(d: Date): string {
    const names: string[] = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return names[d.getDay()];
  }

  static greeting(): string {
    const h = new Date().getHours();
    if (h < 6) {
      return '夜深了';
    }
    if (h < 11) {
      return '早上好';
    }
    if (h < 14) {
      return '中午好';
    }
    if (h < 18) {
      return '下午好';
    }
    return '晚上好';
  }
}
