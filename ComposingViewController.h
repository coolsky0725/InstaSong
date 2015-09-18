//
//  ComposingViewController.h
//  InstaSong
//
//  Created by zongda liang on 2/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EZAudio.h"
#import "LDProgressView.h"
#import "MBProgressHUD.h"
#import "WaveFormViewIOS.h"

@interface ComposingViewController : UIViewController<AVAudioPlayerDelegate, EZMicrophoneDelegate>
{
    NSTimer     *timer;
    int         recordingSeconds;
    
    NSURL       *instrumentUrl;
    NSURL       *recordingUrl;
}
@property (nonatomic, retain)           IBOutlet EZAudioPlotGL      *audioPlot;
@property (nonatomic, retain)           IBOutlet UILabel            *recordingTimeLabel;
@property (nonatomic, retain)           IBOutlet LDProgressView     *progressSlider;
@property (nonatomic, retain)           IBOutlet UIButton           *playPauseButton;
@property (nonatomic, retain)           IBOutlet WaveFormViewIOS    *waveformView;
@property (nonatomic, retain)           EZMicrophone                *microphone;
@property (nonatomic, retain)           AVAudioRecorder             *recorder;
@property (nonatomic, retain)           AVAudioPlayer               *instrumentAudioPlayer;
@property (nonatomic, retain)           AVAudioPlayer               *recordingAudioPlayer;
@property (nonatomic, retain)           MBProgressHUD               *HUD;
@property (nonatomic, retain)           id                          parentController;
@property (nonatomic, retain)           PFObject                    *object;


@end
