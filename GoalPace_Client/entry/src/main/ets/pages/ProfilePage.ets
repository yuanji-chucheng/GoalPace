import { Theme } from '../common/Theme';
import { Bus } from '../common/Bus';
import { ProfileVm } from '../viewmodel/MiscVms';
import { AppSession } from '../viewmodel/Session';
import { Exporter } from '../model/Exporter';
import { Http } from '../model/Http';
import { ReviewParam } from '../model/Models';

/**
 * S8 我的: 用户卡 + 四格概览 + 设置列表(资料/复盘/积分/改密/备份/提醒) + 退出登录
 */
@ComponentV2
export struct ProfilePage {
  @Param navStack: NavPathStack = new NavPathStack();
  @Local vm: ProfileVm = new ProfileVm();
  @Local session: AppSession = AppSession.inst;
  @Local bus: Bus = Bus.inst;

  aboutToAppear(): void {
    this.vm.refresh();
  }

  @Monitor('bus.userTick')
  onUserTick(): void {
    this.vm.refresh();
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 12 }) {
          this.HeaderBar()
          this.UserCard()
          this.MenuCard()
          this.RemindCard()
          this.LogoutButton()
          Text('账号信息由服务端安全管理，客户端只读展示')
            .fontSize(11)
            .fontColor(Theme.TEXT_LIGHT)
            .opacity(0.75)
            .margin({ top: 6 })
        }
        .width('100%')
        .padding({ left: 18, right: 18, bottom: 130 })
        .alignItems(HorizontalAlign.Start)
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  HeaderBar() {
    Text('我的')
      .fontSize(21)
      .fontWeight(FontWeight.Bold)
      .fontColor(Theme.TEXT)
      .width('100%')
      .padding({ top: 16, bottom: 4 })
  }

  @Builder
  UserCard() {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        if (this.session.user.avatar !== '') {
          Image(Http.assetUrl(this.session.user.avatar))
            .width(58)
            .height(58)
            .borderRadius(29)
            .backgroundColor(Theme.TRACK)
        } else {
          Column() {
            Text(this.avatarChar())
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .width(58)
          .height(58)
          .borderRadius(29)
          .backgroundColor(Theme.PRIMARY)
          .justifyContent(FlexAlign.Center)
        }

        Column({ space: 5 }) {
          Text(this.session.user.nickname === ''
            ? this.session.user.username : this.session.user.nickname)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.TEXT)
          Text('@' + this.session.user.username)
            .fontSize(12)
            .fontColor(Theme.TEXT_LIGHT)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('Lv.' + this.session.user.level.toString())
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.PRIMARY_DEEP)
          .padding({ left: 12, right: 12, top: 5, bottom: 5 })
          .backgroundColor(Theme.PRIMARY_SOFT)
          .borderRadius(14)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {
        this.StatCell(this.session.user.points.toString(), '积分')
        this.StatCell(this.session.user.level.toString(), '等级')
        this.StatCell(this.session.user.checkinDays.toString(), '连续打卡(天)')
        this.StatCell(this.vm.goalCount.toString(), '目标数')
      }
      .width('100%')
      .padding({ top: 13, bottom: 13 })
      .borderRadius(Theme.RADIUS_SM)
      .backgroundColor(Theme.BG)
    }
    .width('100%')
    .padding(16)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  StatCell(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.PRIMARY_DEEP)
      Text(label)
        .fontSize(10)
        .fontColor(Theme.TEXT_LIGHT)
    }
    .layoutWeight(1)
  }

  @Builder
  MenuCard() {
    Column() {
      this.MenuRow('👤', '编辑资料', () => {
        this.navStack.pushPathByName('editProfile', '');
      })
      this.MenuDivider()
      this.MenuRow('📝', '复盘笔记', () => {
        this.navStack.pushPathByName('review', new ReviewParam(0));
      })
      this.MenuDivider()
      this.MenuRow('✦', '积分与徽章', () => {
        this.navStack.pushPathByName('points', '');
      })
      this.MenuDivider()
      this.MenuRow('🔐', '修改密码', () => {
        this.navStack.pushPathByName('changePassword', '');
      })
      this.MenuDivider()
      this.MenuRow('📦', '备份导出', () => {
        this.handleExport();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
  }

  @Builder
  MenuRow(icon: string, label: string, onTap: () => void) {
    Row() {
      Text(icon)
        .fontSize(16)
        .width(30)
      Text(label)
        .fontSize(14)
        .fontColor(Theme.TEXT)
        .layoutWeight(1)
      Text('›')
        .fontSize(18)
        .fontColor(Theme.TEXT_LIGHT)
    }
    .width('100%')
    .height(50)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      onTap();
    })
  }

  @Builder
  MenuDivider() {
    Row()
      .width('100%')
      .height(0.6)
      .backgroundColor(Theme.DIVIDER)
  }

  @Builder
  RemindCard() {
    Row() {
      Text('🔔')
        .fontSize(16)
        .width(30)
      Column({ space: 3 }) {
        Text('每日打卡提醒')
          .fontSize(14)
          .fontColor(Theme.TEXT)
        Text('每天 19:00 提醒我完成今日任务')
          .fontSize(11)
          .fontColor(Theme.TEXT_LIGHT)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Toggle({ type: ToggleType.Switch, isOn: this.vm.remindOn })
        .selectedColor(Theme.PRIMARY)
        .onChange((isOn: boolean) => {
          this.vm.setRemind(isOn);
        })
    }
    .width('100%')
    .padding(16)
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  LogoutButton() {
    Button('退出登录')
      .width('100%')
      .height(46)
      .backgroundColor(Color.Transparent)
      .fontColor(Theme.DANGER)
      .fontSize(15)
      .borderRadius(Theme.RADIUS)
      .border({ width: 1, color: Theme.DANGER })
      .margin({ top: 6 })
      .onClick(() => {
        this.confirmLogout();
      })
  }

  private avatarChar(): string {
    const name = this.session.user.nickname === ''
      ? this.session.user.username : this.session.user.nickname;
    return name === '' ? '阶' : name.substring(0, 1);
  }

  private handleExport(): void {
    const prompt = this.getUIContext().getPromptAction();
    Exporter.exportBackup().then((msg: string) => {
      if (msg !== '') {
        prompt.showToast({ message: msg });
      }
    }).catch(() => {
      prompt.showToast({ message: '导出失败，请检查网络或稍后重试' });
    });
  }

  private confirmLogout(): void {
    AlertDialog.show({
      title: '退出登录',
      message: '确定要退出当前账号吗？本地缓存将被清理。',
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '退出',
        fontColor: Theme.DANGER,
        action: () => {
          AppSession.inst.logout();
        }
      }
    });
  }
}
