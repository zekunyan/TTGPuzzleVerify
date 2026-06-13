//
//  TTGAppDelegate.m
//  TTGPuzzleVerify
//
//  Created by tutuge on 2016/12/10.
//  Copyright (c) 2016 zekunyan. All rights reserved.
//

#import "TTGAppDelegate.h"
#import <TTGPuzzleVerify/TTGPuzzleVerify-Swift.h>

typedef NS_ENUM(NSInteger, TTGDemoImageVariant) {
    TTGDemoImageVariantOcean,
    TTGDemoImageVariantSunset,
    TTGDemoImageVariantMint
};

typedef NS_ENUM(NSInteger, TTGDemoStyleKind) {
    TTGDemoStyleKindStandard,
    TTGDemoStyleKindLowBlankAlpha,
    TTGDemoStyleKindCustomShadow
};

@interface TTGDemoItem : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shortTitle;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *symbolName;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) TTGPuzzleVerifyPattern pattern;
@property (nonatomic, assign) TTGPuzzleVerifyAllowedAxes axes;
@property (nonatomic, assign) CGPoint blankPosition;
@property (nonatomic, assign) BOOL requiresManualVerification;
@property (nonatomic, assign) NSInteger maxRetryCount;
@property (nonatomic, assign) TTGDemoStyleKind styleKind;
@property (nonatomic, assign) TTGDemoImageVariant imageVariant;
@property (nonatomic, assign) BOOL usesImageBackground;
@property (nonatomic, strong, nullable) UIBezierPath *customPuzzlePatternPath;
@end

@implementation TTGDemoItem
@end

@interface TTGDemoListViewController : UITableViewController <TTGPuzzleVerifyViewDelegate>
@property (nonatomic, copy) NSArray<TTGDemoItem *> *demos;
@property (nonatomic, strong) UIView *heroHeaderView;
@property (nonatomic, strong) TTGPuzzleVerifyView *heroPuzzleView;
@property (nonatomic, strong) UILabel *heroTitleLabel;
@property (nonatomic, strong) UILabel *heroStatusLabel;
@property (nonatomic, strong) UISlider *heroHorizontalSlider;
@property (nonatomic, strong) UISlider *heroVerticalSlider;
@property (nonatomic, assign) BOOL didApplyHeroInitialReset;
@end

@interface TTGDemoDetailViewController : UIViewController <TTGPuzzleVerifyViewDelegate>
- (instancetype)initWithDemo:(TTGDemoItem *)demo;
@end

static UIImage *TTGDemoGradientImage(CGSize size, TTGDemoImageVariant variant) {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        NSArray *colors;
        switch (variant) {
            case TTGDemoImageVariantSunset:
                colors = @[(id)UIColor.systemPinkColor.CGColor,
                           (id)UIColor.systemOrangeColor.CGColor,
                           (id)UIColor.systemYellowColor.CGColor];
                break;
            case TTGDemoImageVariantMint:
                colors = @[(id)UIColor.systemBlueColor.CGColor,
                           (id)UIColor.systemMintColor.CGColor,
                           (id)UIColor.systemGreenColor.CGColor];
                break;
            case TTGDemoImageVariantOcean:
            default:
                colors = @[(id)UIColor.systemIndigoColor.CGColor,
                           (id)UIColor.systemTealColor.CGColor,
                           (id)UIColor.systemOrangeColor.CGColor];
                break;
        }

        CGFloat locations[] = {0, 0.55, 1};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                            (__bridge CFArrayRef)colors,
                                                            locations);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawLinearGradient(context.CGContext,
                                    gradient,
                                    CGPointZero,
                                    CGPointMake(size.width, size.height),
                                    0);
        CGGradientRelease(gradient);

        NSDictionary *attributes = @{
            NSFontAttributeName: [UIFont boldSystemFontOfSize:48],
            NSForegroundColorAttributeName: [UIColor.whiteColor colorWithAlphaComponent:0.9]
        };
        [@"TTGPuzzleVerify" drawAtPoint:CGPointMake(36, size.height - 96) withAttributes:attributes];
    }];
}

static UIImage *TTGDemoImage(TTGDemoItem *demo) {
    if (demo.usesImageBackground) {
        UIImage *image = [UIImage imageNamed:@"pic3"];
        if (image) {
            return image;
        }
    }
    return TTGDemoGradientImage(CGSizeMake(640, 400), demo.imageVariant);
}

