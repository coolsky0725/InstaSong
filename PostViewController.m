//
//  PostViewController.m
//  InstaSong
//
//  Created by zongda liang on 1/8/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "PostViewController.h"
#import "TSLibraryImport.h"
#import "DataManager.h"
#import "RecordingViewController.h"

@implementation PostViewController
@synthesize titleField;
@synthesize sounNameLabel;
@synthesize descriptionView;
@synthesize HUD;
@synthesize tagsField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *recognizer;
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.view addGestureRecognizer:recognizer];
    recordingFlag = NO;
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (recordingFlag && [DataManager getInstance].savedFlag) {
        [sounNameLabel setText:@"record.caf"];
        recordingFlag = NO;
        soundFileUrl = [DataManager getInstance].recordingSoundUrl;
    }
    
    if ([DataManager getInstance].groupPostFlag) {
        [DataManager getInstance].groupPostFlag =! [DataManager getInstance].groupPostFlag;
        soundFileUrl = nil;
        [titleField setText:@""];
        [sounNameLabel setText:@""];
        [descriptionView setText:@""];
        [tagsField setText:@""];
    }
}
- (void)handleTap
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) onClickSoundImport:(id)sender
{
    [self.view endEditing:YES];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"iTunes", @"Recording", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)onClickPostButton:(id)sender
{
    if ([titleField.text isEqualToString:@""]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the title!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    } else if (soundFileUrl == nil) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please select the sound file!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    } else if (tagsField == nil) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the tags!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    } else {
        
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [HUD setLabelText:@"Posting..."];
        PFObject *postObject = [PFObject objectWithClassName:@"Post"];
        [postObject setObject:[[DataManager getInstance].currentUser objectId] forKey:@"userid"];
        [postObject setObject:[[DataManager getInstance].currentUser username] forKey:@"publisher_name"];
        [postObject setObject:sounNameLabel.text forKey:@"filename"];
        NSString *path = [soundFileUrl path];
        NSData *soundData = [[NSFileManager defaultManager] contentsAtPath:path];
        PFFile *soundFile = [PFFile fileWithName:sounNameLabel.text data:soundData];
        [postObject setObject:soundFile forKey:@"audio_file"];
        
        PFFile *profileImageFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
        UIImage *profileImage = [UIImage imageWithData:[profileImageFile getData]];
        NSData *data = UIImageJPEGRepresentation([self imageWithImage:profileImage scaledToSize:CGSizeMake(50, 50)], 1.0f);
        PFFile *imageFile = [PFFile fileWithName:@"publisher_image.jpg" data:data];
        [postObject setObject:imageFile forKey:@"publisher_image"];
        
        [postObject setObject:titleField.text forKey:@"title"];
        [postObject setObject:descriptionView.text forKey:@"description"];
        [postObject setObject:[NSMutableArray array] forKey:@"likes"];
        [postObject setObject:[NSMutableArray array] forKey:@"comments"];
        [postObject setObject:tagsField.text forKey:@"tags"];
        [postObject setObject:[NSNumber numberWithInt:1] forKey:@"type"];
        [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (!error) {
                NSString *post_number = [[DataManager getInstance].currentUser objectForKey:@"post_number"];
                [[DataManager getInstance].currentUser setObject:[NSString stringWithFormat:@"%i", [post_number intValue] + 1] forKey:@"post_number"];
                [[DataManager getInstance].currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    [HUD hide:YES];
                    if (!error) {
                        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Successful!" message:@"Audio successfully posted!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];
                        soundFileUrl = nil;
                        [titleField setText:@""];
                        [sounNameLabel setText:@""];
                        [descriptionView setText:@""];
                        [tagsField setText:@""];
                    }
                }];
            } else {
                [HUD hide:YES];
                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Post failed!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

- (IBAction)onClickGroupPostButton:(id)sender
{
    if ([titleField.text isEqualToString:@""]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the title!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    } else if (soundFileUrl == nil) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please select the sound file!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    } else if ([tagsField.text isEqualToString:@""]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the tags!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    } else {
        [DataManager getInstance].groupPostTitile = titleField.text;
        [DataManager getInstance].groupPostSoundUrl = soundFileUrl;
        [DataManager getInstance].groupPostDescription = descriptionView.text;
        [DataManager getInstance].groupPostTags = tagsField.text;
        [DataManager getInstance].groupPostFileName = sounNameLabel.text;
        [self performSegueWithIdentifier:@"GroupPost" sender:nil];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        recordingFlag = YES;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        RecordingViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"RecordingViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (buttonIndex == 0){
        
        MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
        picker.delegate                    = self;
        picker.allowsPickingMultipleItems  = NO;
        picker.prompt                      = NSLocalizedString(@"Select the song", @"Prompt to user to choose song to upload");
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated:YES];
        [self presentViewController: picker animated: YES completion:nil];
    }
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    //play your file here
    [self dismissViewControllerAnimated:YES completion:nil];
    mediaItem = [mediaItemCollection.items objectAtIndex:0];
    NSURL *url = [mediaItem valueForProperty: MPMediaItemPropertyAssetURL];
    if (url == nil) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Warning!" message:@"You have selected an icloud file. Please download it to your device and select it again." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    } else {
        NSString *soundTitle = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
        soundTitle = [NSString stringWithFormat:@"%@.%@", soundTitle, [TSLibraryImport extensionForAssetURL:url]];
        [sounNameLabel setText:soundTitle];
        [self exportAssetAtURL:url withTitle:[mediaItem valueForProperty:MPMediaItemPropertyTitle]];
    }
}

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title {
	
	// create destination URL
	NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	soundFileUrl = [[NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:title]] URLByAppendingPathExtension:ext];
	// we're responsible for making sure the destination url doesn't already exist
	[[NSFileManager defaultManager] removeItemAtURL:soundFileUrl error:nil];
	
	// create the import object
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.userInteractionEnabled = NO;
	TSLibraryImport* import = [[TSLibraryImport alloc] init];
	[import importAsset:assetURL toURL:soundFileUrl completionBlock:^(TSLibraryImport* import) {
		if (import.status == AVAssetExportSessionStatusCompleted) {
			// something went wrong with the import
            [HUD hide:YES];
			NSLog(@"importing finished!");
		} else if (import.status == AVAssetExportSessionStatusFailed){
            [HUD hide:YES];
			NSLog(@"importing failed");
            soundFileUrl = nil;
            [sounNameLabel setText:@""];
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Warning!" message:@"Importing failed." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
        }
	}];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [self.view setFrame:CGRectOffset(self.view.frame, 0, - 90)];
    } completion:nil];
    
}

- (void)UIKeyboardWillHideNotification:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSNumber *durationValue = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    [UIView animateWithDuration:durationValue.doubleValue delay:0.0 options:(animationCurve << 16) animations:^(void) {
        [self.view setFrame:CGRectOffset(self.view.frame, 0, 90)];
    } completion:nil];
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
