import { Theme } from '../common/Theme';

/**
 * 二级页标题栏: 返回 + 标题 + 右侧操作
 */
@ComponentV2
export struct NavHeader {
  @Param stack: NavPathStack = new NavPathStack();
  @Param headerTitle: string = '';
  @Param headerActionText: string = '';
  @Event onHeaderAction: () => void = () => {
  };

  build() {
    Row() {
      Text('<')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT)
        .width(36)
        .height(36)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.stack.pop();
        })
      Text(this.headerTitle)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.TEXT)
        .layoutWeight(1)
      if (this.headerActionText !== '') {
        Text(this.headerActionText)
          .fontSize(14)
          .fontColor(Theme.PRIMARY_DEEP)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .onClick(() => {
            this.onHeaderAction();
          })
      }
    }
    .width('100%')
    .height(48)
    .padding({ left: 12, right: 14 })
    .backgroundColor(Theme.CARD)
  }
}

/**
 * 筛选胶囊组
 */
@ComponentV2
export struct ChipRow {
  @Param labels: string[] = [];
  @Param selected: number = 0;
  @Event onChipSelect: (index: number) => void = (index: number) => {
  };

  build() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.labels, (label: string, idx: number) => {
          Text(label)
            .fontSize(13)
            .fontColor(this.selected === idx ? Theme.PRIMARY_DEEP : Theme.TEXT_LIGHT)
            .fontWeight(this.selected === idx ? FontWeight.Medium : FontWeight.Normal)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .backgroundColor(this.selected === idx ? Theme.PRIMARY_SOFT : Theme.CARD)
            .borderRadius(16)
            .onClick(() => {
              this.onChipSelect(idx);
            })
        }, (label: string, idx: number) => label + '_' + idx.toString())
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
  }
}

/**
 * 空态占位
 */
@ComponentV2
export struct EmptyView {
  @Param emptyIcon: string = '⛰';
  @Param emptyTitle: string = '暂无数据';
  @Param emptyHint: string = '';

  build() {
    Column({ space: 8 }) {
      Text(this.emptyIcon)
        .fontSize(40)
        .fontColor(Theme.PRIMARY)
        .opacity(0.5)
      Text(this.emptyTitle)
        .fontSize(Theme.FONT_BODY)
        .fontColor(Theme.TEXT_LIGHT)
      if (this.emptyHint !== '') {
        Text(this.emptyHint)
          .fontSize(Theme.FONT_CAPTION)
          .fontColor(Theme.TEXT_LIGHT)
          .opacity(0.8)
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding({ top: 44, bottom: 44 })
    .borderRadius(Theme.RADIUS)
    .backgroundColor(Theme.CARD)
    .justifyContent(FlexAlign.Center)
  }
}

/**
 * 优先级标签
 */
@ComponentV2
export struct PriorityTag {
  @Param level: number = 2;

  build() {
    Text(Theme.priorityLabel(this.level))
      .fontSize(11)
      .fontColor(Color.White)
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      .backgroundColor(Theme.priorityColor(this.level))
      .borderRadius(8)
  }
}

/**
 * 进度条
 */
@ComponentV2
export struct ProgressTrack {
  @Param percent: number = 0;
  @Param trackColor: string = Theme.PRIMARY;

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Row()
        .width('100%')
        .height(8)
        .backgroundColor(Theme.TRACK)
        .borderRadius(4)
      Row()
        .width(Math.min(100, Math.max(0, this.percent)).toString() + '%')
        .height(8)
        .backgroundColor(this.trackColor)
        .borderRadius(4)
    }
    .width('100%')
  }
}

/**
 * 加载遮罩
 */
@ComponentV2
export struct LoadingOverlay {
  @Param visible: boolean = false;

  build() {
    if (this.visible) {
      Column({ space: 10 }) {
        LoadingProgress()
          .width(38)
          .height(38)
          .color(Theme.PRIMARY)
        Text('加载中...')
          .fontSize(13)
          .fontColor(Theme.TEXT_LIGHT)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(248,246,242,0.88)')
      .position({ x: 0, y: 0 })
    }
  }
}

/**
 * 表单字段标题
 */
@ComponentV2
export struct FieldLabel {
  @Param label: string = '';
  @Param required: boolean = false;

  build() {
    Row({ space: 3 }) {
      if (this.required) {
        Text('*')
          .fontSize(14)
          .fontColor(Theme.DANGER)
      }
      Text(this.label)
        .fontSize(13)
        .fontColor(Theme.TEXT_LIGHT)
    }
  }
}
