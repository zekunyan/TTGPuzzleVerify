# TTGPuzzleVerify Objective-C Example

This is the standalone Objective-C UIKit example project. It demonstrates Objective-C integration against the Swift core through CocoaPods and the generated Swift header.

## Run

```sh
cd Examples/ObjCExample
pod install
open TTGPuzzleVerify.xcworkspace
```

## Test

```sh
cd Examples/ObjCExample
pod install
xcodebuild -workspace TTGPuzzleVerify.xcworkspace -scheme TTGPuzzleVerify-Example -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Contents

- `TTGPuzzleVerify/`: Objective-C UIKit demo screens.
- `Tests/`: Objective-C XCTest coverage for Objective-C compatibility and the Swift core API.
- `Podfile`: local path dependency on the repository root.
