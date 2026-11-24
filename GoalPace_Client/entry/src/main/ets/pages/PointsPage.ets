import { LengthMetrics } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Fmt } from '../common/Fmt';
import { PointsVm } from '../viewmodel/MiscVms';
import { AppSession } from '../viewmodel/Session';
import { PointLog, RuleItem } from '../model/Models';
import { NavHeader } from '../components/Widgets';

/** 热力图单格 */
class DayCell {
  date: string = '';
  value: number = 0;

  constructor(date: string, value: number) {
    this.date = date;
    this.value = value;
  }
}

/**
 * S10 积分激励: 等级台阶 + 规则表 + 12周热力图 + 徽章墙 + 积分明细
 */
@ComponentV2
export struct PointsPage {
  navPathStack: NavPathStack = new NavPathStack();
  @Local vm: PointsVm = new PointsVm();
  @Local session: AppSession = AppSession.inst;

  build() {
    NavDestination() {
      Column() {
        NavHeader({ stack: this.navPathStack, headerTitle: '积分与徽章' })
        if (this.vm.loading) {
          Column() {
            LoadingProgress()
              .width(34)
              .height(34)
              .color(Theme.PRIMARY)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: 12 }) {
              if (this.vm.offline) {
                Text('离线镜像展示，数据可能不是最新')
                  .fontSize(11)
                  .fontColor(Theme.DANGER)
              }
              this.LevelCard()
              this.RulesCard()
              this.HeatmapCard()
              this.BadgesCard()
              this.LogsCard()
            }
            .width('100%')
            .padding({ left: 18, right: 18, top: 14, bottom: 40 })
            .alignItems(HorizontalAlign.Start)
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .width('100%')
        }
      }
      .width('100%')
      .height('100%')
    }
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      this.vm.refresh();
    })
    .backgroundColor(Theme.BG)
  }

  @Builder
  LevelCard() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Column() {
          Text('Lv.' + this.session.user.level.toString())
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(58)
        .height(58)
        .borderRadius(18)
        .backgroundColor(Theme.PRIMARY)
        .justifyContent(FlexAlign.Center)

        Column({ space: 5 }) {
          Text(this.session.user.points.toString() + ' 分')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Text('当前等级 Lv.' + this.session.user.level.toString()
            + ' · 连续打卡 ' + this.session.user.checkinDays.toString() + ' 天')
            .fontSize(12)
            .fontColor(Theme.TEXT_LIGHT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: 12 }) {
        this.LevelStep(this.session.user.level - 1)
        this.LevelStep(this.session.user.level)
        this.LevelStep(this.session.user.level + 1)
        this.LevelStep(this.session.user.level + 2)
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)

      Text('距下一级还差 ' + this.nextLevelGap().toString() + ' 分，每满 100 分升一级')
        .fontSize(11)
        .fontColor(Theme.TEXT_LIGHT)
    }
    .width('100%')
    .padding(16)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  LevelStep(level: number) {
    Column({ space: 4 }) {
      Text('Lv.' + level.toString())
        .fontSize(11)
        .fontWeight(level === this.session.user.level ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(level === this.session.user.level ? Theme.PRIMARY_DEEP : Theme.TEXT_LIGHT)
      Column()
        .width('100%')
        .height(10 + level * 8)
        .borderRadius(6)
        .backgroundColor(level === this.session.user.level ? Theme.PRIMARY
          : (level < this.session.user.level ? Theme.PRIMARY_SOFT : Theme.TRACK))
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.End)
  }

  @Builder
  RulesCard() {
    Column({ space: 10 }) {
      Text('积分规则')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT)
      if (this.vm.rules.length === 0) {
        ForEach(PointsVm.DEFAULT_RULES, (row: string[]) => {
          Row() {
            Text(row[0])
              .fontSize(13)
              .fontColor(Theme.TEXT)
              .layoutWeight(1)
            Text(row[1])
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.PRIMARY_DEEP)
          }
          .width('100%')
        }, (row: string[], idx: number) => row[0] + '_' + idx.toString())
      }
      ForEach(this.vm.rules, (rule: RuleItem) => {
        Row() {
          Text(rule.name)
            .fontSize(13)
            .fontColor(Theme.TEXT)
            .layoutWeight(1)
          Text('+' + rule.points.toString())
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.PRIMARY_DEEP)
        }
        .width('100%')
      }, (rule: RuleItem) => rule.name + '_' + rule.points.toString())
      Text('积分只累计与展示，不支持兑换或消费')
        .fontSize(11)
        .fontColor(Theme.TEXT_LIGHT)
        .opacity(0.8)
    }
    .width('100%')
    .padding(15)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  HeatmapCard() {
    Column({ space: 10 }) {
      Row() {
        Text('近 12 周活跃热力图')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.TEXT)
          .layoutWeight(1)
        Row({ space: 4 }) {
          Text('少')
            .fontSize(9)
            .fontColor(Theme.TEXT_LIGHT)
          Column().width(9).height(9).borderRadius(2).backgroundColor(Theme.TRACK)
          Column().width(9).height(9).borderRadius(2).backgroundColor('rgba(107,168,160,0.35)')
          Column().width(9).height(9).borderRadius(2).backgroundColor('rgba(107,168,160,0.65)')
          Column().width(9).height(9).borderRadius(2).backgroundColor(Theme.PRIMARY)
          Text('多')
            .fontSize(9)
            .fontColor(Theme.TEXT_LIGHT)
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')

      Row({ space: 4 }) {
        ForEach(this.heatWeeks(), (week: DayCell[]) => {
          Column({ space: 4 }) {
            ForEach(week, (cell: DayCell) => {
              Column()
                .width(13)
                .height(13)
                .borderRadius(3)
                .backgroundColor(this.heatColor(cell.value))
            }, (cell: DayCell) => cell.date)
          }
        }, (week: DayCell[], idx: number) => 'w' + idx.toString())
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .padding(15)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  BadgesCard() {
    Column({ space: 10 }) {
      Text('徽章墙')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT)
      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) {
        ForEach(this.vm.badges(), (badge: string[]) => {
          Column({ space: 6 }) {
            Text(badge[0])
              .fontSize(26)
            Text(badge[1])
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.TEXT)
            Text(badge[2])
              .fontSize(11)
              .fontColor(badge[2] === '已获得' ? Theme.PRIMARY_DEEP : Theme.TEXT_LIGHT)
          }
          .width('47%')
          .padding({ top: 14, bottom: 14 })
          .borderRadius(Theme.RADIUS_SM)
          .backgroundColor(badge[2] === '已获得' ? Theme.PRIMARY_SOFT : Theme.BG)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }, (badge: string[], idx: number) => badge[1] + '_' + idx.toString())
      }
      .width('100%')
    }
    .width('100%')
    .padding(15)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  LogsCard() {
    Column({ space: 10 }) {
      Text('积分明细')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT)
      if (this.vm.logs.length === 0) {
        Text('暂无积分记录，完成第一个任务获得 +10')
          .fontSize(12)
          .fontColor(Theme.TEXT_LIGHT)
      }
      ForEach(this.vm.logs, (log: PointLog) => {
        Row({ space: 10 }) {
          Column() {
            Text(log.change >= 0 ? '+' + log.change.toString() : log.change.toString())
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(log.change >= 0 ? Theme.PRIMARY_DEEP : Theme.DANGER)
          }
          .width(52)
          .alignItems(HorizontalAlign.Center)

          Column({ space: 3 }) {
            Text(log.reason)
              .fontSize(13)
              .fontColor(Theme.TEXT)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(log.createTime.length >= 16 ? log.createTime.substring(0, 16) : log.createTime)
              .fontSize(11)
              .fontColor(Theme.TEXT_LIGHT)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }, (log: PointLog) => log.id.toString())
    }
    .width('100%')
    .padding(15)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }

  private nextLevelGap(): number {
    const gap = this.session.user.level * 100 - this.session.user.points;
    return gap < 0 ? 0 : gap;
  }

  private heatWeeks(): DayCell[][] {
    const map = this.vm.heatmap();
    const weeks: DayCell[][] = [];
    const today = new Date();
    for (let w = 0; w < 12; w++) {
      const column: DayCell[] = [];
      for (let d = 0; d < 7; d++) {
        const offset = 83 - ((11 - w) * 7 + (6 - d));
        const day = new Date(today.getFullYear(), today.getMonth(), today.getDate() - offset);
        const key = Fmt.dateString(day);
        const value = map.get(key);
        column.push(new DayCell(key, value === undefined ? 0 : value));
      }
      weeks.push(column);
    }
    return weeks;
  }

  private heatColor(value: number): string {
    if (value <= 0) {
      return Theme.TRACK;
    }
    if (value < 15) {
      return 'rgba(107,168,160,0.35)';
    }
    if (value < 30) {
      return 'rgba(107,168,160,0.65)';
    }
    return Theme.PRIMARY;
  }
}

@Builder
export function PointsBuilder() {
  PointsPage()
}
