/**
 * 跨页刷新总线: 二级页增删改成功后 bump, 主 Tab 页 @Monitor 感知后重拉数据
 */
@ObservedV2
export class Bus {
  private static sole: Bus | null = null;

  static get inst(): Bus {
    if (Bus.sole === null) {
      Bus.sole = new Bus();
    }
    return Bus.sole;
  }

  @Trace goalsTick: number = 0;
  @Trace tasksTick: number = 0;
  @Trace userTick: number = 0;

  private constructor() {
  }

  bumpGoals(): void {
    this.goalsTick++;
  }

  bumpTasks(): void {
    this.tasksTick++;
  }

  bumpUser(): void {
    this.userTick++;
  }
}
