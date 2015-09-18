//
//  PreviewViewController.m
//  InstaSong
//
//  Created by zongda liang on 2/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "PreviewViewController.h"

@implementation PreviewViewController
@synthesize titleField;
@synthesize sounNameLabel;
@synthesize descriptionView;
@synthesize HUD;
@synthesize tagsField;
@synthesize object;
@synthesize audioPlayer;
@synthesize playPauseButton;

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
    [titleField setText:[object objectForKey:@"title"]];
    [descriptionView setText:[object objectForKey:@"description"]];
    [tagsField setText:[object objectForKey:@"tags"]];
    [sounNameLabel setText:@"record.m4a"];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [HUD hide:YES];
        PFFile *audioFile = [object objectForKey:@"audio"];
        NSString *filename = [object objectForKey:@"filename"];
        if ([filename rangeOfString:@".mp3"].location != NSNotFound) {
            audioPlayer  = [[AVAudioPlayer alloc] initWithData:[audioFile getData] fileTypeHint:AVFileTypeMPEGLayer3 error:nil];
        } else if([filename rangeOfString:@".wav"].location != NSNotFound){
            audioPlayer  = [[AVAudioPlayer alloc] initWithData:[audioFile getData] fileTypeHint:AVFileTypeWAVE error:nil];
        } else if([filename rangeOfString:@".m4a"].location != NSNotFound) {
            audioPlayer  = [[AVAudioPlayer alloc] initWithData:[audioFile getData] fileTypeHint:AVFileTypeAppleM4A error:nil];
        } else {
            audioPlayer  = [[AVAudioPlayer alloc] initWithData:[audioFile getData] fileTypeHint:AVFileTypeAIFF error:nil];
        }
        [audioPlayer setDelegate:self];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark onClickBackButton
- (IBAction)onClickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark onClickPlayPauseButton
- (IBAction)onClickPlayPauseButton:(id)sender
{
    if (audioPlayer.playing) {
        [audioPlayer stop];
        [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    } else {
        [audioPlayer play];
        [playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
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
