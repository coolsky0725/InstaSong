//
//  PreviewViewController.h
//  InstaSong
//
//  Created by zongda liang on 2/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import <AVFoundation/AVFoundation.h>


@interface PreviewViewController : UIViewController< AVAudioPlayerDelegate >
{
    
}
@property (nonatomic, retain) IBOutlet UITextField *titleField;
@property (nonatomic, retain) IBOutlet UILabel *sounNameLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UITextField *tagsField;
@property (nonatomic, retain) IBOutlet UIButton    *playPauseButton;
@property (nonatomic, retain) AVAudioPlayer       *audioPlayer;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) PFObject *object;
@end
