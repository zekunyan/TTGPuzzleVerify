//
//  TTGPuzzleVerifyView+PatternPathProvider.h
//  Pods
//
//  Created by tutuge on 2016/12/10.
//
//

#import "TTGPuzzleVerifyView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTGPuzzleVerifyView (PatternPathProvider)

/**
 * Path for different puzzle pattern
 * @param pattern Puzzle shape to resolve.
 * @return Shared 100x100 source path for the requested pattern.
 */
+ (UIBezierPath *)verifyPathForPattern:(TTGPuzzleVerifyPattern)pattern;

@end

NS_ASSUME_NONNULL_END