static TTGPuzzleVerifyStyle *TTGDemoStyle(TTGDemoStyleKind kind) {
    TTGPuzzleVerifyStyle *style = [[TTGPuzzleVerifyStyle alloc] init];
    style.blankAlpha = 0.45;
    style.cornerRadius = 18;
    style.puzzleShadow.opacity = 0.42;

    if (kind == TTGDemoStyleKindLowBlankAlpha) {
        style.blankAlpha = 0.1;
    } else if (kind == TTGDemoStyleKindCustomShadow) {
        style.blankInnerShadow.color = UIColor.systemYellowColor;
        style.blankInnerShadow.radius = 6;
        style.blankInnerShadow.opacity = 0.8;
        style.blankInnerShadow.offset = CGSizeMake(2, 2);
        style.puzzleShadow.color = UIColor.systemGreenColor;
        style.puzzleShadow.radius = 6;
        style.puzzleShadow.opacity = 0.6;
        style.puzzleShadow.offset = CGSizeMake(2, 2);
    }

    return style;
}

static TTGPuzzleVerifyConfiguration *TTGDemoConfiguration(TTGDemoItem *demo) {
    TTGPuzzleVerifyConfiguration *configuration = [[TTGPuzzleVerifyConfiguration alloc] init];
    configuration.puzzlePattern = demo.pattern;
    configuration.puzzleSize = CGSizeMake(86, 86);
    configuration.verificationTolerance = 6;
    configuration.allowedAxes = demo.axes;
    configuration.autoSnapWhenWithinTolerance = !demo.requiresManualVerification;
    configuration.recordsTrack = YES;
    configuration.maxRetryCount = demo.maxRetryCount;
    configuration.style = TTGDemoStyle(demo.styleKind);
    return configuration;
}

static NSString *TTGCompletionSummary(TTGPuzzleVerifyResult *result) {
    return [NSString stringWithFormat:@"verified in %.2fs, distance %ld, points %ld",
            result.elapsedTime,
            (long)result.dragDistance,
            (long)result.interactionCount];
}

static NSString *TTGFailureSummary(TTGPuzzleVerifyResult *result) {
    return [NSString stringWithFormat:@"failed offset=(%ld, %ld) points=%ld",
            (long)result.xOffset,
            (long)result.yOffset,
            (long)result.interactionCount];
}

static NSString *TTGInitialSummary(TTGDemoItem *demo) {
    return demo.requiresManualVerification ? @"Adjust the slider, then tap Verify." : @"Drag the puzzle or use the slider to verify.";
}

