//
//  TTGPuzzleVerifyView.m
//  Pods
//
//  Created by tutuge on 2016/12/10.
//
//

#import "TTGPuzzleVerifyView.h"
#import "TTGPuzzleVerifyView+PatternPathProvider.h"
#import <math.h>

static const CGSize TTGPuzzleVerifyDefaultPuzzleSize = { 100.0, 100.0 };
static const CGPoint TTGPuzzleVerifyDefaultPuzzlePosition = { 20.0, 20.0 };
static const CGFloat TTGPuzzleVerifyAnimationDuration = 0.3;
static const CGFloat TTGPuzzleVerifyDefaultTolerance = 8.0;
static const CGFloat TTGPuzzleVerifyDefaultAlpha = 0.5;
static const CGFloat TTGPuzzleVerifyDefaultShadowRadius = 4.0;
static const CGFloat TTGPuzzleVerifyDefaultShadowOpacity = 0.5;
static const CGFloat TTGPuzzleVerifyShadowInset = -20.0;

@interface TTGPuzzleVerifyView ()
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) CAShapeLayer *backMaskLayer;
@property (nonatomic, strong) CAShapeLayer *backInnerShadowLayer;

@property (nonatomic, strong) UIImageView *frontImageView;
@property (nonatomic, strong) CAShapeLayer *frontMaskLayer;

@property (nonatomic, strong) UIImageView *puzzleImageView;
@property (nonatomic, strong) CAShapeLayer *puzzleMaskLayer;
@property (nonatomic, strong) UIView *puzzleImageContainerView;
@property (nonatomic, assign) CGPoint puzzleContainerPosition;

@property (nonatomic, assign) BOOL lastVerification;
@end

@implementation TTGPuzzleVerifyView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    if (_backImageView) {
        return;
    }

    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;

    _enable = YES;
    _puzzlePattern = TTGPuzzleVerifyClassicPattern;
    _puzzleSize = TTGPuzzleVerifyDefaultPuzzleSize;
    _puzzleBlankPosition = CGPointZero;
    _puzzleContainerPosition = CGPointMake(TTGPuzzleVerifyDefaultPuzzlePosition.x - _puzzleBlankPosition.x,
                                           TTGPuzzleVerifyDefaultPuzzlePosition.y - _puzzleBlankPosition.y);
    _verificationTolerance = TTGPuzzleVerifyDefaultTolerance;
    _puzzleBlankAlpha = TTGPuzzleVerifyDefaultAlpha;
    _puzzleBlankInnerShadowColor = UIColor.blackColor;
    _puzzleBlankInnerShadowRadius = TTGPuzzleVerifyDefaultShadowRadius;
    _puzzleBlankInnerShadowOpacity = TTGPuzzleVerifyDefaultShadowOpacity;
    _puzzleBlankInnerShadowOffset = CGSizeZero;
    _puzzleShadowColor = UIColor.blackColor;
    _puzzleShadowRadius = TTGPuzzleVerifyDefaultShadowRadius;
    _puzzleShadowOpacity = TTGPuzzleVerifyDefaultShadowOpacity;
    _puzzleShadowOffset = CGSizeZero;
    _customPuzzlePatternPath = [UIBezierPath bezierPathWithCGPath:[TTGPuzzleVerifyView verifyPathForPattern:TTGPuzzleVerifyClassicPattern].CGPath];

    [self configureSubviews];
    [self configureMaskLayers];
    [self configureGestureRecognizers];
}

