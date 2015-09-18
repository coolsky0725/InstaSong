//
//  SignUpViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage *profileImage;
}
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *confirmPasswordField;
@property (nonatomic, retain) IBOutlet UIImageView *profileView;
@property (nonatomic, retain) MBProgressHUD *HUD;
@end
