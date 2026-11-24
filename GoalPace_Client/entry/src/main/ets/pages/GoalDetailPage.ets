import { Theme } from '../common/Theme';
import { Bus } from '../common/Bus';
import { GoalDetailVm } from '../viewmodel/GoalVms';
import { AppSession } from '../viewmodel/Session';
import { Goal, GoalDetailParam, GoalFormParam, ReviewParam, Task, TaskFormParam } from '../model/Models';
import { EmptyView, NavHeader, PriorityTag, ProgressTrack } from '../components/Widgets';

/**
 * S4 目标详情: 目标信息 + 任务清单(勾选/编辑/长按删除) + 复盘入口 + 归档/删除
 */
@ComponentV2
export struct GoalDetailPage {
  navPathStack: NavPathStack = new NavPathStack();
  @Local vm: GoalDetailVm = new GoalDetailVm();
  @Local showDelta: boolean = false;
  @Local deltaText: string = '';

  build() {
    NavDestination() {
      Column() {
        NavHeader({
          stack: this.navPathStack,
          headerTitle: '目标详情',
          headerActionText: '编辑',
          onHeaderAction: () => {
            this.navPathStack.pushPathByName('goalForm', new GoalFormParam(this.vm.goal.id));
          }
        })
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
              this.GoalInfoCard()
              this.TaskSection()
              this.ReviewEntry()
              this.ArchiveButton()
              this.DeleteButton()
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
      const param = ctx.pathInfo.param as GoalDetailParam;
      if (param !== undefined && param !== null) {
        this.vm.load(param.goalId);
      }
    })
    .backgroundColor(Theme.BG)
  }

