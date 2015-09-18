//
//  PKIntroRootViewController.h
//  Peek
//
//  Created by Robert Bastian on 2014-03-16.
//  Copyright (c) 2014 Peek Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKIntroRootViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property(strong, nonatomic) IBOutlet UIView *skipBtnView;
@property(strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end
