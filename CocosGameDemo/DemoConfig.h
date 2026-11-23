// iOS Demo 测试环境配置，与 Android Demo 保持一致。
#pragma once

#import <Foundation/Foundation.h>

static NSString *const DemoGameWebsocketURL = @"wss://test.imnono.net/game-ws/ws";
static NSString *const DemoGameAPIURL = @"https://test.imnono.net/game-lobby";
// 游客观战示例固定使用测试直播间号（群聊游客同样支持）。
static NSString *const DemoGuestSceneId = @"3947124";
// 游戏模块热更新版本清单地址（0.7.0 起 SDK 不内置游戏，必须配置）。
static NSString *const DemoModuleCatalogURL = @"https://cocos-game-modules.pages.dev/ios/catalog.json";
// 版本清单签名公钥（EC P-256，X.509 DER 的 Base64），SDK 用它校验清单未被篡改。
static NSString *const DemoModuleCatalogPublicKey = @"MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAErTdV8F92qHswr8ysK3qdPAlCSlOGceiYNZu02CJbHkGYFCbrUg/+TNJDPQNt+nSyS6oM9KIkh7o3+t2DcsyQuA==";
// 启动后预下载的游戏模块，用户进入游戏时无需等待下载。
static NSString *const DemoPreloadGameId = @"niuniu";
static NSString *const DemoLoginAPIURL = @"https://test2.kzb001.net/prod-api/login";
static NSString *const DemoLoginPid = @"4";
static NSString *const DemoLoginVersion = @"1.120";
static NSString *const DemoLoginUserAgent = @"cocos-game-sdk-demo/1.120";
static NSString *const DemoLoginAppType = @"1";
static NSString *const DemoLoginCountryCode = @"86";
static NSString *const DemoDefaultSceneId = @"0999000015";
static const NSInteger DemoDefaultSceneType = 2;
static const NSTimeInterval DemoRequestTimeoutSeconds = 20;
