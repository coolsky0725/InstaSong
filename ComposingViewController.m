//
//  ComposingViewController.m
//  InstaSong
//
//  Created by zongda liang on 2/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "ComposingViewController.h"
#import "PostGroupViewController.h"
#import "BJIConverter.h"
#import "PCMMixer.h"

@implementation ComposingViewController
@synthesize parentController;
@synthesize object;
@synthesize waveformView;
@synthesize audioPlot;
@synthesize recordingTimeLabel;
@synthesize progressSlider;
@synthesize recorder;
@synthesize microphone;
@synthesize recordingAudioPlayer;
@synthesize instrumentAudioPlayer;
@synthesize playPauseButton;
@synthesize HUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PFFile *audioFile = [object objectForKey:@"audio"];
        NSData *audioData = [audioFile getData];
        NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[object objectForKey:@"filename"]];
        [audioData writeToFile:filePath atomically:YES];
        
        if ([[object objectForKey:@"filename"] rangeOfString:@".caf"].location == NSNotFound) {
            NSString *convFilePath = [filePath substringToIndex:[filePath rangeOfString:@"."].location];
            [BJIConverter convertFile:filePath toFile:[NSString stringWithFormat:@"%@.caf", convFilePath]];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:filePath error:nil];
            filePath = [NSString stringWithFormat:@"%@.caf", convFilePath];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            instrumentUrl = [NSURL fileURLWithPath:filePath];
            [waveformView openAudioURL:instrumentUrl];
            NSError *soundError = nil;
            instrumentAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:instrumentUrl error:&soundError];
            [instrumentAudioPlayer setVolume:0.7];
            if(instrumentAudioPlayer == nil)
            {
                NSLog(@"%@",soundError);
            } else {
                [instrumentAudioPlayer setDelegate:self];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
        });
    });
    
    microphone = [EZMicrophone microphoneWithDelegate:self];
    audioPlot.backgroundColor = [UIColor clearColor];
    audioPlot.color           = [UIColor colorWithRed:0.12f green:0.23f blue:0.61f alpha:1.0];
    audioPlot.plotType        = EZPlotTypeRolling;
    audioPlot.shouldFill      = YES;
    audioPlot.shouldMirror    = YES;
    [audioPlot setContentScaleFactor:2.0f];
    
    NSURL *soundFileURL = [self testFilePathURL];
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:32], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],AVSampleRateKey, nil];
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    recorder.meteringEnabled = YES;
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [recorder prepareToRecord];
    }
    
    progressSlider.color = [UIColor colorWithRed:0.12f green:0.23f blue:0.61f alpha:1.0];
    progressSlider.flat = @YES;
    progressSlider.animate = @NO;
    progressSlider.showText = @NO;
    progressSlider.showStroke = @NO;
    progressSlider.progressInset = @2;
    progressSlider.showBackground = @NO;
    progressSlider.outerStrokeWidth = @1;
    progressSlider.type = LDProgressSolid;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[instrumentUrl path] error:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark recording start.
- (IBAction)onClickRecordingStartButton:(id)sender
{
    if ([self isHeadsetPluggedIn]) {
        if (recordingAudioPlayer) {
            [recordingAudioPlayer stop];
            recordingAudioPlayer = nil;
        }
        
        if (instrumentAudioPlayer) {
            [instrumentAudioPlayer stop];
        }
        
        recordingSeconds = 0;
        [recordingTimeLabel setText:[NSString stringWithFormat:@"%i s", recordingSeconds]];
        [progressSlider setProgress:0.0f];
        [audioPlot clear];
        
        [waveformView pauseAudio];
        [self.microphone startFetchingAudio];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [recorder record];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRecordingSeconds) userInfo:nil repeats:YES];
        
    } else {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Warning!" message:@"Please use headset for high quality!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)updateRecordingSeconds
{
    recordingSeconds ++;
    if (recordingSeconds < 60) {
        [recordingTimeLabel setText:[NSString stringWithFormat:@"%i s", recordingSeconds]];
    } else {
        [recordingTimeLabel setText:[NSString stringWithFormat:@"%i : %i", recordingSeconds/60, recordingSeconds%60]];
    }
    [progressSlider setProgress:recordingSeconds/300.0f];
}
#pragma mark recording end
- (IBAction)onClickRecordingEndButton:(id)sender
{
    [recorder stop];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    
    [self.microphone stopFetchingAudio];
    [waveformView pauseAudio];
    [instrumentAudioPlayer stop];
    [timer invalidate];
    timer = nil;
    
    NSError *err;
    recordingAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self testFilePathURL] error:&err];
    if (err == nil) {
        recordingAudioPlayer.delegate = self;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

#pragma mark onClickPlayPauseButton
- (IBAction)onClickPlayPauseButton:(id)sender
{
    if (instrumentAudioPlayer) {
        if (instrumentAudioPlayer.playing) {
            [instrumentAudioPlayer stop];
            if (recordingAudioPlayer) {
                [recordingAudioPlayer  stop];
            }
            [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        } else {
            [instrumentAudioPlayer play];
            if (recordingAudioPlayer) {
                [recordingAudioPlayer play];
            }
            [playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark onClickPostButton
- (IBAction)onClickPostButton:(id)sender
{
    if (recordingAudioPlayer) {
        [self MergeAndPost];
    } else {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please record the vocal!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark onClickSaveButton
- (void) MergeAndPost
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setLabelText:@"Mixing"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PCMMixer mix:[instrumentUrl path] file2:[[self testFilePathURL] path] offset:0 mixfile:[[self mixedFilePathURL] path]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
        });
    });
}

#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (recordingAudioPlayer && !recordingAudioPlayer.playing  && !instrumentAudioPlayer.playing ) {
        [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - EZMicrophoneDelegate
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
-(void)microphone:(EZMicrophone *)microphone hasAudioReceived:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    dispatch_async(dispatch_get_main_queue(),^{
        [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

-(void)microphone:(EZMicrophone *)microphone hasBufferList:(AudioBufferList *)bufferList withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
}

#pragma mark - Utility
-(NSArray*)applicationDocuments {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

-(NSString*)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSURL*)testFilePathURL {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], @"record1.caf"]];
}

-(NSURL*)mixedFilePathURL {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [self applicationDocumentsDirectory], @"mixed.m4a"]];
}

#pragma mark check headset.
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
