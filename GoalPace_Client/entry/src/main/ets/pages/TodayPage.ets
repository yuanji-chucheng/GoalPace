import { Theme } from '../common/Theme';
import { Fmt } from '../common/Fmt';
import { Bus } from '../common/Bus';
import { TodayVm, TaskGroup } from '../viewmodel/TaskVms';
import { AppSession } from '../viewmodel/Session';
import { Task, TaskFormParam } from '../model/Models';
import { EmptyView } from '../components/Widgets';

/**
 * S2 今日: 打卡概览 + 今日任务(按目标分组), 勾选触发服务端积分与进度重算并回刷
 */
@ComponentV2
export struct TodayPage {
  @Param navStack: NavPathStack = new NavPathStack();
  @Local vm: TodayVm = new TodayVm();
  @Local session: AppSession = AppSession.inst;
  @Local bus: Bus = Bus.inst;
  @Local refreshing: boolean = false;

  aboutToAppear(): void {
    this.vm.refresh();
  }

  @Monitor('bus.tasksTick')
  onTasksTick(): void {
    this.vm.refresh();
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        this.HeaderBar()
        this.CheckinCard()
        this.SectionBar()
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
          Refresh({ refreshing: this.refreshing!! }) {
            List({ space: 10 }) {
              if (this.vm.groups().length === 0) {
                ListItem() {
                  EmptyView({
                    emptyIcon: '⛰',
                    emptyTitle: '暂无今日任务',
                    emptyHint: '创建目标并拆解任务后，将在这里汇总'
                  })
                }
              }
              ForEach(this.vm.groups(), (group: TaskGroup) => {
                ListItem() {
                  Text(group.goalTitle === '' ? '未分组' : group.goalTitle)
                    .fontSize(13)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.TEXT_LIGHT)
                }
                ForEach(group.items, (task: Task) => {
                  ListItem() {
                    this.TaskRow(task)
                  }
                }, (task: Task) => task.id.toString())
              }, (group: TaskGroup) => group.goalId.toString())
            }
            .width('100%')
            .scrollBar(BarState.Off)
            .padding({ left: 18, right: 18, bottom: 130 })
          }
          .onRefreshing(() => {
            this.vm.sync().then(() => {
              this.refreshing = false;
            });
          })
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')

      if (this.vm.showDelta) {
        Text(this.vm.deltaText)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.PRIMARY_DEEP)
          .position({ x: '42%', y: 200 })
          .transition(TransitionEffect.OPACITY.animation({ duration: 500 })
            .combine(TransitionEffect.translate({ y: -30 }).animation({ duration: 900 })))
      }

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
          this.navStack.pushPathByName('taskForm', new TaskFormParam(0, 0));
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
        Text(Fmt.greeting() + '，' + (this.session.user.nickname === ''
          ? this.session.user.username : this.session.user.nickname))
          .fontSize(21)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.TEXT)
        Text(Fmt.today() + ' · ' + Fmt.weekdayLabel(new Date()))
          .fontSize(12)
          .fontColor(Theme.TEXT_LIGHT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Row({ space: 5 }) {
        Text('✦')
          .fontSize(13)
          .fontColor(Theme.PRIMARY_DEEP)
        Text(this.session.user.points.toString())
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.PRIMARY_DEEP)
        Text('分')
          .fontSize(11)
          .fontColor(Theme.PRIMARY_DEEP)
      }
      .padding({ left: 14, right: 14, top: 7, bottom: 7 })
      .backgroundColor(Theme.PRIMARY_SOFT)
      .borderRadius(18)
      .onClick(() => {
        this.navStack.pushPathByName('points', '');
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 12 })
  }

  @Builder
  CheckinCard() {
    Row({ space: 14 }) {
      Column({ space: 4 }) {
        Text('连续打卡')
          .fontSize(12)
          .fontColor(Theme.TEXT_LIGHT)
        Text() {
          Span(this.session.user.checkinDays.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.PRIMARY_DEEP)
          Span(' 天')
            .fontSize(12)
            .fontColor(Theme.TEXT_LIGHT)
        }
      }
      .alignItems(HorizontalAlign.Start)

      Column()
        .width(1)
        .height(38)
        .backgroundColor(Theme.DIVIDER)

      Column({ space: 4 }) {
        Text('今日完成 / 待办')
          .fontSize(12)
          .fontColor(Theme.TEXT_LIGHT)
        Text() {
          Span(this.vm.todayDoneCount().toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Span(' / ')
            .fontSize(14)
            .fontColor(Theme.TEXT_LIGHT)
          Span(this.vm.todayPendingCount().toString())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('拾级而上')
        .fontSize(12)
        .fontColor(Theme.PRIMARY)
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .border({ width: 1, color: Theme.PRIMARY })
        .borderRadius(14)
    }
    .width('100%')
    .padding(16)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .margin({ left: 18, right: 18 })
  }

  @Builder
  SectionBar() {
    Row() {
      Text('今日任务')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT)
        .layoutWeight(1)
      if (this.vm.offline) {
        Text('离线镜像')
          .fontSize(11)
          .fontColor(Theme.DANGER)
          .margin({ right: 8 })
      }
      Text('查看全部')
        .fontSize(13)
        .fontColor(Theme.PRIMARY_DEEP)
        .onClick(() => {
          this.navStack.pushPathByName('allTasks', '');
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 18, bottom: 10 })
  }

  @Builder
  TaskRow(task: Task) {
    Row({ space: 12 }) {
      Text(task.status === 1 ? '✓' : '')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width(24)
        .height(24)
        .borderRadius(12)
        .textAlign(TextAlign.Center)
        .backgroundColor(task.status === 1 ? Theme.PRIMARY : Color.Transparent)
        .border({ width: 1.6, color: task.status === 1 ? Theme.PRIMARY : Theme.TEXT_LIGHT })
        .hitTestBehavior(HitTestMode.Block)
        .onClick(() => {
          this.vm.toggle(task);
        })

      Column({ space: 4 }) {
        Text(task.title)
          .fontSize(Theme.FONT_BODY)
          .fontColor(task.status === 1 ? Theme.TEXT_LIGHT : Theme.TEXT)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 8 }) {
          Text(Theme.priorityLabel(task.priority))
            .fontSize(10)
            .fontColor(Color.White)
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .backgroundColor(Theme.priorityColor(task.priority))
            .borderRadius(6)
          if (task.dueTime !== '') {
            Text(task.dueTime)
              .fontSize(11)
              .fontColor(Theme.TEXT_LIGHT)
          }
          if (task.dueDate !== '' && task.dueDate < Fmt.today() && task.status === 0) {
            Text('已过期')
              .fontSize(11)
              .fontColor(Theme.DANGER)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(14)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.navStack.pushPathByName('taskForm', new TaskFormParam(task.goalId, task.id));
    })
  }
}
