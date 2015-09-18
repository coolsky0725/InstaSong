//
//  PostViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/8/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

@interface PostViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UITextViewDelegate, MPMediaPickerControllerDelegate>
{
    MPMediaItem *mediaItem;
    NSURL       *soundFileUrl;
    BOOL        recordingFlag;
}
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UILabel *sounNameLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UITextField *tagsField;
@property (nonatomic, retain) MBProgressHUD *HUD;
@end
