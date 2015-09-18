//
//  RecordingViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/21/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"
#import "LDProgressView.h"
#import "MBProgressHUD.h"

@interface RecordingViewController : UIViewController< AVAudioPlayerDelegate, EZMicrophoneDelegate >
{
    BOOL     recordingFlag;
    NSTimer *timer;
    int      recordingSeconds;
}
@property (nonatomic, retain)           IBOutlet EZAudioPlotGL      *audioPlot;
@property (nonatomic, retain)           IBOutlet UILabel            *recordingTimeLabel;
@property (nonatomic, retain)           IBOutlet LDProgressView     *progressSlider;
@property (nonatomic, retain)           IBOutlet UIButton           *playPauseButton;
@property (nonatomic, retain)           EZMicrophone                *microphone;
@property (nonatomic, retain)           AVAudioRecorder             *recorder;
@property (nonatomic, retain)           AVAudioPlayer               *audioPlayer;
@property (nonatomic, retain)           MBProgressHUD               *HUD;
@end
