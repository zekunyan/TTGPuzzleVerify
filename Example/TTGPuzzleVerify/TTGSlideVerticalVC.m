//
//  TTGSlideVerticalVC.m
//  TTGPuzzleVerify
//
//  Created by tutuge on 2016/12/11.
//  Copyright © 2016年 zekunyan. All rights reserved.
//

#import "TTGSlideVerticalVC.h"
#import <TTGPuzzleVerify/TTGPuzzleVerifyView.h>

@interface TTGSlideVerticalVC () <TTGPuzzleVerifyViewDelegate>
@property (weak, nonatomic) IBOutlet TTGPuzzleVerifyView *puzzleVerifyView;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@end

@implementation TTGSlideVerticalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _puzzleVerifyView.image = [UIImage imageNamed:@"pic3"];
    _puzzleVerifyView.puzzleBlankPosition = CGPointMake(100, 100);
    _puzzleVerifyView.puzzlePosition = CGPointMake(100, 10);
    _puzzleVerifyView.puzzleYPercentage = 0.1;
    _puzzleVerifyView.delegate = self;
}

#pragma mark - TTGPuzzleVerifyViewDelegate

- (void)puzzleVerifyView:(TTGPuzzleVerifyView *)puzzleVerifyView didChangedVerification:(BOOL)isVerified {
    if ([_puzzleVerifyView isVerified]) {
        [_puzzleVerifyView completeVerificationWithAnimation:YES];
        _puzzleVerifyView.enable = NO;
        _logLabel.text = @"Verify done !";
    }
}

#pragma mark - Actions

- (IBAction)onSliderChange:(UISlider *)sender {
    _puzzleVerifyView.puzzleYPercentage = sender.value;
}

@end