- (void)configureSubviews {
    _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backImageView.userInteractionEnabled = NO;
    _backImageView.contentMode = UIViewContentModeScaleToFill;
    _backImageView.backgroundColor = UIColor.clearColor;
    _backImageView.alpha = _puzzleBlankAlpha;
    [self addSubview:_backImageView];

    _frontImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _frontImageView.userInteractionEnabled = NO;
    _frontImageView.contentMode = UIViewContentModeScaleToFill;
    _frontImageView.backgroundColor = UIColor.clearColor;
    [self addSubview:_frontImageView];

    _puzzleImageContainerView = [[UIView alloc] initWithFrame:CGRectMake(_puzzleContainerPosition.x,
                                                                         _puzzleContainerPosition.y,
                                                                         CGRectGetWidth(self.bounds),
                                                                         CGRectGetHeight(self.bounds))];
    _puzzleImageContainerView.backgroundColor = UIColor.clearColor;
    _puzzleImageContainerView.userInteractionEnabled = NO;
    [self applyPuzzleShadowStyle];
    [self addSubview:_puzzleImageContainerView];

    _puzzleImageView = [[UIImageView alloc] initWithFrame:_puzzleImageContainerView.bounds];
    _puzzleImageView.userInteractionEnabled = NO;
    _puzzleImageView.contentMode = UIViewContentModeScaleToFill;
    _puzzleImageView.backgroundColor = UIColor.clearColor;
    [_puzzleImageContainerView addSubview:_puzzleImageView];
}

- (void)configureMaskLayers {
    _backMaskLayer = [CAShapeLayer layer];
    _backMaskLayer.fillRule = kCAFillRuleEvenOdd;
    _backImageView.layer.mask = _backMaskLayer;

    _frontMaskLayer = [CAShapeLayer layer];
    _frontMaskLayer.fillRule = kCAFillRuleEvenOdd;
    _frontImageView.layer.mask = _frontMaskLayer;

    _puzzleMaskLayer = [CAShapeLayer layer];
    _puzzleImageView.layer.mask = _puzzleMaskLayer;

    _backInnerShadowLayer = [CAShapeLayer layer];
    _backInnerShadowLayer.fillRule = kCAFillRuleEvenOdd;
    [self applyInnerShadowStyle];
    [_backImageView.layer addSublayer:_backInnerShadowLayer];
}

- (void)configureGestureRecognizers {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - Public methods

- (void)completeVerificationWithAnimation:(BOOL)withAnimation {
    void (^updates)(void) = ^{
        [self setPuzzlePosition:self->_puzzleBlankPosition notify:NO];
        self->_puzzleImageContainerView.layer.shadowOpacity = 0;
    };

    if (withAnimation) {
        [UIView animateWithDuration:TTGPuzzleVerifyAnimationDuration animations:updates completion:^(__unused BOOL finished) {
            [self performCallback];
        }];
    } else {
        updates();
        [self performCallback];
    }
}

- (void)resetVerification {
    [self setPuzzlePosition:TTGPuzzleVerifyDefaultPuzzlePosition notify:YES];
}

#pragma mark - Pan gesture

- (void)onPanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (!self.isEnabled) {
        return;
    }

    CGPoint panLocation = [panGestureRecognizer locationInView:self];
    CGPoint position = CGPointMake(panLocation.x - _puzzleSize.width / 2.0,
                                   panLocation.y - _puzzleSize.height / 2.0);

    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:TTGPuzzleVerifyAnimationDuration animations:^{
            [self setPuzzlePosition:position notify:NO];
        } completion:^(__unused BOOL finished) {
            [self performCallback];
        }];
    } else {
        [self setPuzzlePosition:position notify:YES];
    }
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];

    _backImageView.frame = self.bounds;
    _frontImageView.frame = self.bounds;
    _puzzleImageContainerView.frame = CGRectMake(_puzzleContainerPosition.x,
                                                 _puzzleContainerPosition.y,
                                                 CGRectGetWidth(self.bounds),
                                                 CGRectGetHeight(self.bounds));
    _puzzleImageView.frame = _puzzleImageContainerView.bounds;

    [self updatePuzzleMask];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [self updatePuzzleMask];
    }
}

#pragma mark - Update Mask layer

