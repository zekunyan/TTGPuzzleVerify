//
//  TTGCustomShadowVC.m
//  TTGPuzzleVerify
//
//  Created by tutuge on 2016/12/11.
//  Copyright © 2016年 zekunyan. All rights reserved.
//

#import "TTGCustomShadowVC.h"
#import <TTGPuzzleVerify/TTGPuzzleVerifyView.h>

@interface TTGCustomShadowVC () <TTGPuzzleVerifyViewDelegate>
@property (weak, nonatomic) IBOutlet TTGPuzzleVerifyView *puzzleVerifyView;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@end

@implementation TTGCustomShadowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _puzzleVerifyView.image = [UIImage imageNamed:@"pic3"];
    _puzzleVerifyView.puzzleBlankPosition = CGPointMake(200, 40);
    _puzzleVerifyView.puzzlePosition = CGPointMake(10, 40);
    _puzzleVerifyView.puzzleXPercentage = 0.1;
    _puzzleVerifyView.delegate = self;
    
    _puzzleVerifyView.puzzleBlankInnerShadowColor = [UIColor yellowColor];
    _puzzleVerifyView.puzzleBlankInnerShadowRadius = 6;
    _puzzleVerifyView.puzzleBlankInnerShadowOpacity = 0.8;
    _puzzleVerifyView.puzzleBlankInnerShadowOffset = CGSizeMake(2, 2);
    
    _puzzleVerifyView.puzzleShadowColor = [UIColor greenColor];
    _puzzleVerifyView.puzzleShadowRadius = 6;
    _puzzleVerifyView.puzzleShadowOpacity = 0.6;
    _puzzleVerifyView.puzzleShadowOffset = CGSizeMake(2, 2);
}

#pragma mark - TTGPuzzleVerifyViewDelegate

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedVerification:(BOOL)isVerified {
    if ([_puzzleVerifyView isVerified]) {
        [_puzzleVerifyView completeVerificationWithAnimation:YES];
        _puzzleVerifyView.enable = NO;
        _logLabel.text = @"Verify done !";
    }
}

@end
