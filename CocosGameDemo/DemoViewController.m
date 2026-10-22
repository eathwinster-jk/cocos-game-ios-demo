// iOS Demo 宿主页面与 SDK 调用示例。
#import "DemoViewController.h"

#import <CocosGameSDK/CocosGameSDK.h>

@interface DemoViewController () <CocosGameSDKDelegate>

@property(nonatomic, strong) CocosGameSessionConfig *sessionConfig;
@property(nonatomic, retain) UILabel *stateLabel;
@property(nonatomic, retain) UIView *gameContainer;
@property(nonatomic, retain) UIView *playingOperationPanel;
@property(nonatomic) BOOL hasOpened;

@end

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
    [NSLayoutConstraint activateConstraints:@[
        [self.gameContainer.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.gameContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.gameContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.gameContainer.heightAnchor constraintEqualToAnchor:self.gameContainer.widthAnchor
                                                      multiplier:211.0 / 375.0],
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
    self.playingOperationPanel = [self createPlayingOperationPanel];
    self.playingOperationPanel.hidden = YES;
    [stackView addArrangedSubview:self.playingOperationPanel];
    [stackView addArrangedSubview:[self createLabel:@"大力出奇迹：真假 是不是啊" size:15 color:UIColor.darkGrayColor]];
    [stackView addArrangedSubview:[self createLabel:@"众位球星：楼上角球绝杀，这场进球绝杀" size:15 color:UIColor.darkGrayColor]];
    [stackView addArrangedSubview:[self createLabel:@"球界诸葛：太刺激了" size:15 color:UIColor.systemTealColor]];
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
 * 打印游戏发送的通用业务事件。
 */
- (void)gameSDKDidReceiveEvent:(NSString *)event payloadJSON:(NSString *)payloadJSON gameId:(NSString *)gameId {
    NSLog(@"Demo 收到游戏事件，gameId=%@，event=%@，payload=%@", gameId, event, payloadJSON);
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
