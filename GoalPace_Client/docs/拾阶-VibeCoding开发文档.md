# 拾阶 · Vibe Coding 开发文档 v1.1

> 目标：14 屏 HarmonyOS APP + Spring Boot 后端。原型稿共 21 页，S1–S14 为 14 屏。**本文档为实现约束，优先级高于原型 PDF；页面文案以《拾阶-原型稿对齐修订清单》为准。**

## 0. 总纲与红线

- **架构（方案 B · 前后端分离，已确认）**：MySQL 8 是唯一数据源。业务数据全部经 `@ohos.net.http` 走后端；客户端 `@ohos.data.relationalStore` 仅作本地缓存 / 离线镜像，`@ohos.data.preferences` 仅存登录态、userId、提醒偏好。原型附录 B 的「数据仅存本机 / 本地账号校验 / 不上传云端」及 S1、S12、S8、S11 对应文案按修订清单改写。
- **缓存红线（防回退）**：RelationalStore 不得作为业务判定依据。登录必须 `POST /api/auth/login` 由服务端校验；积分、目标进度、连续打卡一律以服务端返回为准；所有增删改先 HTTP 成功、再回刷缓存。**把 RelationalStore 当主存储 = 回退方案 A，视为不合规。**
- **禁止**：第三方 UI / 图表库；合并 S9（复盘笔记 → review_notes）与 S14（任务表单 → tasks）；积分兑换消费；注册后自动登录；修改账号；改密后保持登录态；V1/V2 装饰器混用。
- **视觉基线**：375×812；暖米底 `#F8F6F2`；主色鼠尾草青 `#6BA8A0`、深青 `#3F7570`；白卡 16px 圆角；Noto Sans SC；底部胶囊四 Tab（今日 / 目标 / 统计 / 我的）；青绿描边线性图标。优先级色：高红、中黄、低灰。

## 1. 前端 `E:\GoalPace\GoalPace_Client`

Stage 模型 + ArkTS + 声明式 ArkUI，**全站统一状态管理 V2（API 12+）**，页面组件一律 `@ComponentV2`。

**MVVM 三层**：View 为 `@ComponentV2` 组件，只消费 ViewModel 并渲染，不发请求、不做业务计算；ViewModel 为 `@ObservedV2` 类，`@Trace` 字段持有状态与事件，组件内局部状态用 `@Local`，父子传参 `@Param`（+`@Once`）、子回调 `@Event`、跨层 `@Provider/@Consumer`、监听 `@Monitor`、派生值 `@Computed`；Model 含 `HttpUtil`（`@ohos.net.http`，统一解析 Result 与错误 Toast）、`Prefs`（preferences）、`Cache`（relationalStore，五张缓存表）、Entity / DTO 映射。

**V2 硬约束**：`@ComponentV2` 组件内禁止出现 V1 装饰器（`@State/@Prop/@Link/@ObjectLink/@Provide/@Consume/@Watch/@Observed/@Track`）；`@ObservedV2` 不与 V1 装饰器共存，且必须配 `@Trace` 才能观测属性；同一变量不叠多个装饰器（`@Once/@Require` 除外）；不与 V1 组件混用。

**其他原生能力**：`Navigation` 栈（S4/S5/S9/S10/S11/S13/S14 push 入栈）、`Tabs`（四主 Tab）；`List/Grid/Progress/Refresh/TextInput/DatePicker/TimePicker/Toggle`；`@ohos.reminderAgentManager`（任务到期 + 每日 19:00 打卡）；`@ohos.multimedia.imagePicker`（S11 头像，选图后经 HTTP 上传）。目录 `entry/src/main/ets/{pages,viewmodel,model,common,components}`，路由名常量化。

**统一交互**：保存后 pop 回来源页并刷新（HTTP 成功 → 回刷缓存 → `@Trace` 更新 → UI 重绘）；删除走列表行长按；勾选完成弹 +10/+15 微动效；请求带 loading + 失败 Toast；`Refresh` 下拉触发 `GET /sync?since=` 增量回刷；日期 `YYYY-MM-DD`。

## 2. 后端 `E:\GoalPace\GoalPace_Server`

Spring Boot 3.x / Java 17 / MyBatis-Plus 3.5.x / MySQL 8，端口 **8080**。分层 `Controller → Service → ServiceImpl → Mapper(MP BaseMapper) → Entity`，禁止跨层；Controller 只做校验与包装，业务逻辑与事务在 ServiceImpl。统一 `Result<T>{code,msg,data}`、`@RestControllerAdvice` 全局异常、CORS 放行前端、密码 BCrypt、逻辑删除、时间字段自动填充。

