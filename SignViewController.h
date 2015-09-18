//
//  SignViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignViewController : UIViewController
{
    BOOL    bkFlag;
    NSTimer *timer;
}
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@end
