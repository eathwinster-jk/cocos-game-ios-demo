// iOS Demo 宿主页面与 SDK 调用示例。
#import "DemoViewController.h"

#import <CocosGameSDK/CocosGameSDK.h>
#import "DemoHostBetPanel.h"
#import "DemoHostRecordsSheet.h"

@interface DemoViewController () <CocosGameSDKDelegate>

@property(nonatomic, strong) CocosGameSessionConfig *sessionConfig;
@property(nonatomic, retain) UILabel *stateLabel;
@property(nonatomic, retain) UIView *gameContainer;
@property(nonatomic, retain) UIView *playingOperationPanel;
@property(nonatomic, strong) DemoHostBetPanel *betPanel;
@property(nonatomic, strong) UILabel *balanceLabel;
@property(nonatomic, weak) DemoHostRecordsSheet *recordsSheet;
@property(nonatomic, copy) NSArray<NSLayoutConstraint *> *embeddedConstraints;
@property(nonatomic, copy) NSArray<NSLayoutConstraint *> *miniConstraints;
@property(nonatomic) BOOL hasOpened;

@end

static const CGFloat DemoMiniBarMargin = 6;

@implementation DemoViewController

/**
 * 使用登录后的大厅会话创建游戏页。
 */
- (instancetype)initWithSessionConfig:(CocosGameSessionConfig *)sessionConfig {
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    _sessionConfig = sessionConfig;
    return self;
}

/**
 * 页面被系统返回手势移除时同步关闭游戏。
 */
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController) [[CocosGameSDK shared] close];
}

/**
 * 创建 Demo 页面。
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.navigationController.navigationBarHidden = YES;
    [self buildInterface];
    CocosGameSDK.shared.delegate = self;
}

/**
 * 游戏页面完成展示后再加载牛牛。
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startGameIfNeeded];
}

/**
 * 游戏页面显示时隐藏系统导航栏。
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

/**
 * 在首次显示前启动并预热游戏。
 */
- (void)startGameIfNeeded {
    if (self.hasOpened) return;
    self.hasOpened = YES;
    [self openNiuNiu];
}

/**
 * Demo 宿主仅使用竖屏。
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

/**
 * 旋转全屏时隐藏宿主状态栏。
 */
- (BOOL)prefersStatusBarHidden {
    return CocosGameSDK.shared.isFullscreen;
}

/**
 * 使用淡入淡出切换状态栏。
 */
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

/**
 * 创建标题、状态与操作按钮。
 */
