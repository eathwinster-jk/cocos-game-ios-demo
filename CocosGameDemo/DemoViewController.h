// iOS Demo 宿主页面。
#pragma once

#import <UIKit/UIKit.h>

@class CocosGameSessionConfig;

@interface DemoViewController : UIViewController

/**
 * 使用登录后的大厅会话创建游戏页。
 */
- (instancetype)initWithSessionConfig:(CocosGameSessionConfig *)sessionConfig;

@end
