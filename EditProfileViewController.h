//
//  EditProfileViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/21/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "MBProgressHUD.h"

@interface EditProfileViewController : UIViewController<UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIAlertViewDelegate>
{
    UIImage* profileImage;
}
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *currentPasswordField;
@property (nonatomic, retain) IBOutlet UITextField *confirmPasswordField;
@property (nonatomic, retain) IBOutlet UIImageView *avatorImageView;
@property (nonatomic, retain) MBProgressHUD *HUD;
@end
