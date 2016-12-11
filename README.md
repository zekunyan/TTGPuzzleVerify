# TTGPuzzleVerify

[![CI Status](http://img.shields.io/travis/zekunyan/TTGPuzzleVerify.svg?style=flat)](https://travis-ci.org/zekunyan/TTGPuzzleVerify)
[![Version](https://img.shields.io/cocoapods/v/TTGPuzzleVerify.svg?style=flat)](http://cocoapods.org/pods/TTGPuzzleVerify)
[![License](https://img.shields.io/cocoapods/l/TTGPuzzleVerify.svg?style=flat)](http://cocoapods.org/pods/TTGPuzzleVerify)
[![Platform](https://img.shields.io/cocoapods/p/TTGPuzzleVerify.svg?style=flat)](http://cocoapods.org/pods/TTGPuzzleVerify)

![Screenshot](https://github.com/zekunyan/TTGPuzzleVerify/raw/master/Resources/TTGPuzzleVerify.jpeg)

![Gif](https://github.com/zekunyan/TTGPuzzleVerify/raw/master/Resources/TTGPuzzleVerify.gif)

## What 
By completing **image puzzle game**, TTGPuzzleVerify is a **more user-friendly** verification tool on iOS, which is highly customizable and easy to use. It supports square, circle, classic or custom puzzle shape. User can complete the verification by sliding horizontally, vertically or directly dragging the puzzle block.

## Features
* More user-friendly
* Highly Customizable
* Classic, square, circle or custom puzzle shape
* Slide horizontally or vertically or drag the puzzle directly

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
iOS 7 and later.

## Installation

TTGPuzzleVerify is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TTGPuzzleVerify"
```

## Usage
`TTGPuzzleVerifyView`

### Basic use
```
// Import
#import <TTGPuzzleVerify/TTGPuzzleVerifyView.h>

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create TTGPuzzleVerifyView instance
    _puzzleVerifyView = [[TTGPuzzleVerifyView alloc] initWithFrame:CGRectMake(20, 20, 320, 200)];
    [self.view addSubview:_puzzleVerifyView];
    
    // Set image
    _puzzleVerifyView.image = [UIImage imageNamed:@"pic"];
    
    // Set the puzzle blank position
    _puzzleVerifyView.puzzleBlankPosition = CGPointMake(200, 40);
    
    // Set init puzzle position
    _puzzleVerifyView.puzzlePosition = CGPointMake(10, 40);
    
    // Callback
    [_puzzleVerifyView setVerificationChangeBlock:^(TTGPuzzleVerifyView *view, BOOL isVerified) {
        if (isVerified) {
            // User complete the verification
        }
    }];
}

// On slide changed
- (IBAction)onSliderChange:(UISlider *)sender {
    // Update position
    _puzzleVerifyView.puzzleXPercentage = sender.value;
}

```

### API
#### Puzzle pattern types
```
/**
 * TTGPuzzleVerifyView pattern type
 */
typedef NS_ENUM(NSInteger, TTGPuzzleVerifyPattern) {
    TTGPuzzleVerifyClassicPattern = 0, // Default
    TTGPuzzleVerifySquarePattern,
    TTGPuzzleVerifyCirclePattern,
    TTGPuzzleVerifyCustomPattern
};

// Puzzle pattern, default is TTGPuzzleVerifyClassicPattern
@property (nonatomic, assign) TTGPuzzleVerifyPattern puzzlePattern;

// Custom path for puzzle shape. Only work when puzzlePattern is TTGPuzzleVerifyCustomPattern
@property (nonatomic, strong) UIBezierPath *customPuzzlePatternPath;
```

#### Complete the puzzle with animation
```
/**
 Complete verification. Call this with set the puzzle to its original position and fill the blank.

 @param withAnimation if show animation
 */
- (void)completeVerificationWithAnimation:(BOOL)withAnimation;
```

#### Callback
```
/**
 * Verification changed callback delegate
 */
@protocol TTGPuzzleVerifyViewDelegate <NSObject>
@optional
- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedVerification:(BOOL)isVerified;

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedPuzzlePosition:(CGPoint)newPosition
             xPercentage:(CGFloat)xPercentage yPercentage:(CGFloat)yPercentage;
@end

// Callback block and delegate
@property (nonatomic, weak) id <TTGPuzzleVerifyViewDelegate> delegate; // Callback delegate
@property (nonatomic, copy) void (^verificationChangeBlock)(TTGPuzzleVerifyView *puzzleVerifyView, BOOL isVerified); // verification changed callback block
```

#### Puzzle image
```
@property (nonatomic, strong) UIImage *image; // Image for verification
```

#### Puzzle size and position
```
// Puzzle rect size，not for TTGPuzzleVerifyCustomPattern pattern
@property (nonatomic, assign) CGSize puzzleSize;

// Puzzle blank position
@property (nonatomic, assign) CGPoint puzzleBlankPosition;

// Puzzle current position
@property (nonatomic, assign) CGPoint puzzlePosition;

// Puzzle current X and Y position percentage, range: [0, 1]
@property (nonatomic, assign) CGFloat puzzleXPercentage;
@property (nonatomic, assign) CGFloat puzzleYPercentage;
```

#### Puzzle verification
```
// Verification
@property (nonatomic, assign) CGFloat verificationTolerance; // Verification tolerance, default is 8
@property (nonatomic, assign, readonly) BOOL isVerified; // Verification boolean
```

#### Style
```
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
```

## Example
For more information, you can download the zip and run the example.

## Author

zekunyan, zekunyan@163.com

## License

TTGPuzzleVerify is available under the MIT license. See the LICENSE file for more info.
