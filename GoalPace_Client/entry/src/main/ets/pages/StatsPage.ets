import { Theme } from '../common/Theme';
import { Bus } from '../common/Bus';
import { StatsVm } from '../viewmodel/MiscVms';
import { DailyCount, GoalProgress } from '../model/Models';
import { ChipRow, EmptyView, ProgressTrack } from '../components/Widgets';

/**
 * S7 统计: 本周/本月 完成概览 + 每日完成柱状图 + 目标进度榜
 */
@ComponentV2
export struct StatsPage {
  @Param navStack: NavPathStack = new NavPathStack();
  @Local vm: StatsVm = new StatsVm();
  @Local bus: Bus = Bus.inst;

  aboutToAppear(): void {
    this.vm.refresh();
  }

  @Monitor('bus.tasksTick', 'bus.goalsTick')
  onDataTick(): void {
    this.vm.refresh();
  }

  build() {
    Column() {
      this.HeaderBar()
      ChipRow({
        labels: ['本周', '本月'],
        selected: this.vm.period === 'week' ? 0 : 1,
        onChipSelect: (index: number) => {
          this.vm.setPeriod(index === 0 ? 'week' : 'month');
        }
      })
      .padding({ left: 18, right: 18 })

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
              Text('网络不可用，暂无法获取统计数据')
                .fontSize(11)
                .fontColor(Theme.DANGER)
                .alignSelf(ItemAlign.Start)
            }
            this.SummaryGrid()
            this.BarChartCard()
            this.ProgressRankCard()
          }
          .width('100%')
          .padding({ left: 18, right: 18, top: 14, bottom: 130 })
          .alignItems(HorizontalAlign.Start)
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  HeaderBar() {
    Row() {
      Column({ space: 3 }) {
        Text('统计')
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT)
        Text('用数据看见自己的拾阶轨迹')
          .fontSize(12)
          .fontColor(Theme.TEXT_LIGHT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 12 })
  }

  @Builder
  SummaryGrid() {
    Row() {
      this.SummaryCell('完成任务', this.vm.data.taskDone.toString(), '个')
      this.SummaryCell('获得积分', this.vm.data.pointsGained.toString(), '分')
      this.SummaryCell('坚持打卡', this.vm.data.checkinDays.toString(), '天')
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
  }

  @Builder
  SummaryCell(label: string, value: string, unit: string) {
    Column({ space: 5 }) {
      Text() {
        Span(value)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.PRIMARY_DEEP)
        Span(' ' + unit)
          .fontSize(11)
          .fontColor(Theme.TEXT_LIGHT)
      }
      Text(label)
        .fontSize(12)
        .fontColor(Theme.TEXT_LIGHT)
    }
    .layoutWeight(1)
  }

  @Builder
  BarChartCard() {
    Column({ space: 12 }) {
      Row() {
        Text('每日完成')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.TEXT)
          .layoutWeight(1)
        Text(this.vm.data.startDate + ' ~ ' + this.vm.data.endDate)
          .fontSize(11)
          .fontColor(Theme.TEXT_LIGHT)
      }
      .width('100%')

      if (this.vm.data.dailyCounts.length === 0) {
        EmptyView({ emptyTitle: '暂无完成记录', emptyHint: '完成今日任务后可见' })
      } else {
        Scroll() {
          Row({ space: 6 }) {
            ForEach(this.vm.data.dailyCounts, (d: DailyCount) => {
              this.BarItem(d)
            }, (d: DailyCount) => d.date)
          }
          .padding({ bottom: 2 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
    }
    .width('100%')
    .padding(15)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  BarItem(d: DailyCount) {
    Column({ space: 5 }) {
      if (d.done > 0) {
        Text(d.done.toString())
          .fontSize(9)
          .fontColor(Theme.PRIMARY_DEEP)
      } else {
        Text(' ')
          .fontSize(9)
      }
      Column()
        .width(14)
        .height(this.barHeight(d.done))
        .backgroundColor(d.done > 0 ? Theme.PRIMARY : Theme.TRACK)
        .borderRadius(4)
      Text(d.date.length >= 10 ? d.date.substring(8, 10) : d.date)
        .fontSize(9)
        .fontColor(Theme.TEXT_LIGHT)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.End)
  }

  private barHeight(done: number): number {
    const max = this.vm.maxDaily();
    if (max <= 0 || done <= 0) {
      return 5;
    }
    return Math.max(6, Math.round(done / max * 88));
  }

  @Builder
  ProgressRankCard() {
    Column({ space: 12 }) {
      Text('目标进度榜')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT)
      if (this.vm.data.goalProgress.length === 0) {
        Text('暂无进行中的目标')
          .fontSize(12)
          .fontColor(Theme.TEXT_LIGHT)
      }
      ForEach(this.vm.data.goalProgress, (item: GoalProgress) => {
        Column({ space: 6 }) {
          Row() {
            Text(item.title)
              .fontSize(13)
              .fontColor(Theme.TEXT)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
            Text(item.progress.toString() + '%')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.PRIMARY_DEEP)
          }
          .width('100%')
          ProgressTrack({ percent: item.progress })
          Text(item.taskDone.toString() + '/' + item.taskTotal.toString() + ' 个任务')
            .fontSize(10)
            .fontColor(Theme.TEXT_LIGHT)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }, (item: GoalProgress) => item.goalId.toString())
    }
    .width('100%')
    .padding(15)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }
}
