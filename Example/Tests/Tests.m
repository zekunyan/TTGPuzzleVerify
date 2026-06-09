//
//  TTGPuzzleVerifyTests.m
//  TTGPuzzleVerifyTests
//
//  Created by zekunyan on 12/05/2016.
//  Copyright (c) 2016 zekunyan. All rights reserved.
//

@import XCTest;
#import <TTGPuzzleVerify/TTGPuzzleVerify-Swift.h>

@interface Tests : XCTestCase <TTGPuzzleVerifyViewDelegate>
@property (nonatomic, assign) BOOL delegateVerificationValue;
@property (nonatomic, assign) CGPoint delegatePosition;
@property (nonatomic, assign) CGFloat delegateXPercentage;
@property (nonatomic, assign) CGFloat delegateYPercentage;
@end

@implementation Tests

- (TTGPuzzleVerifyView *)makePuzzleView {
    TTGPuzzleVerifyView *view = [[TTGPuzzleVerifyView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    view.puzzleSize = CGSizeMake(80, 60);
    view.puzzleBlankPosition = CGPointMake(160, 90);
    view.puzzlePosition = CGPointMake(20, 30);
    view.verificationTolerance = 4;
    return view;
}

- (void)testDefaultConfigurationIsStable {
    TTGPuzzleVerifyView *view = [[TTGPuzzleVerifyView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];

    XCTAssertTrue(view.enable);
    XCTAssertEqual(view.puzzlePattern, TTGPuzzleVerifyPatternClassicPattern);
    XCTAssertEqualWithAccuracy(view.puzzleSize.width, 100, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzleSize.height, 100, 0.001);
    XCTAssertEqualWithAccuracy(view.verificationTolerance, 8, 0.001);
    XCTAssertFalse(view.isVerified);
}

- (void)testPuzzlePositionIsClampedToViewBounds {
    TTGPuzzleVerifyView *view = [self makePuzzleView];

    view.puzzlePosition = CGPointMake(-100, 500);

    XCTAssertEqualWithAccuracy(view.puzzlePosition.x, 0, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzlePosition.y, 180, 0.001);
}

- (void)testPercentageSettersClampValuesAndUpdatePosition {
    TTGPuzzleVerifyView *view = [self makePuzzleView];

    view.puzzleXPercentage = 2;
    view.puzzleYPercentage = -1;

    XCTAssertEqualWithAccuracy(view.puzzleXPercentage, 1, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzleYPercentage, 0, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzlePosition.x, 240, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzlePosition.y, 0, 0.001);
}

- (void)testVerificationToleranceUsesBothAxes {
    TTGPuzzleVerifyView *view = [self makePuzzleView];

    view.puzzlePosition = CGPointMake(163, 93);
    XCTAssertTrue(view.isVerified);

    view.puzzlePosition = CGPointMake(165, 93);
    XCTAssertFalse(view.isVerified);
}

- (void)testCompleteVerificationUpdatesStateAndCallbacks {
    TTGPuzzleVerifyView *view = [self makePuzzleView];
    __block BOOL blockCalled = NO;
    __block BOOL blockVerified = NO;
    view.delegate = self;
    view.verificationChangeBlock = ^(TTGPuzzleVerifyView *puzzleVerifyView, BOOL isVerified) {
        blockCalled = YES;
        blockVerified = isVerified;
    };

    [view completeVerificationWithAnimation:NO];

    XCTAssertTrue(view.isVerified);
    XCTAssertTrue(blockCalled);
    XCTAssertTrue(blockVerified);
    XCTAssertTrue(self.delegateVerificationValue);
    XCTAssertEqualWithAccuracy(self.delegatePosition.x, view.puzzleBlankPosition.x, 0.001);
    XCTAssertEqualWithAccuracy(self.delegatePosition.y, view.puzzleBlankPosition.y, 0.001);
}

- (void)testDisabledViewDoesNotMovePuzzle {
    TTGPuzzleVerifyView *view = [self makePuzzleView];
    CGPoint initialPosition = view.puzzlePosition;

    view.enable = NO;
    view.puzzlePosition = CGPointMake(200, 100);
    view.puzzleXPercentage = 1;
    view.puzzleYPercentage = 1;

    XCTAssertEqualWithAccuracy(view.puzzlePosition.x, initialPosition.x, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzlePosition.y, initialPosition.y, 0.001);
}

- (void)testStyleInputsAreSanitized {
    TTGPuzzleVerifyView *view = [self makePuzzleView];

    view.puzzleBlankAlpha = 2;
    view.puzzleShadowOpacity = -1;
    view.puzzleBlankInnerShadowOpacity = 3;
    view.puzzleSize = CGSizeMake(0, -10);

    XCTAssertEqualWithAccuracy(view.puzzleBlankAlpha, 1, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzleShadowOpacity, 0, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzleBlankInnerShadowOpacity, 1, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzleSize.width, 1, 0.001);
    XCTAssertEqualWithAccuracy(view.puzzleSize.height, 1, 0.001);
}

#pragma mark - TTGPuzzleVerifyViewDelegate

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedVerification:(BOOL)isVerified {
    self.delegateVerificationValue = isVerified;
}

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedPuzzlePosition:(CGPoint)newPosition xPercentage:(CGFloat)xPercentage yPercentage:(CGFloat)yPercentage {
    self.delegatePosition = newPosition;
    self.delegateXPercentage = xPercentage;
    self.delegateYPercentage = yPercentage;
}

@end
