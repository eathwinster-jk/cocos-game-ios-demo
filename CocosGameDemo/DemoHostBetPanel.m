// 演示宿主下注面板实现。
#import "DemoHostBetPanel.h"

static const long long DemoCentsPerYuan = 100;

@interface DemoHostBetPanel ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIStackView *areaRow;
@property(nonatomic, strong) UIStackView *chipRow;
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong, nullable) CocosGameBetOptions *options;
@property(nonatomic, strong, nullable) NSTimer *countdownTimer;
@property(nonatomic) NSUInteger selectedAreaIndex;

@end

@implementation DemoHostBetPanel

/**
 * 创建卡片样式的下注面板。
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.backgroundColor = UIColor.systemBackgroundColor;
    self.layer.cornerRadius = 12;
    self.layer.borderWidth = 1;
    self.layer.borderColor = UIColor.systemTealColor.CGColor;
    [self buildInterface];
    self.titleLabel.text = @"等待下一局下注";
    return self;
}

/**
 * 从窗口移除时停止倒计时。
 */
- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (!newWindow) [self stopCountdown];
}

/**
 * 组装标题、注区行、筹码行与状态行。
 */
- (void)buildInterface {
    self.titleLabel = [self createLabelWithSize:15 color:UIColor.labelColor];
    self.areaRow = [self createRow];
    self.chipRow = [self createRow];
    self.statusLabel = [self createLabelWithSize:13 color:UIColor.secondaryLabelColor];
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.areaRow, self.chipRow, self.statusLabel]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 6;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
        [stack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
        [stack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:12],
        [stack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
    ]];
}

/**
 * 本局进入下注阶段。
 */
- (void)showOptions:(CocosGameBetOptions *)options {
    self.options = options;
    self.selectedAreaIndex = 0;
    self.statusLabel.text = @"";
    [self bindChoices];
    [self startCountdown];
}

/**
 * 本局下注截止。
 */
- (void)closeRound:(NSString *)roundId {
    if (![self.options.roundId isEqualToString:roundId]) return;
    self.options = nil;
    [self stopCountdown];
    [self bindChoices];
    self.titleLabel.text = @"本局下注已截止";
}

/**
 * 展示下注结果。
 */
- (void)showResult:(CocosGameBetResult *)result {
    if (!result.isSuccess) {
        self.statusLabel.text = [NSString stringWithFormat:@"下注失败：%@", result.errorMessage];
        return;
    }
    NSString *balanceText = result.balanceCent ? [self formatCent:result.balanceCent.longLongValue] : @"-";
    self.statusLabel.text = [NSString stringWithFormat:@"下注成功 %@，余额 %@", [self formatCent:result.amountCent], balanceText];
}

/**
 * 提交当前选中注区与筹码。
 */
- (void)submitChip:(UIButton *)button {
    CocosGameBetOptions *options = self.options;
    if (!options) return;
    long long amountCent = options.chipsCent[(NSUInteger)button.tag].longLongValue;
    NSString *areaCode = options.areas[self.selectedAreaIndex].areaCode;
    BOOL isSent = [CocosGameSDK.shared submitBetWithRoundId:options.roundId
                                                   areaCode:areaCode
                                                 amountCent:amountCent
                                                clientBetNo:[CocosGameSDK createClientBetNo]];
    self.statusLabel.text = isSent ? @"提交中…" : @"本局已截止或重复提交";
}

/**
 * 切换选中注区。
 */
- (void)selectArea:(UIButton *)button {
    self.selectedAreaIndex = (NSUInteger)button.tag;
    [self bindChoices];
}

/**
 * 按当前选项重建注区与筹码按钮。
 */
- (void)bindChoices {
    [self clearRow:self.areaRow];
    [self clearRow:self.chipRow];
    CocosGameBetOptions *options = self.options;
    self.areaRow.hidden = options == nil;
    self.chipRow.hidden = options == nil;
    if (!options) return;
    [options.areas enumerateObjectsUsingBlock:^(CocosGameBetArea *area, NSUInteger index, __unused BOOL *stop) {
        UIButton *button = [self createChoice:area.areaName isSelected:index == self.selectedAreaIndex tag:index];
        [button addTarget:self action:@selector(selectArea:) forControlEvents:UIControlEventTouchUpInside];
        [self.areaRow addArrangedSubview:button];
    }];
    [options.chipsCent enumerateObjectsUsingBlock:^(NSNumber *chip, NSUInteger index, __unused BOOL *stop) {
        UIButton *button = [self createChoice:[self formatCent:chip.longLongValue] isSelected:NO tag:index];
        [button addTarget:self action:@selector(submitChip:) forControlEvents:UIControlEventTouchUpInside];
        [self.chipRow addArrangedSubview:button];
    }];
}

/**
 * 每秒刷新剩余秒数。
 */
- (void)startCountdown {
    [self stopCountdown];
    [self refreshTitle];
    __weak DemoHostBetPanel *weakSelf = self;
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(__unused NSTimer *timer) {
        [weakSelf refreshTitle];
    }];
}

/**
 * 停止倒计时。
 */
- (void)stopCountdown {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
}

/**
 * 刷新局号与剩余秒数。
 */
- (void)refreshTitle {
    CocosGameBetOptions *options = self.options;
    if (!options) return;
    NSInteger remainSeconds = MAX(0, (NSInteger)ceil(options.deadline.timeIntervalSinceNow));
    self.titleLabel.text = [NSString stringWithFormat:@"第 %@ 局 · 剩余 %ld 秒", options.roundId, (long)remainSeconds];
    if (remainSeconds == 0) [self stopCountdown];
}

/**
 * 创建注区或筹码按钮。
 */
- (UIButton *)createChoice:(NSString *)title isSelected:(BOOL)isSelected tag:(NSUInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = (NSInteger)tag;
    button.layer.cornerRadius = 8;
    button.backgroundColor = isSelected ? UIColor.systemTealColor : UIColor.secondarySystemBackgroundColor;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:isSelected ? UIColor.whiteColor : UIColor.labelColor forState:UIControlStateNormal];
    [button.heightAnchor constraintEqualToConstant:36].active = YES;
    return button;
}

/**
 * 创建等分横向按钮行。
 */
- (UIStackView *)createRow {
    UIStackView *row = [[UIStackView alloc] init];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.spacing = 8;
    row.distribution = UIStackViewDistributionFillEqually;
    row.hidden = YES;
    return row;
}

/**
 * 清空按钮行。
 */
- (void)clearRow:(UIStackView *)row {
    for (UIView *view in row.arrangedSubviews) [view removeFromSuperview];
}

/**
 * 创建文字。
 */
- (UILabel *)createLabelWithSize:(CGFloat)size color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

/**
 * 分转元展示。
 */
- (NSString *)formatCent:(long long)amountCent {
    if (amountCent % DemoCentsPerYuan == 0) return [NSString stringWithFormat:@"¥%lld", amountCent / DemoCentsPerYuan];
    return [NSString stringWithFormat:@"¥%.2f", amountCent / (double)DemoCentsPerYuan];
}

@end
