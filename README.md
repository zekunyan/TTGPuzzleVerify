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

## Examples

The repository now includes two runnable example apps:

* Objective-C UIKit example: run `pod install` from the `Example` directory, then open `Example/TTGPuzzleVerify.xcworkspace`.
* Swift 5.9 example with UIKit and SwiftUI demos: run `pod install` from `Example/SwiftExample`, then open `Example/SwiftExample/TTGPuzzleVerifySwiftExample.xcworkspace`.

## Requirements
iOS 16.0 and later. Swift 5.9 is used for SwiftPM/CocoaPods metadata and the Swift example.

## Installation

TTGPuzzleVerify is available through [CocoaPods](http://cocoapods.org). To install
it, set an iOS 16 deployment target and add the following line to your Podfile:

```ruby
platform :ios, '16.0'
pod "TTGPuzzleVerify"
```

Swift Package Manager is also supported for iOS 16+ projects by adding this repository as a package dependency.

## Usage
`TTGPuzzleVerifyView` (implemented in Swift and exposed to Objective-C)

### Basic use
```
// Import
#import <TTGPuzzleVerify/TTGPuzzleVerify-Swift.h>

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
    TTGPuzzleVerifyPatternClassicPattern = 0, // Default
    TTGPuzzleVerifyPatternSquarePattern,
    TTGPuzzleVerifyPatternCirclePattern,
    TTGPuzzleVerifyPatternCustomPattern
};

// Puzzle pattern, default is TTGPuzzleVerifyPatternClassicPattern
@property (nonatomic, assign) TTGPuzzleVerifyPattern puzzlePattern;

// Custom path for puzzle shape. Only work when puzzlePattern is TTGPuzzleVerifyPatternCustomPattern
@property (nonatomic, strong) UIBezierPath *customPuzzlePatternPath;
```

#### Complete or reset the puzzle
```
/**
 Complete verification. Call this to move the puzzle to its blank position and fill the blank.

 @param withAnimation if show animation
 */
- (void)completeVerificationWithAnimation:(BOOL)withAnimation;

/**
 Reset verification. Call this to move the puzzle back to the default start position.
 */
- (void)resetVerification;
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
// Puzzle rect size，not for TTGPuzzleVerifyPatternCustomPattern pattern
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

## Author

zekunyan, zekunyan@163.com

## License

TTGPuzzleVerify is available under the MIT license. See the LICENSE file for more info.
