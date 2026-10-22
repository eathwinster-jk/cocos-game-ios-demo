// iOS Demo 测试环境配置，与 Android Demo 保持一致。
#pragma once

#import <Foundation/Foundation.h>

static NSString *const DemoGameWebsocketURL = @"wss://test.imnono.net/game-ws/ws";
static NSString *const DemoGameAPIURL = @"https://test.imnono.net/game-lobby";
static NSString *const DemoLoginAPIURL = @"https://test2.kzb001.net/prod-api/login";
static NSString *const DemoLoginPid = @"4";
static NSString *const DemoLoginVersion = @"1.120";
static NSString *const DemoLoginUserAgent = @"cocos-game-sdk-demo/1.120";
static NSString *const DemoLoginAppType = @"1";
static NSString *const DemoLoginCountryCode = @"86";
static NSString *const DemoDefaultSceneId = @"0999000015";
static const NSInteger DemoDefaultSceneType = 2;
static const NSTimeInterval DemoRequestTimeoutSeconds = 20;
