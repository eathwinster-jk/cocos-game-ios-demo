# Cocos Game iOS Demo

iOS 宿主接入 `CocosGameSDK` 的示例工程，演示登录、创建会话、在宿主页面容器中打开牛牛、全屏切换与退出流程。工程只包含宿主示例代码，SDK 通过 Swift Package Manager 远程依赖 [cocos-game-ios-sdk](https://github.com/eathwinster-jk/cocos-game-ios-sdk) 0.1.10。

- 接入文档：https://eathwinster-jk.github.io/cocos-game-ios-docs/

## 环境要求

- Xcode 16 及以上
- iOS 16.0 及以上
- 真机 arm64；模拟器 x86_64（工程已在模拟器下排除 arm64，Apple Silicon Mac 以 Rosetta 运行）

## 运行

1. 用 Xcode 打开 `CocosGameDemo.xcodeproj`，等待 Swift Package 解析完成。
2. 选择 `CocosGameDemo` scheme 与模拟器或真机（真机需在 Signing & Capabilities 中选择自己的 Team）。
3. 运行后输入测试账号、密码、Scene Type（1 直播间，2 IM 群）与 Scene ID，点击进入游戏。

命令行构建：

```bash
xcodebuild -project CocosGameDemo.xcodeproj -scheme CocosGameDemo \
  -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

## 目录

| 文件 | 说明 |
| --- | --- |
| `AppDelegate.m` | 创建窗口并初始化 SDK，按 SDK 返回的方向掩码控制旋转 |
| `MainViewController.m` | 登录页：账号密码登录后创建 `CocosGameSessionConfig` |
| `DemoViewController.m` | 游戏页：游戏容器、宿主内容示意、SDK 回调处理 |
| `DemoLoginClient.m` | 测试登录接口，换取 UID、IM UID 与 Token |
| `DemoConfig.h` | 测试环境地址 |

## 说明

- 账号密码登录仅用于 Demo，正式客户端必须复用自身登录体系，UID、Token、Scene Type、Scene ID 由宿主传入 SDK。
- `DemoConfig.h` 为测试环境地址，接入正式环境时替换为宿主自己的配置。