@implementation TTGDemoListViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self) {
        _demos = [self makeDemos];
        self.title = @"OC Example";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"DemoCell"];
    [self configureHeroHeader];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateHeroHeaderLayout];
    [self applyHeroInitialResetIfNeeded];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DemoCell" forIndexPath:indexPath];
    TTGDemoItem *demo = self.demos[indexPath.row];

    UIListContentConfiguration *content = UIListContentConfiguration.subtitleCellConfiguration;
    content.text = demo.title;
    content.secondaryText = demo.subtitle;
    content.image = [UIImage systemImageNamed:demo.symbolName];
    content.imageProperties.tintColor = demo.tintColor;
    content.textProperties.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    content.secondaryTextProperties.color = UIColor.secondaryLabelColor;
    cell.contentConfiguration = content;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.isAccessibilityElement = YES;
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", demo.title, demo.subtitle];
    cell.accessibilityTraits = UIAccessibilityTraitButton;
    cell.contentView.accessibilityElementsHidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TTGDemoDetailViewController *detail = [[TTGDemoDetailViewController alloc] initWithDemo:self.demos[indexPath.row]];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)configureHeroHeader {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = UIColor.clearColor;
    self.heroHeaderView = headerView;

    self.heroTitleLabel = [[UILabel alloc] init];
    self.heroTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.heroTitleLabel.text = @"Slide the puzzle into the blank";
    self.heroTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.heroTitleLabel.numberOfLines = 0;

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.text = @"Objective-C drives TTGPuzzleVerifyView with configuration, state, result, and track callbacks.";
    subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    subtitleLabel.textColor = UIColor.secondaryLabelColor;
    subtitleLabel.numberOfLines = 0;

    self.heroPuzzleView = [[TTGPuzzleVerifyView alloc] init];
    self.heroPuzzleView.translatesAutoresizingMaskIntoConstraints = NO;
    self.heroPuzzleView.image = TTGDemoGradientImage(CGSizeMake(640, 400), TTGDemoImageVariantOcean);
    TTGPuzzleVerifyStyle *style = [[TTGPuzzleVerifyStyle alloc] init];
    style.blankAlpha = 0.45;
    style.cornerRadius = 18;
    TTGPuzzleVerifyConfiguration *configuration = [[TTGPuzzleVerifyConfiguration alloc] init];
    configuration.puzzlePattern = TTGPuzzleVerifyPatternClassicPattern;
    configuration.puzzleSize = CGSizeMake(86, 86);
    configuration.verificationTolerance = 6;
    configuration.allowedAxes = TTGPuzzleVerifyAllowedAxesBoth;
    configuration.autoSnapWhenWithinTolerance = YES;
    configuration.recordsTrack = YES;
    configuration.style = style;
    [self.heroPuzzleView applyConfiguration:configuration];
    self.heroPuzzleView.delegate = self;
    self.heroPuzzleView.enable = NO;
    self.heroPuzzleView.hidden = YES;
    self.heroPuzzleView.layer.cornerRadius = 18;
    self.heroPuzzleView.layer.masksToBounds = YES;

    self.heroStatusLabel = [[UILabel alloc] init];
    self.heroStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.heroStatusLabel.text = @"No verification yet";
    self.heroStatusLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.heroStatusLabel.textColor = UIColor.secondaryLabelColor;
    self.heroStatusLabel.numberOfLines = 0;

    self.heroHorizontalSlider = [[UISlider alloc] init];
    self.heroHorizontalSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.heroHorizontalSlider addTarget:self action:@selector(heroHorizontalSliderChanged:) forControlEvents:UIControlEventValueChanged];

    self.heroVerticalSlider = [[UISlider alloc] init];
    self.heroVerticalSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.heroVerticalSlider addTarget:self action:@selector(heroVerticalSliderChanged:) forControlEvents:UIControlEventValueChanged];

    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [resetButton addTarget:self action:@selector(heroResetTapped) forControlEvents:UIControlEventTouchUpInside];

    UILabel *demoTitleLabel = [[UILabel alloc] init];
    demoTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    demoTitleLabel.text = @"Puzzle demos";
    demoTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    UILabel *demoSubtitleLabel = [[UILabel alloc] init];
    demoSubtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    demoSubtitleLabel.text = @"Try different axes, puzzle shapes, manual verification, and custom styling.";
    demoSubtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    demoSubtitleLabel.textColor = UIColor.secondaryLabelColor;
    demoSubtitleLabel.numberOfLines = 0;

    UIStackView *sliderStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.heroHorizontalSlider,
        self.heroVerticalSlider
    ]];
    sliderStack.translatesAutoresizingMaskIntoConstraints = NO;
    sliderStack.axis = UILayoutConstraintAxisVertical;
    sliderStack.spacing = 16;

    UIStackView *contentStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.heroTitleLabel,
        subtitleLabel,
        self.heroPuzzleView,
        self.heroStatusLabel,
        sliderStack,
        resetButton,
        demoTitleLabel,
        demoSubtitleLabel
    ]];
    contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    contentStack.axis = UILayoutConstraintAxisVertical;
    contentStack.spacing = 12;
    [headerView addSubview:contentStack];

    [NSLayoutConstraint activateConstraints:@[
        [contentStack.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:24],
        [contentStack.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:24],
        [contentStack.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-24],
        [contentStack.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-12],
        [self.heroPuzzleView.heightAnchor constraintEqualToConstant:240]
    ]];

    self.tableView.tableHeaderView = headerView;
}

