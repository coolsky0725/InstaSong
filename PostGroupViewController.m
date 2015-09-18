//
//  PostGroupViewController.m
//  InstaSong
//
//  Created by zongda liang on 2/5/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "PostGroupViewController.h"
#import "ComposingViewController.h"
#import "NotificationViewController.h"
#import "DataManager.h"

@implementation PostGroupViewController
@synthesize titleField;
@synthesize sounNameLabel;
@synthesize descriptionView;
@synthesize playPauseButton;
@synthesize tagsField;
@synthesize object;
@synthesize audioPlayer;
@synthesize HUD;
@synthesize parentController;

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
    [sounNameLabel setText:[object objectForKey:@"filename"]];
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
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

#pragma mark onClickRejectButton
- (IBAction)onClickRejectButton:(id)sender
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [object setObject:[NSNumber numberWithInt:2] forKey:@"status"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [HUD hide:YES];
        if (!error) {
            NotificationViewController *viewController = (NotificationViewController*)parentController;
            [viewController replaceNotificationObject:object];
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Success!" message:@"Rejected group post!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        } else {
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please check your internect connection and try again.!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (IBAction)onClickGroupPostingButton:(id)sender
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setLabelText:@"Posting..."];
    PFObject *postObject = [PFObject objectWithClassName:@"Post"];
    [postObject setObject:[object objectForKey:@"sender_id"] forKey:@"userid"];
    [postObject setObject:[object objectForKey:@"sender_name"] forKey:@"publisher_name"];
    [postObject setObject:[object objectForKey:@"sender_image"] forKey:@"publisher_image"];
    [postObject setObject:sounNameLabel.text forKey:@"filename"];
    [postObject setObject:[object objectForKey:@"audio"] forKey:@"audio_file"];
    [postObject setObject:titleField.text forKey:@"title"];
    [postObject setObject:descriptionView.text forKey:@"description"];
    [postObject setObject:[NSMutableArray array] forKey:@"likes"];
    [postObject setObject:[NSMutableArray array] forKey:@"comments"];
    [postObject setObject:tagsField.text forKey:@"tags"];
    [postObject setObject:[NSNumber numberWithInt:2] forKey:@"type"];
    
    [postObject setObject:[[DataManager getInstance].currentUser objectId] forKey:@"group_userid"];
    [postObject setObject:[[DataManager getInstance].currentUser username] forKey:@"group_publisher_name"];
    PFFile *profileImageFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
    UIImage *profileImage = [UIImage imageWithData:[profileImageFile getData]];
    NSData *data = UIImageJPEGRepresentation([self imageWithImage:profileImage scaledToSize:CGSizeMake(50, 50)], 1.0f);
    PFFile *imageFile = [PFFile fileWithName:@"group_publisher_image.jpg" data:data];
    [postObject setObject:imageFile forKey:@"group_publisher_image"];
    
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error) {            
            [object setObject:[NSNumber numberWithInt:3] forKey:@"status"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSString *post_number = [[DataManager getInstance].currentUser objectForKey:@"post_number"];
                    [[DataManager getInstance].currentUser setObject:[NSString stringWithFormat:@"%i", [post_number intValue] + 1] forKey:@"post_number"];
                    [[DataManager getInstance].currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        [HUD hide:YES];
                        if (!error) {
                            NotificationViewController *viewController = (NotificationViewController*)parentController;
                            [viewController replaceNotificationObject:object];
                            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Successful!" message:@"Audio successfully posted!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alert show];
                        }
                    }];
                    
                    NSString * userid = [object objectForKey:@"sender_id"];
                    PFQuery *query = [PFUser query];
                    [query whereKey:@"objectId" equalTo:userid];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            PFUser *user = [objects objectAtIndex:0];
                            NSString *post_number = [user objectForKey:@"post_number"];
                            [user setObject:[NSString stringWithFormat:@"%i", [post_number intValue] + 1] forKey:@"post_number"];
                            [user saveInBackground];
                        }
                    }];
                }
            }];
        } else {
            [HUD hide:YES];
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Post failed!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

#pragma mark uialertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark onClickComposingButton
- (IBAction)onClickComposingButton:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ComposingViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Composing"];
    viewController.object = object;
    viewController.parentController = self;
    [self.navigationController pushViewController:viewController animated:YES];
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

#pragma mark UITextfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

#pragma mark UITextView delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark scale uiimage
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark keyboard notification
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)UIKeyboardWillShowNotification:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSNumber *durationValue = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    [UIView animateWithDuration:durationValue.doubleValue delay:0.0 options:(animationCurve << 16) animations:^(void) {
        [self.view setFrame:CGRectOffset(self.view.frame, 0, - 100)];
    } completion:nil];
}

- (void)UIKeyboardWillHideNotification:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSNumber *durationValue = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    [UIView animateWithDuration:durationValue.doubleValue delay:0.0 options:(animationCurve << 16) animations:^(void) {
        [self.view setFrame:CGRectOffset(self.view.frame, 0, 100)];
    } completion:nil];
}

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
