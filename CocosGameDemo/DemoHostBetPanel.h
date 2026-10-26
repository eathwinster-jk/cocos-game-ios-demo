// 演示宿主自绘竖屏下注界面：接收下注选项、截止和结果，通过 submitBet 提交。
#import <UIKit/UIKit.h>

#import <CocosGameSDK/CocosGameSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoHostBetPanel : UIView

/**
 * 本局进入下注阶段，展示注区、筹码与倒计时。
 */
- (void)showOptions:(CocosGameBetOptions *)options;

/**
 * 本局下注截止，收起注区与筹码。
 */
- (void)closeRound:(NSString *)roundId;

/**
 * 展示下注提交结果。
 */
- (void)showResult:(CocosGameBetResult *)result;

@end

NS_ASSUME_NONNULL_END
