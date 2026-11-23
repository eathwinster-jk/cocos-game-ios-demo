// iOS Demo 场景入口，iOS 27 起宿主必须采用 UIScene 生命周期。
#pragma once

#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property(nonatomic, strong) UIWindow *window;

@end
