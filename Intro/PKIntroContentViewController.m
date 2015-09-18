//
//  PKIntroContentViewController.m
//  Peek
//
//  Created by Robert Bastian on 2014-03-16.
//  Copyright (c) 2014 Peek Inc. All rights reserved.
//

#import "PKIntroContentViewController.h"

@interface PKIntroContentViewController ()

@end

@implementation PKIntroContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