- (void)updatePuzzleMask {
    if (CGRectIsEmpty(self.bounds) || !_backMaskLayer || !_frontMaskLayer || !_puzzleMaskLayer) {
        return;
    }

    UIBezierPath *puzzlePath = [self newScaledPuzzlePath];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [maskPath appendPath:[UIBezierPath bezierPathWithCGPath:puzzlePath.CGPath]];
    maskPath.usesEvenOddFillRule = YES;

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    _backMaskLayer.frame = self.bounds;
    _backMaskLayer.path = puzzlePath.CGPath;
    _frontMaskLayer.frame = self.bounds;
    _frontMaskLayer.path = maskPath.CGPath;
    _puzzleMaskLayer.frame = self.bounds;
    _puzzleMaskLayer.path = puzzlePath.CGPath;

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds,
                                                                            TTGPuzzleVerifyShadowInset,
                                                                            TTGPuzzleVerifyShadowInset)];
    [shadowPath appendPath:puzzlePath];
    _backInnerShadowLayer.frame = self.bounds;
    _backInnerShadowLayer.path = shadowPath.CGPath;

    [CATransaction commit];
}

#pragma mark - Callback

- (void)performCallback {
    BOOL isVerified = self.isVerified;
    CGFloat xPercentage = self.puzzleXPercentage;
    CGFloat yPercentage = self.puzzleYPercentage;
    CGPoint puzzlePosition = self.puzzlePosition;

    if ([_delegate respondsToSelector:@selector(puzzleVerifyView:didChangedPuzzlePosition:xPercentage:yPercentage:)]) {
        [_delegate puzzleVerifyView:self didChangedPuzzlePosition:puzzlePosition xPercentage:xPercentage yPercentage:yPercentage];
    }

    if (_lastVerification != isVerified) {
        _lastVerification = isVerified;

        if ([_delegate respondsToSelector:@selector(puzzleVerifyView:didChangedVerification:)]) {
            [_delegate puzzleVerifyView:self didChangedVerification:isVerified];
        }

        if (_verificationChangeBlock) {
            _verificationChangeBlock(self, isVerified);
        }
    }
}

#pragma mark - Setter and getter

- (UIBezierPath *)newScaledPuzzlePath {
    UIBezierPath *sourcePath = nil;

    if (_puzzlePattern == TTGPuzzleVerifyCustomPattern && _customPuzzlePatternPath) {
        sourcePath = [UIBezierPath bezierPathWithCGPath:_customPuzzlePatternPath.CGPath];
        _puzzleSize = sourcePath.bounds.size;
    } else {
        sourcePath = [UIBezierPath bezierPathWithCGPath:[TTGPuzzleVerifyView verifyPathForPattern:_puzzlePattern].CGPath];
        CGSize sourceSize = sourcePath.bounds.size;
        if (sourceSize.width > 0 && sourceSize.height > 0) {
            [sourcePath applyTransform:CGAffineTransformMakeScale(_puzzleSize.width / sourceSize.width,
                                                                  _puzzleSize.height / sourceSize.height)];
        }
    }

    CGRect bounds = sourcePath.bounds;
    [sourcePath applyTransform:CGAffineTransformMakeTranslation(_puzzleBlankPosition.x - bounds.origin.x,
                                                               _puzzleBlankPosition.y - bounds.origin.y)];
    return sourcePath;
}

// Puzzle position

- (void)setPuzzlePosition:(CGPoint)puzzlePosition {
    [self setPuzzlePosition:puzzlePosition notify:NO];
}

- (void)setPuzzlePosition:(CGPoint)puzzlePosition notify:(BOOL)notify {
    if (!self.isEnabled) {
        return;
    }

    puzzlePosition = [self clampedPuzzlePosition:puzzlePosition];
    _puzzleImageContainerView.layer.shadowOpacity = _puzzleShadowOpacity;
    [self setPuzzleContainerPosition:CGPointMake(puzzlePosition.x - _puzzleBlankPosition.x,
                                                 puzzlePosition.y - _puzzleBlankPosition.y)];

    if (notify) {
        [self performCallback];
    }
}

- (CGPoint)puzzlePosition {
    return CGPointMake(_puzzleContainerPosition.x + _puzzleBlankPosition.x,
                       _puzzleContainerPosition.y + _puzzleBlankPosition.y);
}

