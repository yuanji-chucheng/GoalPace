import { Theme } from '../common/Theme';
import { MainShell } from './MainShell';
import { LoginPage } from './LoginPage';
import { RegisterPage } from './RegisterPage';
import { AppSession } from '../viewmodel/Session';

/**
 * 应用入口: 未登录 → S1 登录; 登录成功 → S2 今日(默认 Tab)
 */
@Entry
@ComponentV2
struct App {
  @Local session: AppSession = AppSession.inst;
  @Local showRegister: boolean = false;

  aboutToAppear(): void {
    this.session.boot();
  }

  build() {
    Column() {
      if (!this.session.booted) {
        this.SplashScreen()
      } else if (this.session.logged) {
        MainShell()
      } else if (this.showRegister) {
        RegisterPage({
          onBackToLogin: () => {
            this.showRegister = false;
          },
          onRegistered: () => {
            this.showRegister = false;
          }
        })
      } else {
        LoginPage({
          onGoRegister: () => {
            this.showRegister = true;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  SplashScreen() {
    Column({ space: 14 }) {
      Column() {
        Text('阶')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
      }
      .width(66)
      .height(66)
      .borderRadius(18)
      .backgroundColor(Theme.PRIMARY)
      .justifyContent(FlexAlign.Center)

      Text('拾阶')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.TEXT)
      Text('一步一步，拾级而上')
        .fontSize(13)
        .fontColor(Theme.TEXT_LIGHT)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
