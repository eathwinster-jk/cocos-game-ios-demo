// 演示宿主自绘竖屏「记录与规则」：接收规则与记录 JSON，切换页签或加载更多时调用 SDK 查询。
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoHostRecordsSheet : UIViewController

/**
 * 使用规则 JSON（含 records 字段）创建弹窗。
 */
- (instancetype)initWithRulesJSON:(NSString *)rulesJSON;

/**
 * 用最新记录快照整体替换并刷新。
 */
- (void)updateRecordsJSON:(NSString *)recordsJSON;

@end

NS_ASSUME_NONNULL_END
