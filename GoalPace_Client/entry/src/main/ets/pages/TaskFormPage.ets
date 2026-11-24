import { LengthMetrics } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Fmt } from '../common/Fmt';
import { Bus } from '../common/Bus';
import { TaskFormVm } from '../viewmodel/TaskVms';
import { Goal, TaskFormParam } from '../model/Models';
import { FieldLabel, NavHeader } from '../components/Widgets';

/**
 * S14 任务表单: 关联目标/标题/日期时间/优先级/备注/提醒(新建与编辑复用)
 */
@ComponentV2
export struct TaskFormPage {
  navPathStack: NavPathStack = new NavPathStack();
  @Local vm: TaskFormVm = new TaskFormVm();
  @Local priorityLabels: string[] = ['高', '中', '低'];
  @Local priorityValues: number[] = [3, 2, 1];

  build() {
    NavDestination() {
      Column() {
        NavHeader({
          stack: this.navPathStack,
          headerTitle: this.vm.taskId > 0 ? '编辑任务' : '新建任务'
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
            Column({ space: 16 }) {
              Column({ space: 8 }) {
                FieldLabel({ label: '任务标题', required: true })
                TextInput({ placeholder: '要做什么？尽量具体可执行', text: this.vm.title })
                  .backgroundColor(Theme.INPUT_BG)
                  .fontColor(Theme.TEXT)
                  .fontSize(Theme.FONT_BODY)
                  .placeholderColor(Theme.TEXT_LIGHT)
                  .height(46)
                  .borderRadius(Theme.RADIUS_SM)
                  .border({ width: 1, color: Theme.DIVIDER })
                  .padding({ left: 14, right: 14 })
                  .onChange((value: string) => {
                    this.vm.title = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)

              Column({ space: 8 }) {
                FieldLabel({ label: '关联目标', required: true })
                if (this.vm.goalLocked) {
                  Text(this.vm.goalTitle() === '' ? '当前目标' : this.vm.goalTitle())
                    .fontSize(14)
                    .fontColor(Theme.PRIMARY_DEEP)
                    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                    .backgroundColor(Theme.PRIMARY_SOFT)
                    .borderRadius(16)
                } else {
                  Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
                    ForEach(this.vm.goals, (goal: Goal) => {
                      Text(goal.title)
                        .fontSize(13)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .constraintSize({ maxWidth: 180 })
                        .fontColor(this.vm.goalId === goal.id ? Theme.PRIMARY_DEEP : Theme.TEXT_LIGHT)
                        .fontWeight(this.vm.goalId === goal.id ? FontWeight.Medium : FontWeight.Normal)
                        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                        .backgroundColor(this.vm.goalId === goal.id ? Theme.PRIMARY_SOFT : Theme.CARD)
                        .borderRadius(18)
                        .border({ width: 1, color: this.vm.goalId === goal.id ? Theme.PRIMARY : Theme.DIVIDER })
                        .onClick(() => {
                          this.vm.goalId = goal.id;
                        })
                    }, (goal: Goal) => goal.id.toString())
                  }
                  .width('100%')
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)

              this.FormChips('优先级', this.priorityLabels,
                this.priorityValues.indexOf(this.vm.priority), (idx: number) => {
                  this.vm.priority = this.priorityValues[idx];
                })

              Column({ space: 8 }) {
                FieldLabel({ label: '截止日期与时间' })
                Row({ space: 10 }) {
                  Text(this.vm.dueDate === '' ? '选择日期' : this.vm.dueDate)
                    .fontSize(14)
                    .fontColor(this.vm.dueDate === '' ? Theme.TEXT_LIGHT : Theme.TEXT)
                    .height(44)
                    .borderRadius(Theme.RADIUS_SM)
                    .border({ width: 1, color: Theme.DIVIDER })
                    .backgroundColor(Theme.INPUT_BG)
                    .textAlign(TextAlign.Center)
                    .layoutWeight(1)
                    .onClick(() => {
                      this.pickDate();
                    })
                  Text(this.vm.dueTime === '' ? '选填' : this.vm.dueTime)
                    .fontSize(14)
                    .fontColor(this.vm.dueTime === '' ? Theme.TEXT_LIGHT : Theme.TEXT)
                    .height(44)
                    .borderRadius(Theme.RADIUS_SM)
                    .border({ width: 1, color: Theme.DIVIDER })
                    .backgroundColor(Theme.INPUT_BG)
                    .textAlign(TextAlign.Center)
                    .width(110)
                    .onClick(() => {
                      this.pickTime();
                    })
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)

              Column({ space: 8 }) {
                FieldLabel({ label: '备注' })
                TextArea({ placeholder: '补充说明、执行要点…(选填)', text: this.vm.note })
                  .backgroundColor(Theme.INPUT_BG)
                  .fontColor(Theme.TEXT)
                  .fontSize(Theme.FONT_BODY)
                  .placeholderColor(Theme.TEXT_LIGHT)
                  .height(80)
                  .borderRadius(Theme.RADIUS_SM)
                  .border({ width: 1, color: Theme.DIVIDER })
                  .padding(12)
                  .onChange((value: string) => {
                    this.vm.note = value;
                  })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)

              this.RemindCard()

              Button(this.vm.saving ? '保存中...' : '保存任务')
                .width('100%')
                .height(46)
                .backgroundColor(Theme.PRIMARY)
                .fontColor(Color.White)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .borderRadius(23)
                .margin({ top: 10 })
                .enabled(!this.vm.saving)
                .opacity(this.vm.saving ? 0.6 : 1)
                .onClick(() => {
                  this.handleSave();
                })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 40 })
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
      const param = ctx.pathInfo.param as TaskFormParam;
      if (param !== undefined && param !== null) {
        this.vm.load(param.goalId, param.taskId);
      }
    })
    .backgroundColor(Theme.BG)
  }

  @Builder
  FormChips(label: string, labels: string[], selectedIdx: number, onSelect: (idx: number) => void) {
    Column({ space: 8 }) {
      FieldLabel({ label: label })
      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(labels, (item: string, idx: number) => {
          Text(item)
            .fontSize(13)
            .fontColor(selectedIdx === idx ? Theme.PRIMARY_DEEP : Theme.TEXT_LIGHT)
            .fontWeight(selectedIdx === idx ? FontWeight.Medium : FontWeight.Normal)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(selectedIdx === idx ? Theme.PRIMARY_SOFT : Theme.CARD)
            .borderRadius(18)
            .border({ width: 1, color: selectedIdx === idx ? Theme.PRIMARY : Theme.DIVIDER })
            .onClick(() => {
              onSelect(idx);
            })
        }, (item: string, idx: number) => item + '_' + idx.toString())
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  RemindCard() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 3 }) {
          Text('到期提醒')
            .fontSize(14)
            .fontColor(Theme.TEXT)
          Text('在任务到期前提醒我')
            .fontSize(11)
            .fontColor(Theme.TEXT_LIGHT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.vm.remindOn })
          .selectedColor(Theme.PRIMARY)
          .onChange((isOn: boolean) => {
            this.vm.remindOn = isOn;
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.vm.remindOn) {
        Row({ space: 8 }) {
          Text('提前')
            .fontSize(13)
            .fontColor(Theme.TEXT_LIGHT)
          ForEach(TaskFormVm.ADVANCES, (minutes: number) => {
            Text(minutes.toString() + '分钟')
              .fontSize(12)
              .fontColor(this.vm.remindAdvance === minutes ? Theme.PRIMARY_DEEP : Theme.TEXT_LIGHT)
              .fontWeight(this.vm.remindAdvance === minutes ? FontWeight.Medium : FontWeight.Normal)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.vm.remindAdvance === minutes ? Theme.PRIMARY_SOFT : Theme.CARD)
              .borderRadius(14)
              .border({ width: 1, color: this.vm.remindAdvance === minutes ? Theme.PRIMARY : Theme.DIVIDER })
              .onClick(() => {
                this.vm.remindAdvance = minutes;
              })
          }, (minutes: number) => minutes.toString())
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .padding(15)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }

  private pickDate(): void {
    DatePickerDialog.show({
      start: new Date('2020-1-1'),
      end: new Date('2035-12-31'),
      selected: Fmt.parseDate(this.vm.dueDate),
      onDateAccept: (value: Date) => {
        this.vm.dueDate = Fmt.dateString(value);
      }
    });
  }

  private pickTime(): void {
    TimePickerDialog.show({
      selected: Fmt.parseTime(this.vm.dueTime),
      useMilitaryTime: true,
      onAccept: (value: TimePickerResult) => {
        this.vm.dueTime = (value.hour < 10 ? '0' + value.hour.toString() : value.hour.toString())
          + ':' + (value.minute < 10 ? '0' + value.minute.toString() : value.minute.toString());
      }
    });
  }

  private handleSave(): void {
    const prompt = this.getUIContext().getPromptAction();
    this.vm.save().then((msg: string) => {
      if (msg !== '') {
        prompt.showToast({ message: msg });
      } else {
        Bus.inst.bumpTasks();
        prompt.showToast({ message: '任务已保存' });
        this.navPathStack.pop();
      }
    });
  }
}

@Builder
export function TaskFormBuilder() {
  TaskFormPage()
}