// Puzzle blank position

- (void)setPuzzleBlankPosition:(CGPoint)puzzleBlankPosition {
    _puzzleBlankPosition = [self clampedPuzzleBlankPosition:puzzleBlankPosition];
    [self setPuzzlePosition:self.puzzlePosition notify:NO];
    [self updatePuzzleMask];
}

// Puzzle pattern

- (void)setPuzzlePattern:(TTGPuzzleVerifyPattern)puzzlePattern {
    _puzzlePattern = puzzlePattern;
    [self updatePuzzleMask];
}

// Image

- (void)setImage:(UIImage *)image {
    _image = image;
    _backImageView.image = image;
    _frontImageView.image = image;
    _puzzleImageView.image = image;
    [self updatePuzzleMask];
}

// Puzzle size

- (void)setPuzzleSize:(CGSize)puzzleSize {
    _puzzleSize = CGSizeMake(MAX(1.0, puzzleSize.width), MAX(1.0, puzzleSize.height));
    [self setPuzzlePosition:self.puzzlePosition notify:NO];
    [self updatePuzzleMask];
}

// Puzzle custom pattern path

- (void)setCustomPuzzlePatternPath:(UIBezierPath *)customPuzzlePatternPath {
    _customPuzzlePatternPath = customPuzzlePatternPath;
    [self updatePuzzleMask];
}

// Puzzle container position

- (void)setPuzzleContainerPosition:(CGPoint)puzzleContainerPosition {
    _puzzleContainerPosition = puzzleContainerPosition;
    CGRect frame = _puzzleImageContainerView.frame;
    frame.origin = puzzleContainerPosition;
    _puzzleImageContainerView.frame = frame;
}

// Puzzle X position percentage

- (CGFloat)puzzleXPercentage {
    CGFloat range = self.puzzleMaxX - self.puzzleMinX;
    if (range <= 0) {
        return 0;
    }
    return (self.puzzlePosition.x - self.puzzleMinX) / range;
}

- (void)setPuzzleXPercentage:(CGFloat)puzzleXPercentage {
    if (!self.isEnabled) {
        return;
    }

    puzzleXPercentage = [self clampedPercentage:puzzleXPercentage];
    CGPoint position = self.puzzlePosition;
    position.x = puzzleXPercentage * (self.puzzleMaxX - self.puzzleMinX) + self.puzzleMinX;
    [self setPuzzlePosition:position notify:YES];
}

// Puzzle Y position percentage

- (CGFloat)puzzleYPercentage {
    CGFloat range = self.puzzleMaxY - self.puzzleMinY;
    if (range <= 0) {
        return 0;
    }
    return (self.puzzlePosition.y - self.puzzleMinY) / range;
}

- (void)setPuzzleYPercentage:(CGFloat)puzzleYPercentage {
    if (!self.isEnabled) {
        return;
    }

    puzzleYPercentage = [self clampedPercentage:puzzleYPercentage];
    CGPoint position = self.puzzlePosition;
    position.y = puzzleYPercentage * (self.puzzleMaxY - self.puzzleMinY) + self.puzzleMinY;
    [self setPuzzlePosition:position notify:YES];
}

// isVerified

- (BOOL)isVerified {
    return fabs(self.puzzlePosition.x - _puzzleBlankPosition.x) <= _verificationTolerance &&
           fabs(self.puzzlePosition.y - _puzzleBlankPosition.y) <= _verificationTolerance;
}

#pragma mark - Bounds helpers

- (CGPoint)clampedPuzzlePosition:(CGPoint)puzzlePosition {
    puzzlePosition.x = MIN(MAX(self.puzzleMinX, puzzlePosition.x), self.puzzleMaxX);
    puzzlePosition.y = MIN(MAX(self.puzzleMinY, puzzlePosition.y), self.puzzleMaxY);
    return puzzlePosition;
}

- (CGPoint)clampedPuzzleBlankPosition:(CGPoint)puzzleBlankPosition {
    return [self clampedPuzzlePosition:puzzleBlankPosition];
}

