// iOS Demo 宿主应用入口，只通过 SDK 公共接口接入游戏。
#import "AppDelegate.h"

#import <CocosGameHotUpdate/CocosGameHotUpdate.h>
#import <CocosGameSDK/CocosGameSDK.h>

#import "DemoConfig.h"
#import "SceneDelegate.h"

@interface AppDelegate () <CocosGameHotUpdateDelegate>
@property(nonatomic, strong) CocosGameHotUpdate *hotUpdate;
@end

@implementation AppDelegate

/**
 * 开启游戏模块热更新（校验清单签名）并预下载游戏模块；窗口与 SDK 初始化在 SceneDelegate 中完成。
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.hotUpdate = [CocosGameHotUpdate installWithCatalogURL:[NSURL URLWithString:DemoModuleCatalogURL]
                                              catalogPublicKey:DemoModuleCatalogPublicKey];
    if (!self.hotUpdate) {
        NSLog(@"CocosGameDemo 热更新开启失败：清单公钥格式错误");
        return YES;
    }
    self.hotUpdate.delegate = self;
    [self.hotUpdate preloadGameId:DemoPreloadGameId];
    return YES;
}

/**
 * 为新场景指定 SceneDelegate（iOS 27 起宿主必须采用 UIScene 生命周期）。
 */
- (UISceneConfiguration *)application:(UIApplication *)application
    configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                                   options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default"
                                                                         sessionRole:connectingSceneSession.role];
    configuration.delegateClass = SceneDelegate.class;
    return configuration;
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
