// iOS Demo 宿主应用入口，只通过 SDK 公共接口接入游戏。
#import "AppDelegate.h"

#import <CocosGameSDK/CocosGameSDK.h>

#import "MainViewController.h"

@implementation AppDelegate

/**
 * 创建宿主窗口并初始化游戏 SDK。
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    [[CocosGameSDK shared] initializeWithWindow:self.window launchOptions:launchOptions];
    [self.window makeKeyAndVisible];
    return YES;
}

/**
 * 根据 SDK 当前页面限制宿主界面方向。
 */
- (UIInterfaceOrientationMask)application:(UIApplication *)application
    supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return CocosGameSDK.shared.preferredOrientationMask;
}

@end
