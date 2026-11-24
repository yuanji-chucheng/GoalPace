import { Theme } from '../common/Theme';
import { Bus } from '../common/Bus';
import { GoalsVm } from '../viewmodel/GoalVms';
import { Goal, GoalDetailParam, GoalFormParam } from '../model/Models';
import { ChipRow, EmptyView, PriorityTag, ProgressTrack } from '../components/Widgets';

/**
 * S3 目标列表: 全部/进行中/已达成/已归档 筛选, 卡片点击进入 S4 详情
 */
@ComponentV2
export struct GoalsPage {
  @Param navStack: NavPathStack = new NavPathStack();
  @Local vm: GoalsVm = new GoalsVm();
  @Local bus: Bus = Bus.inst;

  aboutToAppear(): void {
    this.vm.refresh();
  }

  @Monitor('bus.goalsTick')
  onGoalsTick(): void {
    this.vm.refresh();
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        this.HeaderBar()
        ChipRow({
          labels: ['全部', '进行中', '已达成', '已归档'],
          selected: this.vm.chipIdx,
          onChipSelect: (index: number) => {
            this.vm.chipIdx = index;
            this.vm.refresh();
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
                Text('离线镜像展示，数据可能不是最新')
                  .fontSize(11)
                  .fontColor(Theme.DANGER)
                  .alignSelf(ItemAlign.Start)
              }
              if (this.vm.displayed().length === 0) {
                EmptyView({
                  emptyIcon: '⛰',
                  emptyTitle: this.vm.chipIdx === 3 ? '暂无已归档目标' : '还没有目标',
                  emptyHint: this.vm.chipIdx === 3 ? '' : '点击右下角 + 创建第一个目标，拾级而上'
                })
              }
              ForEach(this.vm.displayed(), (goal: Goal) => {
                this.GoalCard(goal)
              }, (goal: Goal) => goal.id.toString())
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

      Button('＋')
        .fontSize(24)
        .fontColor(Color.White)
        .width(52)
        .height(52)
        .borderRadius(26)
        .backgroundColor(Theme.PRIMARY)
        .shadow({ radius: 14, color: 'rgba(63,117,112,0.35)', offsetY: 4 })
        .margin({ bottom: 92, right: 18 })
        .onClick(() => {
          this.navStack.pushPathByName('goalForm', new GoalFormParam(0));
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  HeaderBar() {
    Row() {
      Column({ space: 3 }) {
        Text('我的目标')
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT)
        Text('把大目标拆成小台阶')
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
  GoalCard(goal: Goal) {
    Column({ space: 11 }) {
      Row({ space: 10 }) {
        Column({ space: 5 }) {
          Text(goal.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.TEXT)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Row({ space: 6 }) {
            Text(goal.type)
              .fontSize(11)
              .fontColor(Theme.PRIMARY_DEEP)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(Theme.PRIMARY_SOFT)
              .borderRadius(8)
            Text(goal.category)
              .fontSize(11)
              .fontColor(Theme.TEXT_LIGHT)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(Theme.TRACK)
              .borderRadius(8)
            if (goal.archived === 1) {
              Text('已归档')
                .fontSize(11)
                .fontColor(Theme.TEXT_LIGHT)
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        PriorityTag({ level: goal.priority })
      }
      .alignItems(VerticalAlign.Top)

      ProgressTrack({ percent: goal.progress })

      Row() {
        Text('已完成 ' + goal.taskDone.toString() + '/' + goal.taskTotal.toString() + ' 个任务')
          .fontSize(11)
          .fontColor(Theme.TEXT_LIGHT)
          .layoutWeight(1)
        Text(goal.startDate + (goal.endDate === '' ? ' 起' : ' ~ ' + goal.endDate))
          .fontSize(11)
          .fontColor(Theme.TEXT_LIGHT)
      }
      .width('100%')
    }
    .width('100%')
    .padding(15)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.navStack.pushPathByName('goalDetail', new GoalDetailParam(goal.id));
    })
  }
}
