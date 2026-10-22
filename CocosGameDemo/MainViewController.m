// iOS Demo 登录主页面：账号密码换取会话后进入牛牛。
#import "MainViewController.h"

#import "DemoConfig.h"
#import "DemoLoginClient.h"
#import "DemoViewController.h"
#import <CocosGameSDK/CocosGameSessionConfig.h>

@interface MainViewController ()

@property(nonatomic, strong) DemoLoginClient *loginClient;
@property(nonatomic, strong) UITextField *accountField;
@property(nonatomic, strong) UITextField *passwordField;
@property(nonatomic, strong) UITextField *sceneTypeField;
@property(nonatomic, strong) UITextField *sceneIdField;
@property(nonatomic, strong) UIButton *loginButton;
@property(nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property(nonatomic, strong) UILabel *messageLabel;

@end

@implementation MainViewController

/**
 * 创建竖屏登录页面。
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.loginClient = [[DemoLoginClient alloc] init];
    [self buildInterface];
#ifndef NDEBUG
    [self autoLoginFromEnvironmentIfNeeded];
#endif
}

#ifndef NDEBUG
/**
 * 调试包读取 DEMO_ACCOUNT / DEMO_PASSWORD 环境变量自动登录，便于模拟器自动化验证。
 */
- (void)autoLoginFromEnvironmentIfNeeded {
    NSDictionary<NSString *, NSString *> *environment = NSProcessInfo.processInfo.environment;
    if (environment[@"DEMO_ACCOUNT"].length == 0 || environment[@"DEMO_PASSWORD"].length == 0) return;
    self.accountField.text = environment[@"DEMO_ACCOUNT"];
    self.passwordField.text = environment[@"DEMO_PASSWORD"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleLogin];
    });
}
#endif

/**
 * 主页面始终隐藏系统导航栏。
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

/**
 * 主页面仅支持竖屏。
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

/**
 * 创建标题、输入框与登录按钮。
 */
- (void)buildInterface {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [stack addArrangedSubview:[self createTitleLabel]];
    self.accountField = [self createField:@"账号" isSecure:NO keyboard:UIKeyboardTypeASCIICapable];
    self.passwordField = [self createField:@"密码" isSecure:YES keyboard:UIKeyboardTypeASCIICapable];
    self.sceneTypeField = [self createField:@"场景类型（1 直播间 / 2 IM 群）" isSecure:NO keyboard:UIKeyboardTypeNumberPad];
    self.sceneIdField = [self createField:@"场景 ID" isSecure:NO keyboard:UIKeyboardTypeASCIICapable];
    self.sceneTypeField.text = [NSString stringWithFormat:@"%ld", (long)DemoDefaultSceneType];
    self.sceneIdField.text = DemoDefaultSceneId;
    for (UIView *field in @[self.accountField, self.passwordField, self.sceneTypeField, self.sceneIdField]) {
        [stack addArrangedSubview:field];
    }
    [stack addArrangedSubview:[self createLoginButton]];
    [stack addArrangedSubview:[self createMessageLabel]];
    [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:28],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
    ]];
}

/**
 * 创建主页面标题。
 */
- (UILabel *)createTitleLabel {
    UILabel *label = [[UILabel alloc] init];
    label.text = @"游戏中心";
    label.font = [UIFont boldSystemFontOfSize:28];
    label.textColor = UIColor.labelColor;
    return label;
}

/**
 * 创建单行输入框。
 */
- (UITextField *)createField:(NSString *)placeholder isSecure:(BOOL)isSecure keyboard:(UIKeyboardType)keyboard {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = placeholder;
    field.secureTextEntry = isSecure;
    field.keyboardType = keyboard;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.backgroundColor = UIColor.systemBackgroundColor;
    [field.heightAnchor constraintEqualToConstant:48].active = YES;
    return field;
}

/**
 * 创建带加载指示的登录按钮。
 */
- (UIButton *)createLoginButton {
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.loginButton.backgroundColor = UIColor.systemTealColor;
    self.loginButton.layer.cornerRadius = 12;
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.loginButton setTitle:@"账号登录并进入牛牛" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(handleLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.heightAnchor constraintEqualToConstant:52].active = YES;
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.loadingIndicator.color = UIColor.whiteColor;
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loginButton addSubview:self.loadingIndicator];
    [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.loginButton.centerYAnchor].active = YES;
    [self.loadingIndicator.trailingAnchor constraintEqualToAnchor:self.loginButton.trailingAnchor constant:-16].active = YES;
    return self.loginButton;
}

/**
 * 创建错误提示文字。
 */
- (UILabel *)createMessageLabel {
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.font = [UIFont systemFontOfSize:14];
    self.messageLabel.textColor = UIColor.systemRedColor;
    return self.messageLabel;
}

/**
 * 校验输入后请求登录。
 */
- (void)handleLogin {
    [self.view endEditing:YES];
    NSString *account = [self.accountField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    NSString *password = self.passwordField.text ?: @"";
    if (account.length == 0 || password.length == 0) {
        [self showMessage:@"请输入账号和密码"];
        return;
    }
    [self setLoading:YES];
    [self.loginClient loginWithAccount:account password:password completion:^(DemoLoginResult *result, NSString *errorMessage) {
        [self setLoading:NO];
        if (!result) {
            [self showMessage:errorMessage ?: @"登录失败"];
            return;
        }
        [self openGameWithLoginResult:result];
    }];
}

/**
 * 使用登录结果和场景参数打开游戏页。
 */
- (void)openGameWithLoginResult:(DemoLoginResult *)result {
    NSError *error = nil;
    NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"1.0.0";
    CocosGameSessionConfig *session = [[CocosGameSessionConfig alloc]
        initWithWebsocketURL:DemoGameWebsocketURL apiBaseURL:DemoGameAPIURL
                  liveUserId:result.liveUserId imUserId:result.imUserId liveToken:result.token
                   sceneType:(CocosGameSceneType)self.sceneTypeField.text.integerValue
                     sceneId:self.sceneIdField.text ?: @"" tableId:0
               clientVersion:version deviceType:@"iOS" error:&error];
    if (!session) {
        [self showMessage:error.localizedDescription];
        return;
    }
    [self showMessage:@""];
    DemoViewController *gameViewController = [[DemoViewController alloc] initWithSessionConfig:session];
    [self.navigationController pushViewController:gameViewController animated:YES];
}

/**
 * 切换登录中状态，防止重复提交。
 */
- (void)setLoading:(BOOL)isLoading {
    self.loginButton.enabled = !isLoading;
    self.loginButton.alpha = isLoading ? 0.6 : 1;
    if (isLoading) [self.loadingIndicator startAnimating];
    else [self.loadingIndicator stopAnimating];
}

/**
 * 展示提示文字。
 */
- (void)showMessage:(NSString *)message {
    self.messageLabel.text = message;
}

@end