- (void)updateHeroHeaderLayout {
    CGFloat width = CGRectGetWidth(self.tableView.bounds);
    if (width <= 0) {
        return;
    }

    CGRect frame = self.heroHeaderView.frame;
    frame.size.width = width;
    self.heroHeaderView.frame = frame;
    CGSize size = [self.heroHeaderView systemLayoutSizeFittingSize:CGSizeMake(width, UIViewNoIntrinsicMetric)
                                     withHorizontalFittingPriority:UILayoutPriorityRequired
                                           verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
    if (fabs(CGRectGetHeight(frame) - size.height) > 0.5) {
        frame.size.height = size.height;
        self.heroHeaderView.frame = frame;
        self.tableView.tableHeaderView = self.heroHeaderView;
    }
}

- (void)applyHeroInitialResetIfNeeded {
    if (self.didApplyHeroInitialReset || CGRectIsEmpty(self.heroPuzzleView.bounds)) {
        return;
    }

    self.didApplyHeroInitialReset = YES;
    [UIView performWithoutAnimation:^{
        [self resetHeroPuzzleToStart];
        [self.heroHeaderView layoutIfNeeded];
    }];
    self.heroPuzzleView.hidden = NO;
}

- (void)resetHeroPuzzleToStart {
    if (CGRectIsEmpty(self.heroPuzzleView.bounds)) {
        return;
    }

    self.heroPuzzleView.enable = YES;
    [self.heroPuzzleView unlock];
    [self.heroPuzzleView clearTrack];
    self.heroPuzzleView.puzzleBlankPosition = CGPointMake(220, 96);
    [self.heroPuzzleView resetVerification];
    self.heroTitleLabel.text = @"Slide the puzzle into the blank";
    self.heroStatusLabel.text = @"No verification yet";
    [self syncHeroSlidersFromPuzzleView];
}

- (void)syncHeroSlidersFromPuzzleView {
    self.heroHorizontalSlider.value = self.heroPuzzleView.puzzleXPercentage;
    self.heroVerticalSlider.value = self.heroPuzzleView.puzzleYPercentage;
}

- (void)heroHorizontalSliderChanged:(UISlider *)sender {
    self.heroPuzzleView.puzzleXPercentage = sender.value;
}

- (void)heroVerticalSliderChanged:(UISlider *)sender {
    self.heroPuzzleView.puzzleYPercentage = sender.value;
}

- (void)heroResetTapped {
    [self resetHeroPuzzleToStart];
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedVerification:(BOOL)isVerified {
    if (puzzleVerifyView != self.heroPuzzleView) {
        return;
    }

    self.heroTitleLabel.text = isVerified ? @"Verified" : @"Slide the puzzle into the blank";
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView
didChangedPuzzlePosition:(CGPoint)newPosition
             xPercentage:(CGFloat)xPercentage
             yPercentage:(CGFloat)yPercentage {
    if (puzzleVerifyView != self.heroPuzzleView) {
        return;
    }

    self.heroHorizontalSlider.value = xPercentage;
    self.heroVerticalSlider.value = yPercentage;
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didCompleteWith:(TTGPuzzleVerifyResult *)result {
    if (puzzleVerifyView != self.heroPuzzleView) {
        return;
    }

    self.heroStatusLabel.text = [NSString stringWithFormat:@"verified in %.2fs, distance %ld",
                                 result.elapsedTime,
                                 (long)result.dragDistance];
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didFailWith:(TTGPuzzleVerifyResult *)result {
    if (puzzleVerifyView != self.heroPuzzleView) {
        return;
    }

    self.heroStatusLabel.text = [NSString stringWithFormat:@"failed, retry with offset %ld, %ld",
                                 (long)result.xOffset,
                                 (long)result.yOffset];
}

- (NSArray<TTGDemoItem *> *)makeDemos {
    NSMutableArray<TTGDemoItem *> *demos = [NSMutableArray array];

    [demos addObject:[self demoWithIdentifier:@"horizontal" title:@"Slide horizontally to verify" shortTitle:@"Horizontal" subtitle:@"Horizontal-only movement that returns to the starting point after a miss." symbol:@"arrow.left.and.right" tint:UIColor.systemBlueColor pattern:TTGPuzzleVerifyPatternClassicPattern axes:TTGPuzzleVerifyAllowedAxesHorizontal blank:CGPointMake(200, 20) manual:NO retries:0 style:TTGDemoStyleKindStandard image:TTGDemoImageVariantOcean imageBackground:NO customPath:nil]];
    [demos addObject:[self demoWithIdentifier:@"vertical" title:@"Slide vertically to verify" shortTitle:@"Vertical" subtitle:@"Vertical-only movement with the same slider-driven control." symbol:@"arrow.up.and.down" tint:UIColor.systemTealColor pattern:TTGPuzzleVerifyPatternClassicPattern axes:TTGPuzzleVerifyAllowedAxesVertical blank:CGPointMake(20, 100) manual:NO retries:0 style:TTGDemoStyleKindStandard image:TTGDemoImageVariantMint imageBackground:NO customPath:nil]];
    [demos addObject:[self demoWithIdentifier:@"drag" title:@"Drag to verify" shortTitle:@"Drag" subtitle:@"Free two-axis dragging with retry tracking enabled." symbol:@"hand.draw" tint:UIColor.systemIndigoColor pattern:TTGPuzzleVerifyPatternClassicPattern axes:TTGPuzzleVerifyAllowedAxesBoth blank:CGPointMake(200, 40) manual:NO retries:3 style:TTGDemoStyleKindStandard image:TTGDemoImageVariantOcean imageBackground:NO customPath:nil]];
    [demos addObject:[self demoWithIdentifier:@"manual" title:@"Slide and verify manually" shortTitle:@"Manual" subtitle:@"Move the piece first, then explicitly run verification." symbol:@"checkmark.seal" tint:UIColor.systemOrangeColor pattern:TTGPuzzleVerifyPatternClassicPattern axes:TTGPuzzleVerifyAllowedAxesHorizontal blank:CGPointMake(200, 20) manual:YES retries:0 style:TTGDemoStyleKindStandard image:TTGDemoImageVariantSunset imageBackground:NO customPath:nil]];
    [demos addObject:[self demoWithIdentifier:@"image-background" title:@"Image background" shortTitle:@"Image" subtitle:@"Use a bundled photo as the puzzle background." symbol:@"photo" tint:UIColor.systemBrownColor pattern:TTGPuzzleVerifyPatternClassicPattern axes:TTGPuzzleVerifyAllowedAxesHorizontal blank:CGPointMake(200, 20) manual:NO retries:0 style:TTGDemoStyleKindStandard image:TTGDemoImageVariantOcean imageBackground:YES customPath:nil]];
    [demos addObject:[self demoWithIdentifier:@"square" title:@"Square pattern" shortTitle:@"Square" subtitle:@"A square cutout with the same smooth slider control." symbol:@"square.dashed" tint:UIColor.systemPurpleColor pattern:TTGPuzzleVerifyPatternSquarePattern axes:TTGPuzzleVerifyAllowedAxesHorizontal blank:CGPointMake(200, 20) manual:NO retries:0 style:TTGDemoStyleKindStandard image:TTGDemoImageVariantOcean imageBackground:NO customPath:nil]];
    [demos addObject:[self demoWithIdentifier:@"circle" title:@"Circle pattern" shortTitle:@"Circle" subtitle:@"A circular puzzle piece with automatic verification." symbol:@"circle.dashed" tint:UIColor.systemPinkColor pattern:TTGPuzzleVerifyPatternCirclePattern axes:TTGPuzzleVerifyAllowedAxesHorizontal blank:CGPointMake(200, 20) manual:NO retries:0 style:TTGDemoStyleKindStandard image:TTGDemoImageVariantSunset imageBackground:NO customPath:nil]];
    [demos addObject:[self demoWithIdentifier:@"custom-pattern" title:@"Custom pattern" shortTitle:@"Custom" subtitle:@"Rounded custom UIBezierPath pattern with lighter blank opacity." symbol:@"app.dashed" tint:UIColor.systemCyanColor pattern:TTGPuzzleVerifyPatternCustomPattern axes:TTGPuzzleVerifyAllowedAxesHorizontal blank:CGPointMake(120, 20) manual:NO retries:0 style:TTGDemoStyleKindLowBlankAlpha image:TTGDemoImageVariantMint imageBackground:NO customPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 80, 80) cornerRadius:20]]];
    [demos addObject:[self demoWithIdentifier:@"custom-shadow" title:@"Custom shadow" shortTitle:@"Shadow" subtitle:@"Custom blank inner shadow and puzzle-piece shadow styling." symbol:@"sparkles" tint:UIColor.systemGreenColor pattern:TTGPuzzleVerifyPatternClassicPattern axes:TTGPuzzleVerifyAllowedAxesHorizontal blank:CGPointMake(200, 20) manual:NO retries:0 style:TTGDemoStyleKindCustomShadow image:TTGDemoImageVariantOcean imageBackground:NO customPath:nil]];

    return demos;
}

- (TTGDemoItem *)demoWithIdentifier:(NSString *)identifier
                              title:(NSString *)title
                         shortTitle:(NSString *)shortTitle
                           subtitle:(NSString *)subtitle
                             symbol:(NSString *)symbol
                               tint:(UIColor *)tint
                            pattern:(TTGPuzzleVerifyPattern)pattern
                               axes:(TTGPuzzleVerifyAllowedAxes)axes
                              blank:(CGPoint)blank
                             manual:(BOOL)manual
                            retries:(NSInteger)retries
                              style:(TTGDemoStyleKind)style
                              image:(TTGDemoImageVariant)image
                    imageBackground:(BOOL)imageBackground
                         customPath:(UIBezierPath *)customPath {
    TTGDemoItem *demo = [[TTGDemoItem alloc] init];
    demo.identifier = identifier;
    demo.title = title;
    demo.shortTitle = shortTitle;
    demo.subtitle = subtitle;
    demo.symbolName = symbol;
    demo.tintColor = tint;
    demo.pattern = pattern;
    demo.axes = axes;
    demo.blankPosition = blank;
    demo.requiresManualVerification = manual;
    demo.maxRetryCount = retries;
    demo.styleKind = style;
    demo.imageVariant = image;
    demo.usesImageBackground = imageBackground;
    demo.customPuzzlePatternPath = customPath;
    return demo;
}

@end

@interface TTGDemoDetailViewController ()
@property (nonatomic, strong) TTGDemoItem *demo;
@property (nonatomic, strong) TTGPuzzleVerifyView *puzzleView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UISlider *horizontalSlider;
@property (nonatomic, strong) UISlider *verticalSlider;
@property (nonatomic, assign) BOOL didApplyInitialReset;
@end

@implementation TTGDemoDetailViewController

- (instancetype)initWithDemo:(TTGDemoItem *)demo {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _demo = demo;
        self.title = demo.shortTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self configureViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self applyInitialResetIfNeeded];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self applyInitialResetIfNeeded];
}

- (void)configureViews {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = self.demo.title;
    titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.text = self.demo.subtitle;
    subtitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    subtitleLabel.textColor = UIColor.secondaryLabelColor;
    subtitleLabel.numberOfLines = 0;

    self.puzzleView = [[TTGPuzzleVerifyView alloc] init];
    self.puzzleView.translatesAutoresizingMaskIntoConstraints = NO;
    self.puzzleView.image = TTGDemoImage(self.demo);
    [self.puzzleView applyConfiguration:TTGDemoConfiguration(self.demo)];
    self.puzzleView.customPuzzlePatternPath = self.demo.customPuzzlePatternPath;
    self.puzzleView.failureAnimation = TTGPuzzleVerifyFailureAnimationShake;
    self.puzzleView.delegate = self;
    self.puzzleView.enable = NO;
    self.puzzleView.hidden = YES;
    self.puzzleView.layer.cornerRadius = 18;
    self.puzzleView.layer.masksToBounds = YES;

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.text = TTGInitialSummary(self.demo);
    self.statusLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.statusLabel.textColor = UIColor.secondaryLabelColor;
    self.statusLabel.numberOfLines = 0;

    self.horizontalSlider = [[UISlider alloc] init];
    self.horizontalSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.horizontalSlider addTarget:self action:@selector(horizontalSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.horizontalSlider addTarget:self action:@selector(sliderInteractionEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];

    self.verticalSlider = [[UISlider alloc] init];
    self.verticalSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.verticalSlider addTarget:self action:@selector(verticalSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.verticalSlider addTarget:self action:@selector(sliderInteractionEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];

    UIStackView *sliderStack = [[UIStackView alloc] init];
    sliderStack.translatesAutoresizingMaskIntoConstraints = NO;
    sliderStack.axis = UILayoutConstraintAxisVertical;
    sliderStack.spacing = 16;
    if ([self showsHorizontalSlider]) {
        [sliderStack addArrangedSubview:self.horizontalSlider];
    }
    if ([self showsVerticalSlider]) {
        [sliderStack addArrangedSubview:self.verticalSlider];
    }

    NSMutableArray<UIView *> *buttonViews = [NSMutableArray array];
    if (self.demo.requiresManualVerification) {
        UIButton *verifyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        verifyButton.translatesAutoresizingMaskIntoConstraints = NO;
        [verifyButton setTitle:@"Verify" forState:UIControlStateNormal];
        verifyButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [verifyButton addTarget:self action:@selector(verifyTapped) forControlEvents:UIControlEventTouchUpInside];
        [buttonViews addObject:verifyButton];
    }

    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [resetButton addTarget:self action:@selector(resetTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttonViews addObject:resetButton];

    UIStackView *buttonStack = [[UIStackView alloc] initWithArrangedSubviews:buttonViews];
    buttonStack.translatesAutoresizingMaskIntoConstraints = NO;
    buttonStack.axis = UILayoutConstraintAxisHorizontal;
    buttonStack.spacing = 12;

    UIStackView *contentStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        titleLabel,
        subtitleLabel,
        self.puzzleView,
        self.statusLabel,
        sliderStack,
        buttonStack
    ]];
    contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    contentStack.axis = UILayoutConstraintAxisVertical;
    contentStack.spacing = 16;
    [self.view addSubview:contentStack];

    [NSLayoutConstraint activateConstraints:@[
        [contentStack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24],
        [contentStack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [contentStack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],
        [self.puzzleView.heightAnchor constraintEqualToConstant:240]
    ]];
}

- (void)applyInitialResetIfNeeded {
    if (self.didApplyInitialReset || CGRectIsEmpty(self.puzzleView.bounds)) {
        return;
    }

    self.didApplyInitialReset = YES;
    [UIView performWithoutAnimation:^{
        [self resetPuzzleToStart];
        [self.view layoutIfNeeded];
    }];
    self.puzzleView.hidden = NO;
}

- (BOOL)showsHorizontalSlider {
    return self.demo.axes == TTGPuzzleVerifyAllowedAxesHorizontal ||
           self.demo.axes == TTGPuzzleVerifyAllowedAxesBoth ||
           self.demo.requiresManualVerification;
}

- (BOOL)showsVerticalSlider {
    return self.demo.axes == TTGPuzzleVerifyAllowedAxesVertical ||
           self.demo.axes == TTGPuzzleVerifyAllowedAxesBoth;
}

- (void)resetPuzzleToStart {
    if (CGRectIsEmpty(self.puzzleView.bounds)) {
        return;
    }
    self.puzzleView.enable = YES;
    [self.puzzleView unlock];
    [self.puzzleView clearTrack];
    self.puzzleView.puzzleBlankPosition = self.demo.blankPosition;
    [self.puzzleView resetVerification];
    [self syncSlidersFromPuzzleView];
}

- (void)syncSlidersFromPuzzleView {
    self.horizontalSlider.value = self.puzzleView.puzzleXPercentage;
    self.verticalSlider.value = self.puzzleView.puzzleYPercentage;
}

- (void)restoreStartAfterFailure {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.32 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.puzzleView.state != TTGPuzzleVerifyStateFailed) {
            return;
        }
        [self resetPuzzleToStart];
    });
}

