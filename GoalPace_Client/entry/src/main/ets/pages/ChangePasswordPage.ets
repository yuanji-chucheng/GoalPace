import { Theme } from '../common/Theme';
import { ChangePwdVm } from '../viewmodel/AuthVms';
import { AppSession } from '../viewmodel/Session';
import { FieldLabel, NavHeader } from '../components/Widgets';

/**
 * S13 修改密码: 成功后清理登录态回到 S1 重新登录
 */
@ComponentV2
export struct ChangePasswordPage {
  navPathStack: NavPathStack = new NavPathStack();
  @Local vm: ChangePwdVm = new ChangePwdVm();

  build() {
    NavDestination() {
      Column() {
        NavHeader({ stack: this.navPathStack, headerTitle: '修改密码' })
        Scroll() {
          Column({ space: 16 }) {
            Text('为保障账号安全，修改密码后需重新登录')
              .fontSize(12)
              .fontColor(Theme.TEXT_LIGHT)

            this.PwdInput('原密码', '请输入当前密码', this.vm.oldPassword, (text: string) => {
              this.vm.oldPassword = text;
            })
            this.PwdInput('新密码', '8-20位，需同时包含字母和数字', this.vm.newPassword, (text: string) => {
              this.vm.newPassword = text;
            })
            this.PwdInput('确认新密码', '再次输入新密码', this.vm.confirmPassword, (text: string) => {
              this.vm.confirmPassword = text;
            })

            Button(this.vm.loading ? '提交中...' : '确认修改')
              .width('100%')
              .height(46)
              .backgroundColor(Theme.PRIMARY)
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(23)
              .margin({ top: 10 })
              .enabled(!this.vm.loading)
              .opacity(this.vm.loading ? 0.6 : 1)
              .onClick(() => {
                this.handleSubmit();
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 18, bottom: 40 })
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
    })
    .backgroundColor(Theme.BG)
  }

  @Builder
  PwdInput(label: string, placeholder: string, text: string, onInput: (text: string) => void) {
    Column({ space: 8 }) {
      FieldLabel({ label: label, required: true })
      TextInput({ placeholder: placeholder, text: text })
        .type(InputType.Password)
        .showPasswordIcon(true)
        .backgroundColor(Theme.INPUT_BG)
        .fontColor(Theme.TEXT)
        .fontSize(Theme.FONT_BODY)
        .placeholderColor(Theme.TEXT_LIGHT)
        .height(46)
        .borderRadius(Theme.RADIUS_SM)
        .border({ width: 1, color: Theme.DIVIDER })
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          onInput(value);
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  private handleSubmit(): void {
    const prompt = this.getUIContext().getPromptAction();
    this.vm.submit().then((msg: string) => {
      if (msg !== '') {
        prompt.showToast({ message: msg });
      } else {
        prompt.showToast({ message: '密码已修改，请重新登录' });
        AppSession.inst.logout();
        this.navPathStack.pop();
      }
    });
  }
}

@Builder
export function ChangePasswordBuilder() {
  ChangePasswordPage()
}
