// iOS Demo 宿主应用入口，只通过 SDK 公共接口接入游戏。
#import "AppDelegate.h"

#import <CocosGameHotUpdate/CocosGameHotUpdate.h>
#import <CocosGameSDK/CocosGameSDK.h>

#import "DemoConfig.h"
#import "MainViewController.h"

@interface AppDelegate () <CocosGameHotUpdateDelegate>
@property(nonatomic, strong) CocosGameHotUpdate *hotUpdate;
@end

@implementation AppDelegate

/**
 * 创建宿主窗口，初始化游戏 SDK 并开启游戏模块热更新（首次打开游戏时下载模块）。
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    MainViewController *mainViewController = [[MainViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    [[CocosGameSDK shared] initializeWithWindow:self.window launchOptions:launchOptions];
    self.hotUpdate = [CocosGameHotUpdate installWithCatalogURL:[NSURL URLWithString:DemoModuleCatalogURL]];
    self.hotUpdate.delegate = self;
    [self.window makeKeyAndVisible];
    return YES;
}

/**
 * 游戏模块热更新进度，新版本下次打开生效，Demo 只打印日志。
 */
- (void)gameHotUpdateDidUpdateGame:(NSString *)gameId state:(NSString *)state receivedBytes:(NSUInteger)receivedBytes totalBytes:(NSUInteger)totalBytes {
    NSLog(@"CocosGameDemo 模块更新 %@ %@ %lu/%lu", gameId, state, (unsigned long)receivedBytes, (unsigned long)totalBytes);
}

/**
 * 游戏模块热更新失败，不影响本次游戏。
 */
- (void)gameHotUpdateDidFailUpdateGame:(NSString *)gameId code:(NSInteger)code message:(NSString *)message {
    NSLog(@"CocosGameDemo 模块更新失败 %@ code=%ld %@", gameId, (long)code, message);
}

/**
 * 根据 SDK 当前页面限制宿主界面方向。
 */
- (UIInterfaceOrientationMask)application:(UIApplication *)application
    supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return CocosGameSDK.shared.preferredOrientationMask;
}

@end
