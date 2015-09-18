//
//  SignViewController.m
//  InstaSong
//
//  Created by zongda liang on 1/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "SignViewController.h"

@implementation SignViewController
@synthesize backgroundView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeBackground) userInfo:nil repeats:YES];
}

- (void)changeBackground
{
    bkFlag = !bkFlag;
    if (bkFlag) {
        [backgroundView setImage:[UIImage imageNamed:@"background1.png"]];
    } else {
        [backgroundView setImage:[UIImage imageNamed:@"background2.png"]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
