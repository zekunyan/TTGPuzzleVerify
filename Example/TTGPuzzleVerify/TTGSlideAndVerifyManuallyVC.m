//
//  TTGSlideAndVerifyManuallyVC.m
//  TTGPuzzleVerify
//
//  Created by tutuge on 2016/12/11.
//  Copyright © 2016年 zekunyan. All rights reserved.
//

#import "TTGSlideAndVerifyManuallyVC.h"
#import <TTGPuzzleVerify/TTGPuzzleVerifyView.h>

@interface TTGSlideAndVerifyManuallyVC ()
@property (weak, nonatomic) IBOutlet TTGPuzzleVerifyView *puzzleVerifyView;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@end

@implementation TTGSlideAndVerifyManuallyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _puzzleVerifyView.image = [UIImage imageNamed:@"pic3"];
    _puzzleVerifyView.puzzleBlankPosition = CGPointMake(200, 40);
    _puzzleVerifyView.puzzlePosition = CGPointMake(10, 40);
    _puzzleVerifyView.puzzleXPercentage = 0.1;
}

#pragma mark - Actions

- (IBAction)onSliderChange:(UISlider *)sender {
    _puzzleVerifyView.puzzleXPercentage = sender.value;
}

- (IBAction)onTapVerify:(id)sender {
    if ([_puzzleVerifyView isVerified]) {
        [_puzzleVerifyView completeVerificationWithAnimation:YES];
        _puzzleVerifyView.enable = NO;
        _logLabel.text = @"Verify done !";
    } else {
        _logLabel.text = @"Verify wrong !";
    }
}

@end
