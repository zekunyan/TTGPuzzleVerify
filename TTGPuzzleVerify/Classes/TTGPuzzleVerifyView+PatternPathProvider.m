//
//  TTGPuzzleVerifyView+PatternPathProvider.m
//  Pods
//
//  Created by tutuge on 2016/12/10.
//
//

#import "TTGPuzzleVerifyView+PatternPathProvider.h"

@implementation TTGPuzzleVerifyView (PatternPathProvider)

+ (UIBezierPath *)verifyPathForPattern:(TTGPuzzleVerifyPattern)pattern {
    switch (pattern) {
        case TTGPuzzleVerifyClassicPattern:
            return [self classicPuzzlePath];
        case TTGPuzzleVerifySquarePattern:
            return [self squarePath];
        case TTGPuzzleVerifyCirclePattern:
            return [self circlePath];
        case TTGPuzzleVerifyCustomPattern:
            return [self classicPuzzlePath];
    }
}

#pragma mark - Private 

+ (UIBezierPath *)squarePath {
    static UIBezierPath *path = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 100, 100)];
    });

    return path;
}

+ (UIBezierPath *)circlePath {
    static UIBezierPath *path = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 100, 100)];
    });

    return path;
}

+ (UIBezierPath *)classicPuzzlePath {
    static UIBezierPath *puzzleShape = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        puzzleShape = [UIBezierPath bezierPath];
        [puzzleShape moveToPoint:CGPointMake(17.45, 71.16)];
        [puzzleShape addCurveToPoint:CGPointMake(25, 74.69) controlPoint1:CGPointMake(20.83, 67.76) controlPoint2:CGPointMake(25, 69.2)];
        [puzzleShape addLineToPoint:CGPointMake(25, 100)];
        [puzzleShape addLineToPoint:CGPointMake(50.31, 100)];
        [puzzleShape addCurveToPoint:CGPointMake(53.84, 92.45) controlPoint1:CGPointMake(55.79, 100) controlPoint2:CGPointMake(57.24, 95.83)];
        [puzzleShape addCurveToPoint:CGPointMake(50, 85.33) controlPoint1:CGPointMake(52.18, 90.78) controlPoint2:CGPointMake(50, 89.4)];
        [puzzleShape addCurveToPoint:CGPointMake(62.5, 75) controlPoint1:CGPointMake(50, 80.8) controlPoint2:CGPointMake(54.62, 75)];
        [puzzleShape addCurveToPoint:CGPointMake(75, 85.33) controlPoint1:CGPointMake(70.38, 75) controlPoint2:CGPointMake(75, 80.8)];
        [puzzleShape addCurveToPoint:CGPointMake(71.16, 92.45) controlPoint1:CGPointMake(75, 89.4) controlPoint2:CGPointMake(72.82, 90.78)];
        [puzzleShape addCurveToPoint:CGPointMake(74.69, 100) controlPoint1:CGPointMake(67.76, 95.83) controlPoint2:CGPointMake(69.2, 100)];
        [puzzleShape addLineToPoint:CGPointMake(100, 100)];
        [puzzleShape addLineToPoint:CGPointMake(100, 74.69)];
        [puzzleShape addCurveToPoint:CGPointMake(92.45, 71.16) controlPoint1:CGPointMake(100, 69.21) controlPoint2:CGPointMake(95.83, 67.76)];
        [puzzleShape addCurveToPoint:CGPointMake(85.33, 75) controlPoint1:CGPointMake(90.78, 72.82) controlPoint2:CGPointMake(89.4, 75)];
        [puzzleShape addCurveToPoint:CGPointMake(75, 62.5) controlPoint1:CGPointMake(80.8, 75) controlPoint2:CGPointMake(75, 70.38)];
        [puzzleShape addCurveToPoint:CGPointMake(85.33, 50) controlPoint1:CGPointMake(75, 54.62) controlPoint2:CGPointMake(80.8, 50)];
        [puzzleShape addCurveToPoint:CGPointMake(92.45, 53.84) controlPoint1:CGPointMake(89.4, 50) controlPoint2:CGPointMake(90.78, 52.18)];
        [puzzleShape addCurveToPoint:CGPointMake(100, 50.31) controlPoint1:CGPointMake(95.83, 57.24) controlPoint2:CGPointMake(100, 55.8)];
        [puzzleShape addLineToPoint:CGPointMake(100, 25)];
        [puzzleShape addLineToPoint:CGPointMake(74.69, 25)];
        [puzzleShape addCurveToPoint:CGPointMake(71.16, 17.45) controlPoint1:CGPointMake(69.21, 25) controlPoint2:CGPointMake(67.76, 20.83)];
        [puzzleShape addCurveToPoint:CGPointMake(75, 10.33) controlPoint1:CGPointMake(72.82, 15.78) controlPoint2:CGPointMake(75, 14.4)];
        [puzzleShape addCurveToPoint:CGPointMake(62.5, 0) controlPoint1:CGPointMake(75, 5.8) controlPoint2:CGPointMake(70.38, 0)];
        [puzzleShape addCurveToPoint:CGPointMake(50, 10.33) controlPoint1:CGPointMake(54.62, 0) controlPoint2:CGPointMake(50, 5.8)];
        [puzzleShape addCurveToPoint:CGPointMake(53.84, 17.45) controlPoint1:CGPointMake(50, 14.4) controlPoint2:CGPointMake(52.18, 15.78)];
        [puzzleShape addCurveToPoint:CGPointMake(50.31, 25) controlPoint1:CGPointMake(57.24, 20.83) controlPoint2:CGPointMake(55.8, 25)];
        [puzzleShape addLineToPoint:CGPointMake(25, 25)];
        [puzzleShape addLineToPoint:CGPointMake(25, 50.31)];
        [puzzleShape addCurveToPoint:CGPointMake(17.45, 53.84) controlPoint1:CGPointMake(25, 55.79) controlPoint2:CGPointMake(20.83, 57.24)];
        [puzzleShape addCurveToPoint:CGPointMake(10.33, 50) controlPoint1:CGPointMake(15.78, 52.18) controlPoint2:CGPointMake(14.4, 50)];
        [puzzleShape addCurveToPoint:CGPointMake(0, 62.5) controlPoint1:CGPointMake(5.8, 50) controlPoint2:CGPointMake(0, 54.62)];
        [puzzleShape addCurveToPoint:CGPointMake(10.33, 75) controlPoint1:CGPointMake(0, 70.38) controlPoint2:CGPointMake(5.8, 75)];
        [puzzleShape addCurveToPoint:CGPointMake(17.45, 71.16) controlPoint1:CGPointMake(14.4, 75) controlPoint2:CGPointMake(15.78, 72.82)];
        [puzzleShape moveToPoint:CGPointMake(17.45, 71.16)];
        [puzzleShape closePath];
    });

    return puzzleShape;
}

@end
