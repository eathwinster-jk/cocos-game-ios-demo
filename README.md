# Cocos Game iOS Demo

iOS 宿主接入 `CocosGameSDK` 的示例工程，演示登录、创建会话、在宿主页面容器中打开牛牛、全屏切换、迷你条、竖屏宿主自绘下注/记录/退出确认流程、游客观战。工程只包含宿主示例代码，SDK 通过 Swift Package Manager 远程依赖 [cocos-game-ios-sdk](https://github.com/eathwinster-jk/cocos-game-ios-sdk) 0.2.2。

- 接入文档：https://eathwinster-jk.github.io/cocos-game-ios-docs/

## 环境要求

- Xcode 16 及以上
- iOS 16.0 及以上
- 真机 arm64；模拟器 x86_64（工程已在模拟器下排除 arm64，Apple Silicon Mac 以 Rosetta 运行）

## 运行

1. 用 Xcode 打开 `CocosGameDemo.xcodeproj`，等待 Swift Package 解析完成。
2. 选择 `CocosGameDemo` scheme 与模拟器或真机（真机需在 Signing & Capabilities 中选择自己的 Team）。
3. 运行后输入测试账号、密码、Scene Type（1 直播间，2 IM 群）与 Scene ID，点击进入游戏；或点击「游客观战」免登录进入直播间。

命令行构建：

```bash
xcodebuild -project CocosGameDemo.xcodeproj -scheme CocosGameDemo \
  -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

## 目录

| 文件 | 说明 |
| --- | --- |
| `AppDelegate.m` | 创建窗口并初始化 SDK，按 SDK 返回的方向掩码控制旋转 |
| `MainViewController.m` | 登录页：账号密码登录后创建 `CocosGameSessionConfig`；游客入口用 `initGuestWithWebsocketURL:apiBaseURL:deviceId:sceneId:...` 创建游客会话 |
| `DemoViewController.m` | 游戏页：游戏容器、宿主内容示意、钱包余额、迷你条切换、SDK 回调处理 |
| `DemoHostBetPanel.h/.m` | 宿主自绘竖屏下注面板：注区、筹码、倒计时与下注结果 |
| `DemoHostRecordsSheet.h/.m` | 宿主自绘竖屏记录与规则弹窗：本桌记录、历史场次、规则、加载更多 |
| `DemoLoginClient.m` | 测试登录接口，换取 UID、IM UID 与 Token |
| `DemoConfig.h` | 测试环境地址、游客观战直播间 ID |

## 说明

- 账号密码登录仅用于 Demo，正式客户端必须复用自身登录体系，UID、Token、Scene Type、Scene ID 由宿主传入 SDK。
- 迷你条：点击「缩小为迷你条」先把容器约束切换为 362:50 横条，再调用 `setMiniMode:YES backgroundColorHex:`；玩家点击迷你条展开按钮时在 `gameSDKDidRequestExpand` 中恢复约束并调用 `setMiniMode:NO`。
- 竖屏宿主自绘：Demo 实现了 `gameSDKDidReceiveBetOptions:gameId:` 与 `gameSDKDidRequestShowRecords:gameId:`，竖屏下注与记录弹窗由宿主展示，下注调用 `submitBetWithRoundId:areaCode:amountCent:clientBetNo:`，记录查询调用 `queryRecordsIsHistory:...` / `loadMoreRecordsIsHistory:`；退出确认在 `gameSDKDidRequestExitWithCompletion:` 中由宿主弹框。全屏时三者都由游戏内弹窗展示。不实现这些可选回调时沿用 SDK 自带界面。
- 钱包余额：在 `gameSDKDidReceiveEvent:payloadJSON:gameId:` 中处理 `wallet.balance_changed` 事件（`balanceCent` 单位分）。
- 游客观战：游客仅限直播间（`sceneType=1`），以设备标识 `deviceId` 代替 UID/Token，只能观战、不显示余额。入座、查看记录、全屏时 SDK 发出 `auth.login_required` 事件（`payloadJSON` 中 `action` 为 `join` / `records` / `fullscreen`），游戏内不弹任何提示，由宿主提示登录；事件名可直接用 SDK 0.2.2 起提供的常量 `CocosGameEventLoginRequired`、`CocosGameEventWalletBalanceChanged`，`action` 取值对应 `CocosGameLoginActionJoin` / `CocosGameLoginActionRecords` / `CocosGameLoginActionFullscreen`。Demo 留在游戏页只弹提示框；正式接入可拉起登录页，登录成功后再 `[CocosGameSDK.shared close]` 并用登录态重新打开，不要在事件回调里直接关闭牌桌。
- `DemoConfig.h` 为测试环境地址，接入正式环境时替换为宿主自己的配置。
