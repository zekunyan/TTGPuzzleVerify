//
//  TTGDragToVerifyVC.m
//  TTGPuzzleVerify
//
//  Created by tutuge on 2016/12/11.
//  Copyright © 2016年 zekunyan. All rights reserved.
//

#import "TTGDragToVerifyVC.h"
#import <TTGPuzzleVerify/TTGPuzzleVerifyView.h>

@interface TTGDragToVerifyVC () <TTGPuzzleVerifyViewDelegate>
@property (weak, nonatomic) IBOutlet TTGPuzzleVerifyView *puzzleVerifyView;
@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@end

@implementation TTGDragToVerifyVC

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

@end
