//
//  TTGSlideHorizontallyVC.m
//  TTGPuzzleVerify
//
//  Created by tutuge on 2016/12/11.
//  Copyright © 2016年 zekunyan. All rights reserved.
//

#import "TTGSlideHorizontallyVC.h"
#import <TTGPuzzleVerify/TTGPuzzleVerifyView.h>

@interface TTGSlideHorizontallyVC () <TTGPuzzleVerifyViewDelegate>
@property (weak, nonatomic) IBOutlet TTGPuzzleVerifyView *puzzleVerifyView;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@end

@implementation TTGSlideHorizontallyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _puzzleVerifyView.image = [UIImage imageNamed:@"pic3"];
    _puzzleVerifyView.puzzleBlankPosition = CGPointMake(200, 40);
    _puzzleVerifyView.puzzlePosition = CGPointMake(10, 40);
    _puzzleVerifyView.puzzleXPercentage = 0.1;
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
    _puzzleVerifyView.puzzleXPercentage = sender.value;
}

@end