- (void)buildInterface {
    self.gameContainer = [[UIView alloc] init];
    self.gameContainer.backgroundColor = UIColor.blackColor;
    self.gameContainer.clipsToBounds = YES;
    self.gameContainer.translatesAutoresizingMaskIntoConstraints = NO;
    UIStackView *hostContent = [self createHostContent];
    [self.view addSubview:self.gameContainer];
    [self.view addSubview:hostContent];
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    self.embeddedConstraints = @[
        [self.gameContainer.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [self.gameContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.gameContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.gameContainer.heightAnchor constraintEqualToAnchor:self.gameContainer.widthAnchor
                                                      multiplier:211.0 / 375.0],
    ];
    self.miniConstraints = @[
        [self.gameContainer.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:DemoMiniBarMargin],
        [self.gameContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:DemoMiniBarMargin],
        [self.gameContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-DemoMiniBarMargin],
        [self.gameContainer.heightAnchor constraintEqualToAnchor:self.gameContainer.widthAnchor
                                                      multiplier:50.0 / 362.0],
    ];
    [NSLayoutConstraint activateConstraints:self.embeddedConstraints];
    [NSLayoutConstraint activateConstraints:@[
        [hostContent.topAnchor constraintEqualToAnchor:self.gameContainer.bottomAnchor constant:8],
        [hostContent.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:14],
        [hostContent.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-14],
    ]];
}

/**
 * 关闭游戏并返回原生主页面；返回箭头由牌桌内绘制并通过 SDK 回调。
 */
- (void)closeAndReturn {
    [[CocosGameSDK shared] close];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 创建游戏下方宿主聊天页面示意。
 */
- (UIStackView *)createHostContent {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = 10;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [stackView addArrangedSubview:[self createRoomSummaryRow]];
    [stackView addArrangedSubview:[self createLabel:@"聊天     直播     数据     指数     预测"
                                                size:17
                                               color:UIColor.labelColor]];
    [stackView addArrangedSubview:[self createSeparator]];
    self.balanceLabel = [self createLabel:@"钱包余额：-" size:14 color:UIColor.labelColor];
    [stackView addArrangedSubview:self.balanceLabel];
    self.betPanel = [[DemoHostBetPanel alloc] init];
    [stackView addArrangedSubview:self.betPanel];
    self.playingOperationPanel = [self createPlayingOperationPanel];
    self.playingOperationPanel.hidden = YES;
    [stackView addArrangedSubview:self.playingOperationPanel];
    [stackView addArrangedSubview:[self createLabel:@"大力出奇迹：真假 是不是啊" size:15 color:UIColor.darkGrayColor]];
    [stackView addArrangedSubview:[self createLabel:@"众位球星：楼上角球绝杀，这场进球绝杀" size:15 color:UIColor.darkGrayColor]];
    [stackView addArrangedSubview:[self createLabel:@"球界诸葛：太刺激了" size:15 color:UIColor.systemTealColor]];
    [stackView addArrangedSubview:[self createMiniModeButton]];
    [stackView addArrangedSubview:[self createStateLabel]];
    return stackView;
}

/**
 * 创建房间与比赛摘要行。
 */
- (UIStackView *)createRoomSummaryRow {
    UIStackView *row = [[UIStackView alloc] init];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.spacing = 8;
    row.alignment = UIStackViewAlignmentCenter;
    [row addArrangedSubview:[self createPillLabel:@"牛牛游戏" isPrimary:YES]];
    [row addArrangedSubview:[self createPillLabel:@"老金" isPrimary:NO]];
    [row addArrangedSubview:[self createPillLabel:@"108" isPrimary:NO]];
    UILabel *matchLabel = [self createLabel:@"完场 90+\n深圳 1 - 3 天津" size:12 color:UIColor.darkGrayColor];
    matchLabel.textAlignment = NSTextAlignmentCenter;
    [row addArrangedSubview:matchLabel];
    [row addArrangedSubview:[self createPillLabel:@"私信" isPrimary:YES]];
    return row;
}

/**
 * 创建房间胶囊标签。
 */
- (UILabel *)createPillLabel:(NSString *)text isPrimary:(BOOL)isPrimary {
    UILabel *label = [self createLabel:text size:13 color:isPrimary ? UIColor.whiteColor : UIColor.systemTealColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = isPrimary
        ? UIColor.systemTealColor
        : [UIColor.systemTealColor colorWithAlphaComponent:0.12];
    label.layer.cornerRadius = 13;
    label.clipsToBounds = YES;
    [label.widthAnchor constraintGreaterThanOrEqualToConstant:48].active = YES;
    [label.heightAnchor constraintEqualToConstant:27].active = YES;
    return label;
}

/**
 * 创建已加入状态的选择方式卡片。
 */
- (UIStackView *)createPlayingOperationPanel {
    UIStackView *panel = [[UIStackView alloc] init];
    panel.axis = UILayoutConstraintAxisVertical;
    panel.spacing = 10;
    panel.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
    panel.layoutMarginsRelativeArrangement = YES;
    panel.backgroundColor = UIColor.secondarySystemBackgroundColor;
    panel.layer.cornerRadius = 12;
    [panel addArrangedSubview:[self createLabel:@"请选择方式" size:14 color:UIColor.darkGrayColor]];
    UIStackView *buttons = [[UIStackView alloc] init];
    buttons.axis = UILayoutConstraintAxisHorizontal;
    buttons.spacing = 6;
    buttons.distribution = UIStackViewDistributionFillEqually;
    [buttons addArrangedSubview:[self createOperationButton:@"弃牌"]];
    [buttons addArrangedSubview:[self createOperationButton:@"跟注¥100"]];
    [buttons addArrangedSubview:[self createOperationButton:@"加注"]];
    [panel addArrangedSubview:buttons];
    [panel.heightAnchor constraintEqualToConstant:104].active = YES;
    return panel;
}

/**
 * 创建选择方式按钮。
 */
- (UIButton *)createOperationButton:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = UIColor.systemBackgroundColor;
    button.layer.cornerRadius = 9;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.darkTextColor forState:UIControlStateNormal];
    return button;
}

/**
 * 创建宿主文字。
 */
- (UILabel *)createLabel:(NSString *)text size:(CGFloat)size color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

/**
 * 创建聊天 Tab 分隔线。
 */
- (UIView *)createSeparator {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.systemTealColor;
    [view.heightAnchor constraintEqualToConstant:2].active = YES;
    return view;
}

/**
 * 创建缩小为迷你条按钮，展开由游戏内按钮触发。
 */
- (UIButton *)createMiniModeButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitle:@"缩小为迷你条 ›" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.systemTealColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(enterMiniMode) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

/**
 * 进入迷你条。
 */
- (void)enterMiniMode {
    [self applyMiniMode:YES];
}

/**
 * 先调整容器为 362:50 横条（或恢复原高度），再通知 SDK；圆角外区域用页面底色。
 */
- (void)applyMiniMode:(BOOL)isMiniMode {
    if (CocosGameSDK.shared.isMiniMode == isMiniMode) return;
    [NSLayoutConstraint deactivateConstraints:isMiniMode ? self.embeddedConstraints : self.miniConstraints];
    [NSLayoutConstraint activateConstraints:isMiniMode ? self.miniConstraints : self.embeddedConstraints];
    self.gameContainer.backgroundColor = isMiniMode ? self.view.backgroundColor : UIColor.blackColor;
    [self.view layoutIfNeeded];
    [CocosGameSDK.shared setMiniMode:isMiniMode backgroundColorHex:[self createHexString:self.view.backgroundColor]];
}

/**
 * 按当前外观把颜色转为 #RRGGBB。
 */
- (NSString *)createHexString:(UIColor *)color {
    UIColor *resolvedColor = [color resolvedColorWithTraitCollection:self.traitCollection];
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
    if (![resolvedColor getRed:&red green:&green blue:&blue alpha:&alpha]) return nil;
    return [NSString stringWithFormat:@"#%02X%02X%02X",
        (int)lround(red * 255), (int)lround(green * 255), (int)lround(blue * 255)];
}

/**
 * 玩家点击迷你条展开按钮：恢复内嵌牌桌。
 */
- (void)gameSDKDidRequestExpand {
    [self applyMiniMode:NO];
}

/**
 * 创建 SDK 状态标签。
 */
- (UILabel *)createStateLabel {
    self.stateLabel = [[UILabel alloc] init];
    self.stateLabel.text = @"游戏加载中";
    self.stateLabel.textColor = UIColor.secondaryLabelColor;
    self.stateLabel.font = [UIFont systemFontOfSize:12];
    self.stateLabel.hidden = YES;
    return self.stateLabel;
}

/**
 * 通过 SDK 打开牛牛。
 */
- (void)openNiuNiu {
    [self.view layoutIfNeeded];
    [[CocosGameSDK shared] openGame:@"niuniu"
                      sessionConfig:self.sessionConfig
                        inContainer:self.gameContainer
                 fromViewController:self];
}

/**
 * 牌桌返回箭头请求离开游戏页。
 */
- (void)gameSDKDidRequestBack {
    [self closeAndReturn];
}

/**
 * 大厅会话失效时返回登录页并提示。
 */
- (void)gameSDKDidInvalidateSessionWithMessage:(NSString *)message {
    UINavigationController *navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:YES];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"会话已失效"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [navigationController.topViewController presentViewController:alert animated:YES completion:nil];
}

