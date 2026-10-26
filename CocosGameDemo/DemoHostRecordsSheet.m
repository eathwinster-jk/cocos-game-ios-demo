// 演示宿主记录与规则弹窗实现。
#import "DemoHostRecordsSheet.h"

#import <CocosGameSDK/CocosGameSDK.h>

typedef NS_ENUM(NSInteger, DemoRecordsTab) {
    DemoRecordsTabCurrent,
    DemoRecordsTabHistory,
    DemoRecordsTabRules,
};

@interface DemoHostRecordsSheet ()

@property(nonatomic, copy) NSDictionary *rules;
@property(nonatomic, copy, nullable) NSDictionary *records;
@property(nonatomic) DemoRecordsTab selectedTab;
@property(nonatomic, strong) UIStackView *tabRow;
@property(nonatomic, strong) UIStackView *content;

@end

@implementation DemoHostRecordsSheet

/**
 * 解析规则 JSON 并创建页面。
 */
- (instancetype)initWithRulesJSON:(NSString *)rulesJSON {
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    _rules = [self parseJSON:rulesJSON] ?: @{};
    _records = [self dictionaryIn:_rules key:@"records"];
    _selectedTab = DemoRecordsTabCurrent;
    self.modalPresentationStyle = UIModalPresentationPageSheet;
    return self;
}

/**
 * 创建页签行与可滚动内容。
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    if (@available(iOS 15.0, *)) {
        self.sheetPresentationController.detents = @[UISheetPresentationControllerDetent.mediumDetent, UISheetPresentationControllerDetent.largeDetent];
    }
    self.tabRow = [self createStackWithAxis:UILayoutConstraintAxisHorizontal];
    self.tabRow.spacing = 16;
    self.content = [self createStackWithAxis:UILayoutConstraintAxisVertical];
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [scrollView addSubview:self.content];
    [self.view addSubview:self.tabRow];
    [self.view addSubview:scrollView];
    [self activateLayoutWithScrollView:scrollView];
    [self render];
}

/**
 * 页签在顶部，内容区铺满其余空间。
 */
- (void)activateLayoutWithScrollView:(UIScrollView *)scrollView {
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.tabRow.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:16],
        [self.tabRow.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [scrollView.topAnchor constraintEqualToAnchor:self.tabRow.bottomAnchor constant:8],
        [scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [scrollView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor],
        [self.content.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor],
        [self.content.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor],
        [self.content.leadingAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.leadingAnchor],
        [self.content.widthAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.widthAnchor],
    ]];
}

/**
 * 用最新记录快照刷新。
 */
- (void)updateRecordsJSON:(NSString *)recordsJSON {
    NSDictionary *records = [self parseJSON:recordsJSON];
    if (!records) return;
    self.records = records;
    if (self.isViewLoaded) [self render];
}

/**
 * 按当前页签渲染。
 */
- (void)render {
    [self renderTabs];
    for (UIView *view in self.content.arrangedSubviews) [view removeFromSuperview];
    if (self.selectedTab == DemoRecordsTabRules) [self renderRules];
    else if (!self.records) [self addLine:@"暂无记录" size:14 color:UIColor.secondaryLabelColor];
    else [self renderRecords:self.selectedTab == DemoRecordsTabHistory];
}

/**
 * 渲染页签：本桌记录、历史场次、规则。
 */
- (void)renderTabs {
    for (UIView *view in self.tabRow.arrangedSubviews) [view removeFromSuperview];
    NSArray<NSString *> *titles = @[
        [self stringIn:self.records key:@"currentTab"],
        [self stringIn:self.records key:@"historyTab"],
        [self stringIn:self.rules key:@"title"],
    ];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger index, __unused BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = (NSInteger)index;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:index == (NSUInteger)self.selectedTab ? UIColor.systemTealColor : UIColor.secondaryLabelColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabRow addArrangedSubview:button];
    }];
}

/**
 * 切换页签，记录页签按默认条件重新查询。
 */
- (void)selectTab:(UIButton *)button {
    self.selectedTab = (DemoRecordsTab)button.tag;
    if (self.selectedTab != DemoRecordsTabRules) {
        [CocosGameSDK.shared queryRecordsIsHistory:self.selectedTab == DemoRecordsTabHistory filterKey:@"all" periodIndex:0 keyword:nil];
    }
    [self render];
}

/**
 * 渲染本桌记录或历史场次，以及加载状态。
 */
- (void)renderRecords:(BOOL)isHistory {
    NSDictionary *section = [self dictionaryIn:self.records key:isHistory ? @"history" : @"current"];
    if (!section) return;
    [self addLine:[self stringIn:section key:@"banner"] size:13 color:UIColor.secondaryLabelColor];
    NSArray *rows = [section[isHistory ? @"sessions" : @"items"] isKindOfClass:NSArray.class] ? section[isHistory ? @"sessions" : @"items"] : @[];
    for (NSDictionary *row in rows) {
        if (![row isKindOfClass:NSDictionary.class]) continue;
        NSString *value = [self stringIn:row key:isHistory ? @"amount" : @"result"];
        [self addLine:[NSString stringWithFormat:@"%@    %@", [self stringIn:row key:@"title"], value] size:15 color:[self colorForTone:[self stringIn:row key:@"tone"]]];
        [self addLine:[self stringIn:row key:@"detail"] size:13 color:UIColor.secondaryLabelColor];
    }
    NSDictionary *list = [self dictionaryIn:section key:@"list"];
    if (rows.count == 0 && [[self stringIn:list key:@"status"] isEqualToString:@"ready"]) {
        [self addLine:[self stringIn:self.records key:@"emptyText"] size:14 color:UIColor.secondaryLabelColor];
    }
    [self addFooter:list isHistory:isHistory];
}

