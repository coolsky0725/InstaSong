//
//  SignInViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SignInViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
    BOOL    bkFlag;
    NSTimer *timer;
}
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) MBProgressHUD *HUD;
@end