**表（服务端唯一真源，客户端缓存同名同构）**：`users(id,username,nickname,password,avatar,points,level,checkin_days)`；`goals(id,user_id,title,type,category,priority,start_date,end_date,description,remind_on,remind_time,archived,progress,update_time)`；`tasks(id,goal_id,title,due_date,due_time,priority,note,remind_on,remind_advance,status,update_time)`；`point_logs(id,user_id,change,reason,task_id,create_time)`；`review_notes(id,goal_id,content,create_time)`。

**业务规则（ServiceImpl）**：目标进度 = 已完成任务数 / 关联任务总数，任务保存或勾选后重算；积分 普通 +10 / 高优 +15 / 连打 7 天 +50 / 达成目标 +200，写 point_logs；连续打卡按自然日；积分仅「规则表 + 累计 + 展示」。

|                                              |                                     |      |     |                                     |                   |                   |                                                                      |                                                |                           |                    |                                                                             |
| -------------------------------------------- | ----------------------------------- | ---- | --- | ----------------------------------- | ----------------- | ----------------- | -------------------------------------------------------------------- | ---------------------------------------------- | ------------------------- | ------------------ | --------------------------------------------------------------------------- |
| **接口（/api，全部 Result 包装）**：\`POST /auth/login | register`、`PUT /auth/password`；`GET | POST | PUT | DELETE /goals`、`GET /goals/archived | /goals/{id}`；`GET | POST /tasks`、`PUT | DELETE /tasks/{id}`、`GET /tasks/today`、`PUT /tasks/{id}/toggle`；`GET | POST /reviews?goalId=`；`GET /stats?period=week | month`；`GET /points/rules | /points/logs`；`GET | PUT /users/profile`；`POST /users/avatar`；`GET /sync?since=`、`GET /export\`。 |

## 3. 模块与开发顺序（逐模块验收）

| 序  | 模块   | 页面             | 前端要点                                                                          | 后端                 | 验收                        |
| -- | ---- | -------------- | ----------------------------------------------------------------------------- | ------------------ | ------------------------- |
| M0 | 基建   | —              | V2 状态基类、Result/HttpUtil/Prefs/Cache、主题常量、Tab 壳                                | 统一返回、异常、CORS、sync  | 8080 联通，缓存可回刷             |
| M1 | 账号   | S1 S12 S13 S11 | 注册成功返 S1 不自动登录；账号只读；改密成功清登录态→S1；imagePicker 头像上传；登录走服务端校验                     | auth、users         | 注册→登录→改密→重登闭环             |
| M2 | 目标   | S3 S5 S4       | 筛选 chips / 已归档 / 进度条；编辑回填；S4 底部两按钮各自独立去向                                      | goals              | 新建→列表刷新→详情→编辑             |
| M3 | 任务   | S2 S6 S14      | 按目标分组、状态与优先级筛选；勾选触发服务端积分 + 进度重算并回刷缓存；S4 进入自动带入 goalId；长按删除；reminderAgent      | tasks、points       | S14→S2/S6 勾选→积分与统计同步      |
| M4 | 复盘激励 | S9 S10         | S9 与 S14 不合并，自由文本写 review_notes + 历史列表；S10 台阶等级、规则表、12 周热力图、徽章墙、明细（图表用原生组件绘制） | reviews、point_logs | 复盘落库、明细与流水一致              |
| M5 | 统计我的 | S7 S8          | 本周/本月切换、每日完成量柱状图、目标进度榜；四格概览、设置列表、备份导出走 /export、退出登录→S1                        | stats、users、export | 统计口径与 tasks/point_logs 一致 |

## 4. 跳转要点（附录 A）

未登录→S1→登录成功→S2（默认 Tab）；S1→S12 注册→成功返 S1（不自动登录）。S2 积分条→S10、查看全部→S6、➕→S14、Tab→S3/S7/S8。S3 卡片→S4、➕→S5、已归档→归档列表。S4 编辑→S5、＋添加任务→S14（带 goalId）、写复盘笔记→S9（带 goalId）、任务行→S14 编辑。S6 分组标题→S4、任务行 / ➕→S14。S8 编辑资料→S11、账号与密码→S13、累计积分→S10、退出登录→S1。S11 修改登录密码→S13；S13 成功→提示重新登录→S1；S7 进度榜→S4。S5/S9/S14 保存→pop 回来源页并刷新。

## 5. 总验收

14 屏可达且无死链；全站 `@ComponentV2` 且无 V1 装饰器、无 V1/V2 混用；RelationalStore 仅为缓存，可由服务端重建；后端分层与统一 Result；前后端 8080 联调通过；积分、进度、连续打卡三处口径一致；退出与改密清理登录态；原型冲突文案已按修订清单对齐。