/**
 * 渲染列表底部：加载中、失败重试、加载更多或没有更多。
 */
- (void)addFooter:(NSDictionary *)list isHistory:(BOOL)isHistory {
    NSDictionary *footer = [self dictionaryIn:self.records key:@"footer"];
    if (!list || !footer) return;
    NSString *status = [self stringIn:list key:@"status"];
    if ([status isEqualToString:@"loading"] || [list[@"isLoadingMore"] boolValue]) {
        [self addLine:[self stringIn:footer key:@"loading"] size:14 color:UIColor.secondaryLabelColor];
        return;
    }
    if ([status isEqualToString:@"error"]) {
        NSString *title = [NSString stringWithFormat:@"%@  %@", [self stringIn:list key:@"message"], [self stringIn:footer key:@"retry"]];
        [self addActionButton:title isHistory:isHistory action:@selector(retryQuery:)];
        return;
    }
    if (![list[@"hasMore"] boolValue]) {
        [self addLine:[self stringIn:footer key:@"noMore"] size:13 color:UIColor.secondaryLabelColor];
        return;
    }
    [self addActionButton:[self stringIn:footer key:@"loadMore"] isHistory:isHistory action:@selector(loadMore:)];
}

/**
 * 失败后重新查询。
 */
- (void)retryQuery:(UIButton *)button {
    [CocosGameSDK.shared queryRecordsIsHistory:button.tag == 1 filterKey:@"all" periodIndex:0 keyword:nil];
}

/**
 * 加载下一页。
 */
- (void)loadMore:(UIButton *)button {
    [CocosGameSDK.shared loadMoreRecordsIsHistory:button.tag == 1];
}

/**
 * 渲染规则分组与条目。
 */
- (void)renderRules {
    NSArray *sections = [self.rules[@"sections"] isKindOfClass:NSArray.class] ? self.rules[@"sections"] : @[];
    for (NSDictionary *section in sections) {
        if (![section isKindOfClass:NSDictionary.class]) continue;
        [self addLine:[self stringIn:section key:@"title"] size:16 color:UIColor.labelColor];
        NSArray *items = [section[@"items"] isKindOfClass:NSArray.class] ? section[@"items"] : @[];
        for (NSDictionary *item in items) {
            if (![item isKindOfClass:NSDictionary.class]) continue;
            NSString *title = [NSString stringWithFormat:@"%@  %@", [self stringIn:item key:@"title"], [self stringIn:item key:@"value"]];
            [self addLine:title size:14 color:UIColor.labelColor];
            [self addLine:[self stringIn:item key:@"description"] size:13 color:UIColor.secondaryLabelColor];
        }
    }
}

/**
 * 输赢色：赢红、输绿、其他深灰。
 */
- (UIColor *)colorForTone:(NSString *)tone {
    if ([tone isEqualToString:@"win"]) return UIColor.systemRedColor;
    if ([tone isEqualToString:@"lose"]) return UIColor.systemGreenColor;
    return UIColor.labelColor;
}

/**
 * 追加一行文字，空文案不追加。
 */
- (void)addLine:(NSString *)text size:(CGFloat)size color:(UIColor *)color {
    if (text.length == 0) return;
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.numberOfLines = 0;
    [self.content addArrangedSubview:label];
}

/**
 * 追加可点击的底部按钮，tag 记录是否历史场次。
 */
- (void)addActionButton:(NSString *)title isHistory:(BOOL)isHistory action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = isHistory ? 1 : 0;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.systemTealColor forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.content addArrangedSubview:button];
}

/**
 * 创建堆叠视图。
 */
- (UIStackView *)createStackWithAxis:(UILayoutConstraintAxis)axis {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = axis;
    stack.spacing = 6;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    return stack;
}

/**
 * 解析 JSON 对象，失败时打印上下文。
 */
- (NSDictionary *)parseJSON:(NSString *)json {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id value = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&error] : nil;
    if ([value isKindOfClass:NSDictionary.class]) return value;
    NSLog(@"Demo 解析记录数据失败，error=%@", error);
    return nil;
}

/**
 * 读取字典字段。
 */
- (NSDictionary *)dictionaryIn:(NSDictionary *)json key:(NSString *)key {
    id value = json[key];
    return [value isKindOfClass:NSDictionary.class] ? value : nil;
}

/**
 * 读取字符串字段，缺省为空串。
 */
- (NSString *)stringIn:(NSDictionary *)json key:(NSString *)key {
    id value = json[key];
    if ([value isKindOfClass:NSString.class]) return value;
    if ([value isKindOfClass:NSNumber.class]) return [value stringValue];
    return @"";
}

@end