- (void)horizontalSliderChanged:(UISlider *)sender {
    self.puzzleView.puzzleXPercentage = sender.value;
}

- (void)verticalSliderChanged:(UISlider *)sender {
    self.puzzleView.puzzleYPercentage = sender.value;
}

- (void)sliderInteractionEnded:(UISlider *)sender {
    if (self.demo.requiresManualVerification ||
        self.puzzleView.state == TTGPuzzleVerifyStateVerified ||
        self.puzzleView.isVerified) {
        return;
    }
    [self.puzzleView markVerificationFailed];
}

- (void)verifyTapped {
    if (self.puzzleView.isVerified) {
        [self.puzzleView completeVerificationWithAnimation:YES];
    } else {
        [self.puzzleView markVerificationFailed];
    }
}

- (void)resetTapped {
    self.statusLabel.text = TTGInitialSummary(self.demo);
    [self resetPuzzleToStart];
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedVerification:(BOOL)isVerified {
    if (isVerified) {
        self.statusLabel.text = self.demo.requiresManualVerification ? @"Position matched. Tap Verify to complete." : @"Verified";
    } else if (self.demo.requiresManualVerification) {
        self.statusLabel.text = TTGInitialSummary(self.demo);
    }
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView
didChangedPuzzlePosition:(CGPoint)newPosition
             xPercentage:(CGFloat)xPercentage
             yPercentage:(CGFloat)yPercentage {
    self.horizontalSlider.value = xPercentage;
    self.verticalSlider.value = yPercentage;
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didCompleteWith:(TTGPuzzleVerifyResult *)result {
    self.statusLabel.text = TTGCompletionSummary(result);
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didFailWith:(TTGPuzzleVerifyResult *)result {
    self.statusLabel.text = TTGFailureSummary(result);
    [self restoreStartAfterFailure];
}

@end

@implementation TTGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    TTGDemoListViewController *listViewController = [[TTGDemoListViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:listViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
