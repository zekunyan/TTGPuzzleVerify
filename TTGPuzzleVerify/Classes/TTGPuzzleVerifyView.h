//
//  TTGPuzzleVerifyView.h
//  Pods
//
//  Created by tutuge on 2016/12/10.
//
//

#import <UIKit/UIKit.h>

/**
 * TTGPuzzleVerifyView pattern type
 */
typedef NS_ENUM(NSInteger, TTGPuzzleVerifyPattern) {
    TTGPuzzleVerifyClassicPattern = 0, // Default
    TTGPuzzleVerifySquarePattern,
    TTGPuzzleVerifyCirclePattern,
    TTGPuzzleVerifyCustomPattern
};

@class TTGPuzzleVerifyView;

/**
 * Verification changed callback delegate
 */
@protocol TTGPuzzleVerifyViewDelegate <NSObject>
@optional
- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedVerification:(BOOL)isVerified;

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedPuzzlePosition:(CGPoint)newPosition
             xPercentage:(CGFloat)xPercentage yPercentage:(CGFloat)yPercentage;
@end

/**
 * TTGPuzzleVerifyView
 */
@interface TTGPuzzleVerifyView : UIView
@property (nonatomic, strong) UIImage *image; // Image for verification

// Puzzle pattern, default is TTGPuzzleVerifyClassicPattern
@property (nonatomic, assign) TTGPuzzleVerifyPattern puzzlePattern;

// Custom path for puzzle shape. Only work when puzzlePattern is TTGPuzzleVerifyCustomPattern
@property (nonatomic, strong) UIBezierPath *customPuzzlePatternPath;

// Puzzle rect size，not for TTGPuzzleVerifyCustomPattern pattern
@property (nonatomic, assign) CGSize puzzleSize;

// Puzzle blank position
@property (nonatomic, assign) CGPoint puzzleBlankPosition;

// Puzzle current position
@property (nonatomic, assign) CGPoint puzzlePosition;

// Puzzle current X and Y position percentage, range: [0, 1]
@property (nonatomic, assign) CGFloat puzzleXPercentage;
@property (nonatomic, assign) CGFloat puzzleYPercentage;

// Verification
@property (nonatomic, assign) CGFloat verificationTolerance; // Verification tolerance, default is 8
@property (nonatomic, assign, readonly) BOOL isVerified; // Verification boolean

// Enable
@property (nonatomic, assign) BOOL enable;

/**
 * Style
 */

// Puzzle blank alpha, default is 0.5
@property (nonatomic, assign) CGFloat puzzleBlankAlpha;

// Puzzle blank inner shadow
@property (nonatomic, strong) UIColor *puzzleBlankInnerShadowColor; // Default: black
@property (nonatomic, assign) CGFloat puzzleBlankInnerShadowRadius; // Default: 4
@property (nonatomic, assign) CGFloat puzzleBlankInnerShadowOpacity; // Default: 0.5
@property (nonatomic, assign) CGSize puzzleBlankInnerShadowOffset; // Default: (0, 0)

// Puzzle shadow
@property (nonatomic, strong) UIColor *puzzleShadowColor; // Default: black
@property (nonatomic, assign) CGFloat puzzleShadowRadius; // Default: 4
@property (nonatomic, assign) CGFloat puzzleShadowOpacity; // Default: 0.5
@property (nonatomic, assign) CGSize puzzleShadowOffset; // Default: (0, 0)

// Callback
@property (nonatomic, weak) id <TTGPuzzleVerifyViewDelegate> delegate; // Callback delegate
@property (nonatomic, copy) void (^verificationChangeBlock)(TTGPuzzleVerifyView *puzzleVerifyView, BOOL isVerified); // verification changed callback block


/**
 Complete verification. Call this with set the puzzle to its original position and fill the blank.

 @param withAnimation if show animation
 */
- (void)completeVerificationWithAnimation:(BOOL)withAnimation;

@end