  @Builder
  GoalInfoCard() {
    Column({ space: 12 }) {
      Row({ space: 10 }) {
        Column({ space: 6 }) {
          Text(this.vm.goal.title)
            .fontSize(19)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Row({ space: 6 }) {
            Text(this.vm.goal.type)
              .fontSize(11)
              .fontColor(Theme.PRIMARY_DEEP)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(Theme.PRIMARY_SOFT)
              .borderRadius(8)
            Text(this.vm.goal.category)
              .fontSize(11)
              .fontColor(Theme.TEXT_LIGHT)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(Theme.TRACK)
              .borderRadius(8)
            if (this.vm.goal.archived === 1) {
              Text('已归档')
                .fontSize(11)
                .fontColor(Color.White)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor(Theme.TEXT_LIGHT)
                .borderRadius(8)
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        PriorityTag({ level: this.vm.goal.priority })
      }
      .alignItems(VerticalAlign.Top)

      if (this.vm.goal.description !== '') {
        Text(this.vm.goal.description)
          .fontSize(13)
          .fontColor(Theme.TEXT_LIGHT)
          .lineHeight(20)
      }

      Row() {
        Text(this.vm.goal.startDate + (this.vm.goal.endDate === '' ? ' 起' : ' ~ ' + this.vm.goal.endDate))
          .fontSize(11)
          .fontColor(Theme.TEXT_LIGHT)
          .layoutWeight(1)
        Text(this.vm.goal.progress.toString() + '%')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.PRIMARY_DEEP)
      }
      .width('100%')
      ProgressTrack({ percent: this.vm.goal.progress })
      Text('已完成 ' + this.vm.goal.taskDone.toString() + '/' + this.vm.goal.taskTotal.toString() + ' 个任务')
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
  TaskSection() {
    Column({ space: 10 }) {
      Row() {
        Text('任务清单')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.TEXT)
          .layoutWeight(1)
        Text('＋ 添加任务')
          .fontSize(13)
          .fontColor(Theme.PRIMARY_DEEP)
          .onClick(() => {
            this.navPathStack.pushPathByName('taskForm', new TaskFormParam(this.vm.goal.id, 0));
          })
      }
      .width('100%')

      if (this.vm.tasks.length === 0) {
        EmptyView({ emptyTitle: '暂无任务', emptyHint: '把目标拆解成一个个可执行的小台阶' })
      }
      ForEach(this.vm.tasks, (task: Task) => {
        this.TaskRow(task)
      }, (task: Task) => task.id.toString())
    }
    .width('100%')
    .padding(15)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TaskRow(task: Task) {
    Row({ space: 12 }) {
      Text(task.status === 1 ? '✓' : '')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .width(22)
        .height(22)
        .borderRadius(11)
        .textAlign(TextAlign.Center)
        .backgroundColor(task.status === 1 ? Theme.PRIMARY : Color.Transparent)
        .border({ width: 1.5, color: task.status === 1 ? Theme.PRIMARY : Theme.TEXT_LIGHT })
        .hitTestBehavior(HitTestMode.Block)
        .onClick(() => {
          this.handleToggle(task);
        })

      Column({ space: 3 }) {
        Text(task.title)
          .fontSize(14)
          .fontColor(task.status === 1 ? Theme.TEXT_LIGHT : Theme.TEXT)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 8 }) {
          Text(Theme.priorityLabel(task.priority))
            .fontSize(10)
            .fontColor(Color.White)
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .backgroundColor(Theme.priorityColor(task.priority))
            .borderRadius(6)
          if (task.dueDate !== '') {
            Text(task.dueDate + (task.dueTime === '' ? '' : ' ' + task.dueTime))
              .fontSize(11)
              .fontColor(Theme.TEXT_LIGHT)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.navPathStack.pushPathByName('taskForm', new TaskFormParam(this.vm.goal.id, task.id));
    })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => {
          this.confirmDeleteTask(task);
        })
    )
  }

  @Builder
  ReviewEntry() {
    Row({ space: 10 }) {
      Text('📝')
        .fontSize(16)
      Column({ space: 3 }) {
        Text('复盘笔记')
          .fontSize(14)
          .fontColor(Theme.TEXT)
        Text('记录这个目标路上的思考与调整')
          .fontSize(11)
          .fontColor(Theme.TEXT_LIGHT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text('›')
        .fontSize(18)
        .fontColor(Theme.TEXT_LIGHT)
    }
    .width('100%')
    .padding(16)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.navPathStack.pushPathByName('review', new ReviewParam(this.vm.goal.id));
    })
  }

  @Builder
  ArchiveButton() {
    Button(this.vm.goal.archived === 1 ? '取消归档' : '归档目标')
      .width('100%')
      .height(44)
      .backgroundColor(Color.Transparent)
      .fontColor(Theme.PRIMARY_DEEP)
      .fontSize(14)
      .borderRadius(Theme.RADIUS)
      .border({ width: 1, color: Theme.PRIMARY })
      .onClick(() => {
        this.handleArchive();
      })
  }

  @Builder
  DeleteButton() {
    Button('删除目标')
      .width('100%')
      .height(44)
      .backgroundColor(Color.Transparent)
      .fontColor(Theme.DANGER)
      .fontSize(14)
      .borderRadius(Theme.RADIUS)
      .border({ width: 1, color: Theme.DANGER })
      .onClick(() => {
        this.confirmDeleteGoal();
      })
  }

  private handleToggle(task: Task): void {
    this.vm.toggle(task).then((result) => {
      if (result !== null) {
        Bus.inst.bumpTasks();
        const user = AppSession.inst.user;
        user.points = result.userPoints;
        user.level = result.userLevel;
        user.checkinDays = result.userCheckinDays;
        AppSession.inst.applyUser(user);
        if (result.pointsDelta > 0) {
          this.deltaText = '+' + result.pointsDelta.toString();
          this.showDelta = true;
          setTimeout(() => {
            this.showDelta = false;
          }, 1400);
        }
      }
    });
  }

  private handleArchive(): void {
    this.vm.archiveGoal(this.vm.goal.archived !== 1).then((msg: string) => {
      const prompt = this.getUIContext().getPromptAction();
      if (msg !== '') {
        prompt.showToast({ message: msg });
      } else {
        Bus.inst.bumpGoals();
        prompt.showToast({ message: this.vm.goal.archived === 1 ? '已取消归档' : '已归档' });
      }
    });
  }

  private confirmDeleteTask(task: Task): void {
    const prompt = this.getUIContext().getPromptAction();
    AlertDialog.show({
      title: '删除任务',
      message: '确定删除「' + task.title + '」吗？删除后不可恢复。',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: Theme.DANGER,
        action: () => {
          this.vm.deleteTask(task.id).then((msg: string) => {
            if (msg !== '') {
              prompt.showToast({ message: msg });
            } else {
              Bus.inst.bumpTasks();
              prompt.showToast({ message: '任务已删除' });
            }
          });
        }
      }
    });
  }

  private confirmDeleteGoal(): void {
    const prompt = this.getUIContext().getPromptAction();
    AlertDialog.show({
      title: '删除目标',
      message: '删除目标将同时删除其下全部任务与复盘记录，确定删除吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: Theme.DANGER,
        action: () => {
          this.vm.removeGoal().then((msg: string) => {
            if (msg !== '') {
              prompt.showToast({ message: msg });
            } else {
              Bus.inst.bumpGoals();
              Bus.inst.bumpTasks();
              prompt.showToast({ message: '目标已删除' });
              this.navPathStack.pop();
            }
          });
        }
      }
    });
  }
}

@Builder
export function GoalDetailBuilder() {
  GoalDetailPage()
}
