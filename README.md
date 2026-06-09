# TTGPuzzleVerify

[![CI Status](http://img.shields.io/travis/zekunyan/TTGPuzzleVerify.svg?style=flat)](https://travis-ci.org/zekunyan/TTGPuzzleVerify)
[![Version](https://img.shields.io/cocoapods/v/TTGPuzzleVerify.svg?style=flat)](http://cocoapods.org/pods/TTGPuzzleVerify)
[![License](https://img.shields.io/cocoapods/l/TTGPuzzleVerify.svg?style=flat)](http://cocoapods.org/pods/TTGPuzzleVerify)
[![Platform](https://img.shields.io/cocoapods/p/TTGPuzzleVerify.svg?style=flat)](http://cocoapods.org/pods/TTGPuzzleVerify)

![Screenshot](https://github.com/zekunyan/TTGPuzzleVerify/raw/master/Resources/TTGPuzzleVerify.jpeg)

![Gif](https://github.com/zekunyan/TTGPuzzleVerify/raw/master/Resources/TTGPuzzleVerify.gif)

## What

TTGPuzzleVerify is an iOS puzzle verification component. The core is implemented in Swift 5.9, exposed to Objective-C, and supports UIKit, Swift UIKit, and SwiftUI integration.

## Features

* Swift 5.9 implementation with Objective-C interoperability.
* iOS 16+ CocoaPods and Swift Package Manager support.
* Classic, square, circle, and custom puzzle paths.
* Horizontal-only, vertical-only, or free two-axis dragging.
* Local verification with configurable tolerance and optional auto-snap.
* Verification state machine: idle, dragging, verified, failed, locked.
* Rich verification result object with offsets, elapsed time, drag distance, and interaction count.
* Drag track collection with timestamp and velocity for behavior analysis.
* Retry/lock support for repeated failures.
* Delegate callbacks plus Swift closure callbacks.
* Centralized configuration and style objects.
* Success and failure feedback animations.

## Examples

The repository includes two runnable example apps:

* Objective-C UIKit example: run `pod install` from the `Example` directory, then open `Example/TTGPuzzleVerify.xcworkspace`.
* Swift 5.9 example with UIKit and SwiftUI demos: run `pod install` from `Example/SwiftExample`, then open `Example/SwiftExample/TTGPuzzleVerifySwiftExample.xcworkspace`.

## Requirements

* iOS 16.0+
* Swift 5.9+
* Xcode 15+

## Installation

### CocoaPods

```ruby
platform :ios, '16.0'
use_frameworks!

pod "TTGPuzzleVerify"
```

### Swift Package Manager

Add this repository as an iOS 16+ package dependency. The package product is `TTGPuzzleVerify`.

## Swift usage

```swift
import TTGPuzzleVerify

let puzzleView = TTGPuzzleVerifyView(frame: CGRect(x: 20, y: 80, width: 320, height: 220))
puzzleView.image = UIImage(named: "pic")

let style = TTGPuzzleVerifyStyle()
style.blankAlpha = 0.45
style.cornerRadius = 16
style.puzzleShadow.opacity = 0.4

let configuration = TTGPuzzleVerifyConfiguration()
configuration.puzzlePattern = .classicPattern
configuration.puzzleSize = CGSize(width: 86, height: 86)
configuration.verificationTolerance = 6
configuration.allowedAxes = .horizontal
configuration.autoSnapWhenWithinTolerance = true
configuration.maxRetryCount = 3
configuration.style = style

puzzleView.applyConfiguration(configuration)
puzzleView.puzzleBlankPosition = CGPoint(x: 220, y: 96)
puzzleView.puzzlePosition = CGPoint(x: 24, y: 96)

puzzleView.completionBlock = { view, result in
    print("verified", result.elapsedTime, result.dragDistance)
}

puzzleView.failureBlock = { view, result in
    print("failed offset", result.xOffset, result.yOffset)
}
```

## Objective-C usage

Since the core is Swift, Objective-C clients should import the generated Swift header when using CocoaPods frameworks:

```objc
#import <TTGPuzzleVerify/TTGPuzzleVerify-Swift.h>

TTGPuzzleVerifyView *puzzleView = [[TTGPuzzleVerifyView alloc] initWithFrame:CGRectMake(20, 80, 320, 220)];
puzzleView.image = [UIImage imageNamed:@"pic"];
puzzleView.puzzlePattern = TTGPuzzleVerifyPatternClassicPattern;
puzzleView.allowedAxes = TTGPuzzleVerifyAllowedAxesHorizontal;
puzzleView.puzzleBlankPosition = CGPointMake(220, 96);
puzzleView.puzzlePosition = CGPointMake(24, 96);
puzzleView.verificationTolerance = 6;
puzzleView.delegate = self;

[puzzleView setCompletionBlock:^(TTGPuzzleVerifyView *view, TTGPuzzleVerifyResult *result) {
    NSLog(@"verified in %.2fs", result.elapsedTime);
}];
```

## Key APIs

### Pattern

```swift
public enum TTGPuzzleVerifyPattern: Int {
    case classicPattern
    case squarePattern
    case circlePattern
    case customPattern
}
```

### Drag axes

```swift
public enum TTGPuzzleVerifyAllowedAxes: Int {
    case horizontal
    case vertical
    case both
}
```

### State

```swift
public enum TTGPuzzleVerifyState: Int {
    case idle
    case dragging
    case verified
    case failed
    case locked
}
```

### Result

`TTGPuzzleVerifyResult` includes:

* `isVerified`
* `puzzlePosition`
* `blankPosition`
* `xOffset` / `yOffset`
* `elapsedTime`
* `dragDistance`
* `interactionCount`

### Configuration

Use `TTGPuzzleVerifyConfiguration` to apply behavior consistently:

* `puzzlePattern`
* `puzzleSize`
* `verificationTolerance`
* `allowedAxes`
* `autoSnapWhenWithinTolerance`
* `recordsTrack`
* `maxRetryCount`
* `style`

### Callbacks

The component supports delegate and closure callbacks:

* position changed
* verification changed
* state changed
* completed with result
* failed with result

## Testing

Objective-C tests cover default configuration, clamping, percentage mapping, verification tolerance, callbacks, configuration/style application, failure locking, result creation, and track collection.

Run the tests from macOS with Xcode:

```sh
cd Example
pod install
xcodebuild -workspace TTGPuzzleVerify.xcworkspace -scheme TTGPuzzleVerify-Example -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Author

zekunyan, zekunyan@163.com

## License

TTGPuzzleVerify is available under the MIT license. See the LICENSE file for more info.
