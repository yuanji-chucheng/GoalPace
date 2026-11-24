import { LengthMetrics } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { Fmt } from '../common/Fmt';
import { Bus } from '../common/Bus';
import { GoalFormVm } from '../viewmodel/GoalVms';
import { GoalFormParam } from '../model/Models';
import { FieldLabel, NavHeader } from '../components/Widgets';

/**
 * S5 目标表单: 新建/编辑目标(标题/类型/分类/优先级/起止/描述/提醒)
 */
@ComponentV2
export struct GoalFormPage {
  navPathStack: NavPathStack = new NavPathStack();
  @Local vm: GoalFormVm = new GoalFormVm();
  @Local priorityValues: number[] = [3, 2, 1];

  build() {
    NavDestination() {
      Column() {
        NavHeader({
          stack: this.navPathStack,
          headerTitle: this.vm.goalId > 0 ? '编辑目标' : '新建目标'
        })
        Scroll() {
          Column({ space: 16 }) {
            Column({ space: 8 }) {
              FieldLabel({ label: '目标标题', required: true })
              TextInput({ placeholder: '例如：完成一次半程马拉松', text: this.vm.title })
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

            this.FormChips('目标类型', GoalFormVm.TYPES,
              GoalFormVm.TYPES.indexOf(this.vm.type), (idx: number) => {
                this.vm.type = GoalFormVm.TYPES[idx];
              })

            this.FormChips('目标分类', GoalFormVm.CATEGORIES,
              GoalFormVm.CATEGORIES.indexOf(this.vm.category), (idx: number) => {
                this.vm.category = GoalFormVm.CATEGORIES[idx];
              })

            this.FormChips('优先级', ['高', '中', '低'],
              this.priorityValues.indexOf(this.vm.priority), (idx: number) => {
                this.vm.priority = this.priorityValues[idx];
              })

            Column({ space: 8 }) {
              FieldLabel({ label: '起止日期' })
              Row({ space: 10 }) {
                Text(this.vm.startDate === '' ? '选择开始日期' : this.vm.startDate)
                  .fontSize(14)
                  .fontColor(this.vm.startDate === '' ? Theme.TEXT_LIGHT : Theme.TEXT)
                  .height(44)
                  .borderRadius(Theme.RADIUS_SM)
                  .border({ width: 1, color: Theme.DIVIDER })
                  .backgroundColor(Theme.INPUT_BG)
                  .textAlign(TextAlign.Center)
                  .layoutWeight(1)
                  .onClick(() => {
                    this.pickDate(true);
                  })
                Text('~')
                  .fontSize(14)
                  .fontColor(Theme.TEXT_LIGHT)
                Text(this.vm.endDate === '' ? '选填' : this.vm.endDate)
                  .fontSize(14)
                  .fontColor(this.vm.endDate === '' ? Theme.TEXT_LIGHT : Theme.TEXT)
                  .height(44)
                  .borderRadius(Theme.RADIUS_SM)
                  .border({ width: 1, color: Theme.DIVIDER })
                  .backgroundColor(Theme.INPUT_BG)
                  .textAlign(TextAlign.Center)
                  .layoutWeight(1)
                  .onClick(() => {
                    this.pickDate(false);
                  })
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              FieldLabel({ label: '目标描述' })
              TextArea({ placeholder: '写下这个目标对你的意义…', text: this.vm.description })
                .backgroundColor(Theme.INPUT_BG)
                .fontColor(Theme.TEXT)
                .fontSize(Theme.FONT_BODY)
                .placeholderColor(Theme.TEXT_LIGHT)
                .height(92)
                .borderRadius(Theme.RADIUS_SM)
                .border({ width: 1, color: Theme.DIVIDER })
                .padding(12)
                .onChange((value: string) => {
                  this.vm.description = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            this.RemindRow()

            Button(this.vm.saving ? '保存中...' : '保存目标')
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
      .width('100%')
      .height('100%')
    }
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack;
      const param = ctx.pathInfo.param as GoalFormParam;
      if (param !== undefined && param !== null) {
        this.vm.load(param.goalId);
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
  RemindRow() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 3 }) {
          Text('目标提醒')
            .fontSize(14)
            .fontColor(Theme.TEXT)
          Text('到点提醒我关注这个目标')
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
        Row({ space: 10 }) {
          Text(this.vm.remindTime)
            .fontSize(14)
            .fontColor(Theme.TEXT)
            .height(40)
            .padding({ left: 14, right: 14 })
            .borderRadius(Theme.RADIUS_SM)
            .border({ width: 1, color: Theme.DIVIDER })
            .backgroundColor(Theme.INPUT_BG)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.pickTime();
            })
          Text('每天在这个时间提醒')
            .fontSize(11)
            .fontColor(Theme.TEXT_LIGHT)
            .layoutWeight(1)
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

  private pickDate(isStart: boolean): void {
    DatePickerDialog.show({
      start: new Date('2020-1-1'),
      end: new Date('2035-12-31'),
      selected: Fmt.parseDate(isStart ? this.vm.startDate : this.vm.endDate),
      onDateAccept: (value: Date) => {
        const text = Fmt.dateString(value);
        if (isStart) {
          this.vm.startDate = text;
        } else {
          this.vm.endDate = text;
        }
      }
    });
  }

  private pickTime(): void {
    TimePickerDialog.show({
      selected: Fmt.parseTime(this.vm.remindTime),
      useMilitaryTime: true,
      onAccept: (value: TimePickerResult) => {
        this.vm.remindTime = (value.hour < 10 ? '0' + value.hour.toString() : value.hour.toString())
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
        Bus.inst.bumpGoals();
        prompt.showToast({ message: '目标已保存' });
        this.navPathStack.pop();
      }
    });
  }
}

@Builder
export function GoalFormBuilder() {
  GoalFormPage()
}