/**
 * 打印游戏发送的通用业务事件，钱包余额变化时刷新余额。
 */
- (void)gameSDKDidReceiveEvent:(NSString *)event payloadJSON:(NSString *)payloadJSON gameId:(NSString *)gameId {
    NSLog(@"Demo 收到游戏事件，gameId=%@，event=%@，payload=%@", gameId, event, payloadJSON);
    if (![event isEqualToString:@"wallet.balance_changed"]) return;
    NSData *data = [payloadJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *payload = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    NSNumber *balanceCent = [payload isKindOfClass:NSDictionary.class] ? payload[@"balanceCent"] : nil;
    if (![balanceCent isKindOfClass:NSNumber.class]) return;
    self.balanceLabel.text = [NSString stringWithFormat:@"钱包余额：¥%.2f", balanceCent.longLongValue / 100.0];
}

/**
 * 竖屏本局开始下注：由宿主下注面板展示。
 */
- (void)gameSDKDidReceiveBetOptions:(CocosGameBetOptions *)options gameId:(NSString *)gameId {
    [self.betPanel showOptions:options];
}

/**
 * 本局下注截止：收起宿主下注面板。
 */
- (void)gameSDKDidCloseBetRound:(NSString *)roundId gameId:(NSString *)gameId {
    [self.betPanel closeRound:roundId];
}

/**
 * 下注结果：展示在宿主下注面板。
 */
- (void)gameSDKDidReceiveBetResult:(CocosGameBetResult *)result gameId:(NSString *)gameId {
    [self.betPanel showResult:result];
}

/**
 * 竖屏点击记录与规则：由宿主弹窗展示。
 */
- (void)gameSDKDidRequestShowRecords:(NSString *)rulesJSON gameId:(NSString *)gameId {
    [self.recordsSheet dismissViewControllerAnimated:NO completion:nil];
    DemoHostRecordsSheet *sheet = [[DemoHostRecordsSheet alloc] initWithRulesJSON:rulesJSON];
    self.recordsSheet = sheet;
    [[self activePresenter] presentViewController:sheet animated:YES completion:nil];
}

/**
 * 记录数据更新：刷新已打开的宿主弹窗。
 */
- (void)gameSDKDidUpdateRecords:(NSString *)recordsJSON gameId:(NSString *)gameId {
    [self.recordsSheet updateRecordsJSON:recordsJSON];
}

/**
 * 由宿主展示退出游戏确认框。
 */
- (void)gameSDKDidRequestExitWithCompletion:(void (^)(BOOL))completion {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"退出游戏？"
                         message:@"当前游戏正在进行中，离开后游戏将结束并结算。"
                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:@"离开"
        style:UIAlertActionStyleDestructive
      handler:^(__unused UIAlertAction *action) {
        completion(YES);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
        style:UIAlertActionStyleCancel
      handler:^(__unused UIAlertAction *action) {
        completion(NO);
    }];
    [alert addAction:leaveAction];
    [alert addAction:cancelAction];
    [[self activePresenter] presentViewController:alert animated:YES completion:nil];
}

/**
 * 获取当前可见的宿主展示控制器。
 */
- (UIViewController *)activePresenter {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UIViewController *presenter = window.rootViewController ?: self;
    if ([presenter isKindOfClass:UINavigationController.class]) {
        return ((UINavigationController *)presenter).visibleViewController ?: presenter;
    }
    return presenter;
}

/**
 * 根据游戏参与状态切换选择方式卡片。
 */
- (void)gameSDKDidChangePlayingState:(BOOL)isPlaying {
    if (!self.playingOperationPanel) return;
    [UIView animateWithDuration:0.2 animations:^{
        self.playingOperationPanel.hidden = !isPlaying;
        [self.view layoutIfNeeded];
    }];
}

/**
 * 显示 SDK 状态变化。
 */
- (void)gameSDKDidChangeState:(CocosGameSDKState)state {
    self.stateLabel.text = [NSString stringWithFormat:@"状态：%ld", (long)state];
}

/**
 * 显示 SDK 错误上下文。
 */
- (void)gameSDKDidFailWithError:(NSError *)error {
    self.stateLabel.text = [NSString stringWithFormat:@"错误：%@", error.localizedDescription];
    self.stateLabel.hidden = NO;
}

@end
