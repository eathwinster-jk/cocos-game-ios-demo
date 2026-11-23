// iOS Demo 场景入口：创建宿主窗口并初始化游戏 SDK。
#import "SceneDelegate.h"

#import <CocosGameSDK/CocosGameSDK.h>

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation SceneDelegate

/**
 * 场景连接时创建宿主窗口，并用该窗口初始化游戏 SDK。
 */
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:UIWindowScene.class]) return;
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    ((AppDelegate *)UIApplication.sharedApplication.delegate).window = self.window;
    [[CocosGameSDK shared] initializeWithWindow:self.window launchOptions:nil];
    [self.window makeKeyAndVisible];
}

@end
