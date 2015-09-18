//
//  PostGroupViewController.h
//  InstaSong
//
//  Created by zongda liang on 2/5/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

@interface PostGroupViewController : UIViewController  <UITextFieldDelegate, UIActionSheetDelegate, UITextViewDelegate, AVAudioPlayerDelegate, UIAlertViewDelegate>
{
    
}
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UILabel *sounNameLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UITextField *tagsField;
@property (nonatomic, retain) IBOutlet UIButton    *playPauseButton;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) PFObject *object;
@property (nonatomic, retain) AVAudioPlayer       *audioPlayer;
@property (nonatomic, retain) id                  parentController;
@end
