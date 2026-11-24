import { Theme } from '../common/Theme';
import { LoginVm } from '../viewmodel/AuthVms';

/**
 * S1 登录页: 登录凭据提交服务端校验, 返回会话态
 */
@ComponentV2
export struct LoginPage {
  @Local vm: LoginVm = new LoginVm();
  @Event onGoRegister: () => void = () => {
  };

  build() {
    Column() {
      Scroll() {
        Column() {
          this.BrandBlock()
          this.LoginForm()
          this.SubmitButton()
          this.GoRegisterLink()
          this.BottomNote()
        }
        .width('100%')
        .constraintSize({ minHeight: '100%' })
        .justifyContent(FlexAlign.Center)
        .padding({ left: 30, right: 30, top: 24, bottom: 24 })
        .alignItems(HorizontalAlign.Start)
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  BrandBlock() {
    Column({ space: 12 }) {
      Column() {
        Text('阶')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(68)
      .height(68)
      .borderRadius(18)
      .backgroundColor(Theme.PRIMARY)
      .justifyContent(FlexAlign.Center)

      Text('拾阶')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.TEXT)
      Text('一步一步，拾级而上')
        .fontSize(13)
        .fontColor(Theme.TEXT_LIGHT)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: 34 })
  }

  @Builder
  FormInput(inputLabel: string, inputPlaceholder: string, inputText: string,
    isPassword: boolean, onInput: (text: string) => void) {
    Column({ space: 7 }) {
      Text(inputLabel)
        .fontSize(13)
        .fontColor(Theme.TEXT_LIGHT)
      TextInput({ placeholder: inputPlaceholder, text: inputText })
        .type(isPassword ? InputType.Password : InputType.Normal)
        .backgroundColor(Theme.INPUT_BG)
        .fontColor(Theme.TEXT)
        .fontSize(Theme.FONT_BODY)
        .placeholderColor(Theme.TEXT_LIGHT)
        .placeholderFont({ size: 14 })
        .caretColor(Theme.PRIMARY)
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

  @Builder
  LoginForm() {
    Column({ space: 15 }) {
      this.FormInput('用户名', '请输入用户名', this.vm.username, false, (text: string) => {
        this.vm.username = text;
      })
      this.FormInput('密码', '请输入密码', this.vm.password, true, (text: string) => {
        this.vm.password = text;
      })
    }
    .width('100%')
  }

  @Builder
  SubmitButton() {
    Button(this.vm.loading ? '登录中...' : '登 录')
      .width('100%')
      .height(46)
      .backgroundColor(Theme.PRIMARY)
      .fontColor(Color.White)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .borderRadius(23)
      .margin({ top: 28 })
      .enabled(!this.vm.loading)
      .opacity(this.vm.loading ? 0.6 : 1)
      .onClick(() => {
        this.handleLogin();
      })
  }

  @Builder
  GoRegisterLink() {
    Text() {
      Span('还没有账号？')
        .fontSize(14)
        .fontColor(Theme.TEXT_LIGHT)
      Span('去注册')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.PRIMARY_DEEP)
    }
    .width('100%')
    .textAlign(TextAlign.Center)
    .margin({ top: 18 })
    .onClick(() => {
      this.onGoRegister();
    })
  }

  @Builder
  BottomNote() {
    Text('账号数据由服务端加密存储 · 支持修改密码与提醒偏好')
      .fontSize(Theme.FONT_CAPTION)
      .fontColor(Theme.TEXT_LIGHT)
      .opacity(0.75)
      .width('100%')
      .textAlign(TextAlign.Center)
      .margin({ top: 40 })
  }

  private handleLogin(): void {
    const prompt = this.getUIContext().getPromptAction();
    this.vm.login().then((msg: string) => {
      if (msg !== '') {
        prompt.showToast({ message: msg });
      }
    });
  }
}
