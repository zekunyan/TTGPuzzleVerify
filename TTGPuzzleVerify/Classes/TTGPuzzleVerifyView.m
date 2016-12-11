//
//  TTGPuzzleVerifyView.m
//  Pods
//
//  Created by tutuge on 2016/12/10.
//
//

#import "TTGPuzzleVerifyView.h"
#import "TTGPuzzleVerifyView+PatternPathProvider.h"

static CGSize kTTGPuzzleDefaultSize;
static CGFloat kTTGPuzzleAnimationDuration = 0.3;

@interface TTGPuzzleVerifyView ()
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) CAShapeLayer *backInnerShadowLayer;

@property (nonatomic, strong) UIImageView *frontImageView;

@property (nonatomic, strong) UIImageView *puzzleImageView;
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

    // Init value
    kTTGPuzzleDefaultSize = CGSizeMake(100, 100);
    self.enable = YES;
    self.puzzlePattern = TTGPuzzleVerifyClassicPattern;
    self.customPuzzlePatternPath = [self getNewScaledPuzzledPath];
    self.puzzleSize = kTTGPuzzleDefaultSize;
    self.puzzleBlankPosition = CGPointZero;
    self.puzzlePosition = CGPointMake(20, 20);
    self.verificationTolerance = 8;
    
    self.puzzleBlankAlpha = 0.5;
    self.puzzleBlankInnerShadowColor = [UIColor blackColor];
    self.puzzleBlankInnerShadowRadius = 4;
    self.puzzleBlankInnerShadowOpacity = 0.5;
    self.puzzleBlankInnerShadowOffset = CGSizeZero;

    self.puzzleShadowColor = [UIColor blackColor];
    self.puzzleShadowRadius = 4;
    self.puzzleShadowOpacity = 0.5;
    self.puzzleShadowOffset = CGSizeZero;

    // Back puzzle blank image view
    _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backImageView.userInteractionEnabled = NO;
    _backImageView.contentMode = UIViewContentModeScaleToFill;
    _backImageView.backgroundColor = [UIColor clearColor];
    _backImageView.alpha = _puzzleBlankAlpha;
    [self addSubview:_backImageView];

    // Front puzzle hole image view
    _frontImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _frontImageView.userInteractionEnabled = NO;
    _frontImageView.contentMode = UIViewContentModeScaleToFill;
    _frontImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:_frontImageView];

    // Puzzle piece container view
    _puzzleImageContainerView = [[UIView alloc] initWithFrame:CGRectMake(
            _puzzleContainerPosition.x, _puzzleContainerPosition.y,
            CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    _puzzleImageContainerView.backgroundColor = [UIColor clearColor];
    _puzzleImageContainerView.userInteractionEnabled = NO;
    _puzzleImageContainerView.layer.shadowColor = _puzzleShadowColor.CGColor;
    _puzzleImageContainerView.layer.shadowRadius = _puzzleShadowRadius;
    _puzzleImageContainerView.layer.shadowOpacity = _puzzleShadowOpacity;
    _puzzleImageContainerView.layer.shadowOffset = _puzzleShadowOffset;
    [self addSubview:_puzzleImageContainerView];

    // Puzzle piece imageView
    _puzzleImageView = [[UIImageView alloc] initWithFrame:_puzzleImageContainerView.bounds];
    _puzzleImageView.userInteractionEnabled = NO;
    _puzzleImageView.contentMode = UIViewContentModeScaleToFill;
    _puzzleImageView.backgroundColor = [UIColor clearColor];
    [_puzzleImageContainerView addSubview:_puzzleImageView];

    // Inner shadow layer
    _backInnerShadowLayer = [CAShapeLayer layer];
    _backInnerShadowLayer.frame = self.bounds;
    _backInnerShadowLayer.fillRule = kCAFillRuleEvenOdd;
    _backInnerShadowLayer.shadowColor = _puzzleBlankInnerShadowColor.CGColor;
    _backInnerShadowLayer.shadowRadius = _puzzleBlankInnerShadowRadius;
    _backInnerShadowLayer.shadowOpacity = _puzzleBlankInnerShadowOpacity;
    _backInnerShadowLayer.shadowOffset = _puzzleBlankInnerShadowOffset;

    // Pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [UIPanGestureRecognizer new];
    [panGestureRecognizer addTarget:self action:@selector(onPanGesture:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - Public methods

- (void)completeVerificationWithAnimation:(BOOL)withAnimation {
    if (withAnimation) {
        [UIView animateWithDuration:kTTGPuzzleAnimationDuration animations:^{
            [self setPuzzlePosition:_puzzleBlankPosition];
            _puzzleImageContainerView.layer.shadowOpacity = 0;
        }];
    } else {
        [self setPuzzlePosition:_puzzleBlankPosition];
        _puzzleImageContainerView.layer.shadowOpacity = 0;
    }
}

#pragma mark - Pan gesture

- (void)onPanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint panLocation = [panGestureRecognizer locationInView:self];

    // New position
    CGPoint position = CGPointZero;
    position.x = panLocation.x - _puzzleSize.width / 2;
    position.y = panLocation.y - _puzzleSize.height / 2;

    // Update position
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // Animate move
        [UIView animateWithDuration:kTTGPuzzleAnimationDuration animations:^{
            [self setPuzzlePosition:position];
        }];
    } else {
        [self setPuzzlePosition:position];
    }
    
    // Callback
    [self performCallback];
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];

    _backImageView.frame = self.bounds;
    _frontImageView.frame = self.bounds;
    _puzzleImageContainerView.frame = CGRectMake(
            _puzzleContainerPosition.x, _puzzleContainerPosition.y,
            CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
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
    if (!self.superview) {
        return;
    }

    // Paths
    UIBezierPath *puzzlePath = [self getNewScaledPuzzledPath];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [maskPath appendPath:[UIBezierPath bezierPathWithCGPath:puzzlePath.CGPath]];
    maskPath.usesEvenOddFillRule = YES;

    // Layers
    CAShapeLayer *backMaskLayer = [CAShapeLayer new];
    backMaskLayer.frame = self.bounds;
    backMaskLayer.path = puzzlePath.CGPath;
    backMaskLayer.fillRule = kCAFillRuleEvenOdd;
    
    CAShapeLayer *frontMaskLayer = [CAShapeLayer new];
    frontMaskLayer.frame = self.bounds;
    frontMaskLayer.path = maskPath.CGPath;
    frontMaskLayer.fillRule = kCAFillRuleEvenOdd;

    CAShapeLayer *puzzleMaskLayer = [CAShapeLayer new];
    puzzleMaskLayer.frame = self.bounds;
    puzzleMaskLayer.path = puzzlePath.CGPath;

    _backImageView.layer.mask = backMaskLayer;
    _frontImageView.layer.mask = frontMaskLayer;
    _puzzleImageView.layer.mask = puzzleMaskLayer;

    // Puzzle blank inner shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectInset(self.bounds, -20, -20)]; // Outer rect
    [shadowPath appendPath:puzzlePath]; // Inner shape

    _backInnerShadowLayer.frame = self.bounds;
    _backInnerShadowLayer.path = shadowPath.CGPath;
    
    [[_backImageView.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_backImageView.layer addSublayer:_backInnerShadowLayer];
}

#pragma mark - Callback

- (void)performCallback {
    // Callback for position change
    if ([_delegate respondsToSelector:@selector(puzzleVerifyView:didChangedPuzzlePosition:xPercentage:yPercentage:)]) {
        [_delegate puzzleVerifyView:self didChangedPuzzlePosition:[self puzzlePosition]
                        xPercentage:[self puzzleXPercentage] yPercentage:[self puzzleYPercentage]];
    }
    
    // Callback if verification changed
    if (_lastVerification != [self isVerified]) {
        _lastVerification = [self isVerified];
        
        // Delegate
        if ([_delegate respondsToSelector:@selector(puzzleVerifyView:didChangedVerification:)]) {
            [_delegate puzzleVerifyView:self didChangedVerification:[self isVerified]];
        }
        
        // Block
        if (_verificationChangeBlock) {
            _verificationChangeBlock(self, [self isVerified]);
        }
    }
}

#pragma mark - Setter and getter

- (UIBezierPath *)getNewScaledPuzzledPath {
    UIBezierPath *path = nil;
    
    // Pattern path
    if (_puzzlePattern == TTGPuzzleVerifyCustomPattern) {
        path = [UIBezierPath bezierPathWithCGPath:_customPuzzlePatternPath.CGPath];
        _puzzleSize = path.bounds.size;
    } else {
        path = [UIBezierPath bezierPathWithCGPath:[TTGPuzzleVerifyView verifyPathForPattern:_puzzlePattern].CGPath];
        // Apply scale transform
        [path applyTransform:CGAffineTransformMakeScale(
                                                        _puzzleSize.width / path.bounds.size.width,
                                                        _puzzleSize.height / path.bounds.size.height)];
    }
    
    // Apply position transform
    [path applyTransform:CGAffineTransformMakeTranslation(
            _puzzleBlankPosition.x - path.bounds.origin.x,
            _puzzleBlankPosition.y - path.bounds.origin.y)];
    
    return path;
}

// Puzzle position

- (void)setPuzzlePosition:(CGPoint)puzzlePosition {
    if (!_enable) {
        return;
    }
    
    // Limit range
    puzzlePosition.x = MAX([self puzzleMinX], puzzlePosition.x);
    puzzlePosition.x = MIN([self puzzleMaxX], puzzlePosition.x);
    
    puzzlePosition.y = MAX([self puzzleMinY], puzzlePosition.y);
    puzzlePosition.y = MIN([self puzzleMaxY], puzzlePosition.y);
    
    // Reset shadow
    _puzzleImageContainerView.layer.shadowOpacity = _puzzleShadowOpacity;
    
    // Set puzzle image container position
    [self setPuzzleContainerPosition:CGPointMake(puzzlePosition.x - _puzzleBlankPosition.x,
                                                 puzzlePosition.y - _puzzleBlankPosition.y)];
}

- (CGPoint)puzzlePosition {
    return CGPointMake(_puzzleContainerPosition.x + _puzzleBlankPosition.x,
                       _puzzleContainerPosition.y + _puzzleBlankPosition.y);
}

// Puzzle blank position

- (void)setPuzzleBlankPosition:(CGPoint)puzzleBlankPosition {
    _puzzleBlankPosition = puzzleBlankPosition;
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
    _backImageView.image = _image;
    _frontImageView.image = _image;
    _puzzleImageView.image = _image;
    [self updatePuzzleMask];
}

// Puzzle size

- (void)setPuzzleSize:(CGSize)puzzleSize {
    _puzzleSize = puzzleSize;
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
    return ([self puzzlePosition].x - [self puzzleMinX]) / ([self puzzleMaxX] - [self puzzleMinX]);
}

- (void)setPuzzleXPercentage:(CGFloat)puzzleXPercentage {
    if (!_enable) {
        return;
    }
    
    // Limit range
    puzzleXPercentage = MAX(0, puzzleXPercentage);
    puzzleXPercentage = MIN(1, puzzleXPercentage);

    // Change position
    CGPoint position = [self puzzlePosition];
    position.x = puzzleXPercentage * ([self puzzleMaxX] - [self puzzleMinX]) + [self puzzleMinX];
    [self setPuzzlePosition:position];
    
    // Callback
    [self performCallback];
}

// Puzzle Y position percentage

- (CGFloat)puzzleYPercentage {
    return ([self puzzlePosition].y - [self puzzleMinY]) / ([self puzzleMaxY] - [self puzzleMinY]);
}

- (void)setPuzzleYPercentage:(CGFloat)puzzleYPercentage {
    if (!_enable) {
        return;
    }
    
    // Limit range
    puzzleYPercentage = MAX(0, puzzleYPercentage);
    puzzleYPercentage = MIN(1, puzzleYPercentage);

    // Change position
    CGPoint position = [self puzzlePosition];
    position.y = puzzleYPercentage * ([self puzzleMaxY] - [self puzzleMinY]) + [self puzzleMinY];
    [self setPuzzlePosition:position];
    
    // Callback
    [self performCallback];
}

// isVerified

- (BOOL)isVerified {
    return fabsf([self puzzlePosition].x - _puzzleBlankPosition.x) <= _verificationTolerance &&
           fabsf([self puzzlePosition].y - _puzzleBlankPosition.y) <= _verificationTolerance;
}

// Puzzle position range

- (CGFloat)puzzleMinX {
    return 0;
}

- (CGFloat)puzzleMaxX {
    return CGRectGetWidth(self.bounds) - _puzzleSize.width;
}

- (CGFloat)puzzleMinY {
    return 0;
}

- (CGFloat)puzzleMaxY {
    return CGRectGetHeight(self.bounds) - _puzzleSize.height;
}

// Puzzle shadow

- (void)setPuzzleShadowColor:(UIColor *)puzzleShadowColor {
    _puzzleShadowColor = puzzleShadowColor;
    _puzzleImageContainerView.layer.shadowColor = puzzleShadowColor.CGColor;
}

- (void)setPuzzleShadowRadius:(CGFloat)puzzleShadowRadius {
    _puzzleShadowRadius = puzzleShadowRadius;
    _puzzleImageContainerView.layer.shadowRadius = puzzleShadowRadius;
}

- (void)setPuzzleShadowOpacity:(CGFloat)puzzleShadowOpacity {
    _puzzleShadowOpacity = puzzleShadowOpacity;
    _puzzleImageContainerView.layer.shadowOpacity = puzzleShadowOpacity;
}

- (void)setPuzzleShadowOffset:(CGSize)puzzleShadowOffset {
    _puzzleShadowOffset = puzzleShadowOffset;
    _puzzleImageContainerView.layer.shadowOffset = puzzleShadowOffset;
}

// Puzzle blank alpha

- (void)setPuzzleBlankAlpha:(CGFloat)puzzleBlankAlpha {
    _puzzleBlankAlpha = puzzleBlankAlpha;
    _backImageView.alpha = puzzleBlankAlpha;
}

// Puzzle blank inner shadow

- (void)setPuzzleBlankInnerShadowColor:(UIColor *)puzzleBlankInnerShadowColor {
    _puzzleBlankInnerShadowColor = puzzleBlankInnerShadowColor;
    _backInnerShadowLayer.shadowColor = puzzleBlankInnerShadowColor.CGColor;
}

- (void)setPuzzleBlankInnerShadowRadius:(CGFloat)puzzleBlankInnerShadowRadius {
    _puzzleBlankInnerShadowRadius = puzzleBlankInnerShadowRadius;
    _backInnerShadowLayer.shadowRadius = puzzleBlankInnerShadowRadius;
}

- (void)setPuzzleBlankInnerShadowOpacity:(CGFloat)puzzleBlankInnerShadowOpacity {
    _puzzleBlankInnerShadowOpacity = puzzleBlankInnerShadowOpacity;
    _backInnerShadowLayer.shadowOpacity = puzzleBlankInnerShadowOpacity;
}

- (void)setPuzzleBlankInnerShadowOffset:(CGSize)puzzleBlankInnerShadowOffset {
    _puzzleBlankInnerShadowOffset = puzzleBlankInnerShadowOffset;
    _backInnerShadowLayer.shadowOffset = puzzleBlankInnerShadowOffset;
}

@end
