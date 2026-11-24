import { Theme } from '../common/Theme';
import { RegisterVm } from '../viewmodel/AuthVms';

/**
 * S12 注册页: 注册成功后返回登录页登录, 不自动登录
 */
@ComponentV2
export struct RegisterPage {
  @Local vm: RegisterVm = new RegisterVm();
  @Event onBackToLogin: () => void = () => {
  };
  @Event onRegistered: () => void = () => {
  };

  build() {
    Column() {
      Scroll() {
        Column() {
          this.HeaderBlock()
          this.RegisterForm()
          this.SubmitButton()
          this.BackLoginLink()
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
  HeaderBlock() {
    Column({ space: 8 }) {
      Text('创建账号')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.TEXT)
      Text('创建账号，开始你的第一级台阶')
        .fontSize(13)
        .fontColor(Theme.TEXT_LIGHT)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: 30 })
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
  RegisterForm() {
    Column({ space: 15 }) {
      this.FormInput('用户名', '3-20位字母、数字或中文', this.vm.username, false, (text: string) => {
        this.vm.username = text;
      })
      this.FormInput('昵称（选填）', '展示用的昵称', this.vm.nickname, false, (text: string) => {
        this.vm.nickname = text;
      })
      this.FormInput('密码', '8-20位，需含字母和数字', this.vm.password, true, (text: string) => {
        this.vm.password = text;
      })
      this.FormInput('确认密码', '再次输入密码', this.vm.confirmPassword, true, (text: string) => {
        this.vm.confirmPassword = text;
      })
      Text('用户名唯一、密码 8-20 位含字母和数字、两次一致，由服务端校验后返回')
        .fontSize(Theme.FONT_CAPTION)
        .fontColor(Theme.TEXT_LIGHT)
        .opacity(0.8)
        .width('100%')
    }
    .width('100%')
  }

  @Builder
  SubmitButton() {
    Button(this.vm.loading ? '提交中...' : '创建账号')
      .width('100%')
      .height(46)
      .backgroundColor(Theme.PRIMARY)
      .fontColor(Color.White)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .borderRadius(23)
      .margin({ top: 24 })
      .enabled(!this.vm.loading)
      .opacity(this.vm.loading ? 0.6 : 1)
      .onClick(() => {
        this.handleRegister();
      })
  }

  @Builder
  BackLoginLink() {
    Text('返回登录')
      .fontSize(14)
      .fontColor(Theme.TEXT_LIGHT)
      .width('100%')
      .textAlign(TextAlign.Center)
      .margin({ top: 16 })
      .onClick(() => {
        this.onBackToLogin();
      })
  }

  @Builder
  BottomNote() {
    Text('注册成功后返回登录页登录 · 账号信息提交服务端保存')
      .fontSize(Theme.FONT_CAPTION)
      .fontColor(Theme.TEXT_LIGHT)
      .opacity(0.75)
      .width('100%')
      .textAlign(TextAlign.Center)
      .margin({ top: 34 })
  }

  private handleRegister(): void {
    const prompt = this.getUIContext().getPromptAction();
    this.vm.register().then((msg: string) => {
      if (msg !== '') {
        prompt.showToast({ message: msg });
        return;
      }
      prompt.showToast({ message: '注册成功，请登录' });
      this.onRegistered();
    });
  }
}
