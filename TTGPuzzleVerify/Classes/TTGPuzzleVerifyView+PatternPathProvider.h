//
//  TTGPuzzleVerifyView+PatternPathProvider.h
//  Pods
//
//  Created by tutuge on 2016/12/10.
//
//

#import "TTGPuzzleVerifyView.h"

@interface TTGPuzzleVerifyView (PatternPathProvider)

/**
 * Path for different puzzle pattern
 * @param pattern
 * @return
 */
+ (UIBezierPath *)verifyPathForPattern:(TTGPuzzleVerifyPattern)pattern;

@end