- (CGFloat)clampedPercentage:(CGFloat)percentage {
    if (!isfinite(percentage)) {
        return 0;
    }
    return MIN(MAX(0, percentage), 1);
}

// Puzzle position range

- (CGFloat)puzzleMinX {
    return 0;
}

- (CGFloat)puzzleMaxX {
    return MAX(self.puzzleMinX, CGRectGetWidth(self.bounds) - _puzzleSize.width);
}

- (CGFloat)puzzleMinY {
    return 0;
}

- (CGFloat)puzzleMaxY {
    return MAX(self.puzzleMinY, CGRectGetHeight(self.bounds) - _puzzleSize.height);
}

// Puzzle shadow

- (void)applyPuzzleShadowStyle {
    _puzzleImageContainerView.layer.shadowColor = _puzzleShadowColor.CGColor;
    _puzzleImageContainerView.layer.shadowRadius = _puzzleShadowRadius;
    _puzzleImageContainerView.layer.shadowOpacity = _puzzleShadowOpacity;
    _puzzleImageContainerView.layer.shadowOffset = _puzzleShadowOffset;
}

- (void)setPuzzleShadowColor:(UIColor *)puzzleShadowColor {
    _puzzleShadowColor = puzzleShadowColor ?: UIColor.blackColor;
    [self applyPuzzleShadowStyle];
}

- (void)setPuzzleShadowRadius:(CGFloat)puzzleShadowRadius {
    _puzzleShadowRadius = MAX(0, puzzleShadowRadius);
    [self applyPuzzleShadowStyle];
}

- (void)setPuzzleShadowOpacity:(CGFloat)puzzleShadowOpacity {
    _puzzleShadowOpacity = MIN(MAX(0, puzzleShadowOpacity), 1);
    [self applyPuzzleShadowStyle];
}

- (void)setPuzzleShadowOffset:(CGSize)puzzleShadowOffset {
    _puzzleShadowOffset = puzzleShadowOffset;
    [self applyPuzzleShadowStyle];
}

// Puzzle blank alpha

- (void)setPuzzleBlankAlpha:(CGFloat)puzzleBlankAlpha {
    _puzzleBlankAlpha = MIN(MAX(0, puzzleBlankAlpha), 1);
    _backImageView.alpha = _puzzleBlankAlpha;
}

// Puzzle blank inner shadow

- (void)applyInnerShadowStyle {
    _backInnerShadowLayer.shadowColor = _puzzleBlankInnerShadowColor.CGColor;
    _backInnerShadowLayer.shadowRadius = _puzzleBlankInnerShadowRadius;
    _backInnerShadowLayer.shadowOpacity = _puzzleBlankInnerShadowOpacity;
    _backInnerShadowLayer.shadowOffset = _puzzleBlankInnerShadowOffset;
}

- (void)setPuzzleBlankInnerShadowColor:(UIColor *)puzzleBlankInnerShadowColor {
    _puzzleBlankInnerShadowColor = puzzleBlankInnerShadowColor ?: UIColor.blackColor;
    [self applyInnerShadowStyle];
}

- (void)setPuzzleBlankInnerShadowRadius:(CGFloat)puzzleBlankInnerShadowRadius {
    _puzzleBlankInnerShadowRadius = MAX(0, puzzleBlankInnerShadowRadius);
    [self applyInnerShadowStyle];
}

- (void)setPuzzleBlankInnerShadowOpacity:(CGFloat)puzzleBlankInnerShadowOpacity {
    _puzzleBlankInnerShadowOpacity = MIN(MAX(0, puzzleBlankInnerShadowOpacity), 1);
    [self applyInnerShadowStyle];
}

- (void)setPuzzleBlankInnerShadowOffset:(CGSize)puzzleBlankInnerShadowOffset {
    _puzzleBlankInnerShadowOffset = puzzleBlankInnerShadowOffset;
    [self applyInnerShadowStyle];
}

@end
