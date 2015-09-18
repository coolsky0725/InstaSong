//
//  PKIntroContentViewController.h
//  Peek
//
//  Created by Robert Bastian on 2014-03-16.
//  Copyright (c) 2014 Peek Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKIntroContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@end
