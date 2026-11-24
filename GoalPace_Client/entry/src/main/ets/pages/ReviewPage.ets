import { LengthMetrics } from '@kit.ArkUI';
import { Theme } from '../common/Theme';
import { ReviewVm } from '../viewmodel/MiscVms';
import { Goal, ReviewNote, ReviewParam } from '../model/Models';
import { FieldLabel, NavHeader } from '../components/Widgets';

/**
 * S9 复盘笔记: 目标关联 + 自由文本记录 + 历史回顾
 */
@ComponentV2
export struct ReviewPage {
  navPathStack: NavPathStack = new NavPathStack();
  @Local vm: ReviewVm = new ReviewVm();

  build() {
    NavDestination() {
      Column() {
        NavHeader({ stack: this.navPathStack, headerTitle: '复盘笔记' })
        Scroll() {
          Column({ space: 14 }) {
            if (this.vm.offline) {
              Text('离线镜像展示，新建笔记需要网络')
                .fontSize(11)
                .fontColor(Theme.DANGER)
            }

            Column({ space: 8 }) {
              FieldLabel({ label: '关联目标', required: true })
              if (this.vm.goalLocked) {
                Text(this.vm.goalTitle() === '' ? '当前目标' : this.vm.goalTitle())
                  .fontSize(14)
                  .fontColor(Theme.PRIMARY_DEEP)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor(Theme.PRIMARY_SOFT)
                  .borderRadius(16)
              } else if (this.vm.goals.length === 0) {
                Text('还没有目标，先去创建一个目标吧')
                  .fontSize(12)
                  .fontColor(Theme.TEXT_LIGHT)
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
                        this.switchGoal(goal.id);
                      })
                  }, (goal: Goal) => goal.id.toString())
                }
                .width('100%')
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              FieldLabel({ label: '今日复盘', required: true })
              TextArea({ placeholder: '今天做得怎么样？\n· 哪些完成得不错？\n· 哪些没做完，原因是什么？\n· 明天打算怎么调整？', text: this.vm.content })
                .backgroundColor(Theme.INPUT_BG)
                .fontColor(Theme.TEXT)
                .fontSize(Theme.FONT_BODY)
                .placeholderColor(Theme.TEXT_LIGHT)
                .height(150)
                .borderRadius(Theme.RADIUS_SM)
                .border({ width: 1, color: Theme.DIVIDER })
                .padding(12)
                .onChange((value: string) => {
                  this.vm.content = value;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Button(this.vm.saving ? '保存中...' : '保存复盘')
              .width('100%')
              .height(46)
              .backgroundColor(Theme.PRIMARY)
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(23)
              .enabled(!this.vm.saving)
              .opacity(this.vm.saving ? 0.6 : 1)
              .onClick(() => {
                this.handleSave();
              })

            if (this.vm.notes.length > 0) {
              Text('历史复盘')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.TEXT)
                .margin({ top: 8 })
              ForEach(this.vm.notes, (note: ReviewNote) => {
                Column({ space: 8 }) {
                  Row() {
                    Text(note.goalTitle === '' ? '复盘' : note.goalTitle)
                      .fontSize(12)
                      .fontColor(Theme.PRIMARY_DEEP)
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(note.createTime.length >= 16 ? note.createTime.substring(0, 16) : note.createTime)
                      .fontSize(11)
                      .fontColor(Theme.TEXT_LIGHT)
                  }
                  .width('100%')
                  Text(note.content)
                    .fontSize(13)
                    .fontColor(Theme.TEXT)
                    .lineHeight(20)
                }
                .width('100%')
                .padding(14)
                .borderRadius(Theme.RADIUS)
                .backgroundColor(Theme.CARD)
                .alignItems(HorizontalAlign.Start)
              }, (note: ReviewNote) => note.id.toString())
            }
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
      const param = ctx.pathInfo.param as ReviewParam;
      if (param !== undefined && param !== null) {
        this.vm.load(param.goalId);
      }
    })
    .backgroundColor(Theme.BG)
  }

  private switchGoal(goalId: number): void {
    this.vm.goalId = goalId;
    this.vm.refresh();
  }

  private handleSave(): void {
    const prompt = this.getUIContext().getPromptAction();
    this.vm.save().then((msg: string) => {
      if (msg !== '') {
        prompt.showToast({ message: msg });
      } else {
        prompt.showToast({ message: '复盘已保存' });
      }
    });
  }
}

@Builder
export function ReviewBuilder() {
  ReviewPage()
}
