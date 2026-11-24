import { Theme } from '../common/Theme';
import { Bus } from '../common/Bus';
import { TasksVm } from '../viewmodel/TaskVms';
import { Task, TaskFormParam } from '../model/Models';
import { ChipRow, EmptyView } from '../components/Widgets';
import { NavHeader } from '../components/Widgets';

/**
 * S6 全部任务: 状态/优先级筛选, 勾选完成, 点击编辑, 长按删除
 */
@ComponentV2
export struct AllTasksPage {
  navPathStack: NavPathStack = new NavPathStack();
  @Local vm: TasksVm = new TasksVm();
  @Local statusLabels: string[] = ['全部', '待办', '已完成'];
  @Local priorityLabels: string[] = ['全部', '高', '中', '低'];

  build() {
    NavDestination() {
      Column() {
        NavHeader({ stack: this.navPathStack, headerTitle: '全部任务' })
        Column({ space: 8 }) {
          ChipRow({
            labels: this.statusLabels,
            selected: this.vm.statusChip,
            onChipSelect: (index: number) => {
              this.vm.statusChip = index;
              this.vm.refresh();
            }
          })
          ChipRow({
            labels: this.priorityLabels,
            selected: this.vm.priorityChip,
            onChipSelect: (index: number) => {
              this.vm.priorityChip = index;
              this.vm.refresh();
            }
          })
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 10 })

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
            Column({ space: 10 }) {
              if (this.vm.offline) {
                Text('离线镜像展示，数据可能不是最新')
                  .fontSize(11)
                  .fontColor(Theme.DANGER)
                  .alignSelf(ItemAlign.Start)
              }
              if (this.vm.tasks.length === 0) {
                EmptyView({ emptyTitle: '没有符合条件的任务', emptyHint: '调整筛选条件或创建新任务' })
              }
              ForEach(this.vm.tasks, (task: Task) => {
                this.TaskRow(task)
              }, (task: Task) => task.id.toString())
            }
            .width('100%')
            .padding({ left: 18, right: 18, top: 12, bottom: 40 })
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
          Text(task.goalTitle === '' ? '未分组' : task.goalTitle)
            .fontSize(11)
            .fontColor(Theme.TEXT_LIGHT)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
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
          if (task.status === 1 && task.completeTime !== '') {
            Text('完成于 ' + task.completeTime.substring(5, 16))
              .fontSize(11)
              .fontColor(Theme.PRIMARY_DEEP)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(13)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.navPathStack.pushPathByName('taskForm', new TaskFormParam(0, task.id));
    })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => {
          this.confirmDelete(task);
        })
    )
  }

  private handleToggle(task: Task): void {
    this.vm.toggle(task).then(() => {
      Bus.inst.bumpTasks();
    });
  }

  private confirmDelete(task: Task): void {
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
          this.vm.remove(task.id).then((msg: string) => {
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
}

@Builder
export function AllTasksBuilder() {
  AllTasksPage()
}
