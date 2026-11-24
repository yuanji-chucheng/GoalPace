import { Theme } from '../common/Theme';
import { TodayPage } from './TodayPage';
import { GoalsPage } from './GoalsPage';
import { StatsPage } from './StatsPage';
import { ProfilePage } from './ProfilePage';

/**
 * 主壳: Navigation 栈 + 底部胶囊四 Tab(今日 / 目标 / 统计 / 我的)
 */
@ComponentV2
export struct MainShell {
  pathStack: NavPathStack = new NavPathStack();
  @Local tabIdx: number = 0;
  private tabsController: TabsController = new TabsController();

  build() {
    Navigation(this.pathStack) {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ controller: this.tabsController }) {
          TabContent() {
            TodayPage({ navStack: this.pathStack })
          }
          TabContent() {
            GoalsPage({ navStack: this.pathStack })
          }
          TabContent() {
            StatsPage({ navStack: this.pathStack })
          }
          TabContent() {
            ProfilePage({ navStack: this.pathStack })
          }
        }
        .barHeight(0)
        .scrollable(false)
        .width('100%')
        .height('100%')
        .onChange((index: number) => {
          this.tabIdx = index;
        })

        Row() {
          this.TabItem(0, $r('app.media.ic_today'), $r('app.media.ic_today_on'), '今日')
          this.TabItem(1, $r('app.media.ic_goal'), $r('app.media.ic_goal_on'), '目标')
          this.TabItem(2, $r('app.media.ic_stat'), $r('app.media.ic_stat_on'), '统计')
          this.TabItem(3, $r('app.media.ic_mine'), $r('app.media.ic_mine_on'), '我的')
        }
        .width('92%')
        .height(58)
        .backgroundColor(Theme.CARD)
        .borderRadius(29)
        .margin({ bottom: 14 })
        .shadow({ radius: 20, color: 'rgba(63,117,112,0.16)', offsetY: -4 })
      }
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  TabItem(idx: number, icon: Resource, iconOn: Resource, label: string) {
    Column({ space: 3 }) {
      Image(this.tabIdx === idx ? iconOn : icon)
        .width(22)
        .height(22)
        .fillColor(this.tabIdx === idx ? Theme.PRIMARY : Theme.TEXT_LIGHT)
      Text(label)
        .fontSize(11)
        .fontWeight(this.tabIdx === idx ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.tabIdx === idx ? Theme.PRIMARY_DEEP : Theme.TEXT_LIGHT)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.tabIdx !== idx) {
        this.tabsController.changeIndex(idx);
      }
    })
  }
}
