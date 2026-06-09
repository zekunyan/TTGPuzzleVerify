# TTGPuzzleVerify Swift Example

This is a Swift 5.9 / iOS 16 example app for `TTGPuzzleVerify`.

It demonstrates:

- using `TTGPuzzleVerifyView` directly from Swift UIKit code;
- wrapping `TTGPuzzleVerifyView` in SwiftUI with `UIViewRepresentable`;
- delegate callbacks and `verificationChangeBlock` state binding;
- programmatic slider-driven puzzle movement and manual completion/reset.

## Run

```sh
cd Example/SwiftExample
pod install
open TTGPuzzleVerifySwiftExample.xcworkspace
```

Select the `TTGPuzzleVerifySwiftExample` scheme and run on an iOS 16+ simulator or device.
