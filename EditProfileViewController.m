//
//  EditProfileViewController.m
//  InstaSong
//
//  Created by zongda liang on 1/21/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "EditProfileViewController.h"

@implementation EditProfileViewController
@synthesize passwordField;
@synthesize currentPasswordField;
@synthesize confirmPasswordField;
@synthesize avatorImageView;
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
    PFFile *profileFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
    profileImage = [UIImage imageWithData:[profileFile getData]];
    [avatorImageView setImage:profileImage];
    CALayer * l = [avatorImageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:avatorImageView.frame.size.width / 2];
    [self registerForKeyboardNotifications];
}

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextfield delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 1 && [textField.text isEqualToString:@"Current Password"]) {
        [textField setText:@""];
    } else if (textField.tag == 2 && [textField.text isEqualToString:@"New Password"]) {
        [textField setText:@""];
    } else if (textField.tag == 3 && [textField.text isEqualToString:@"Confirm Password"]) {
        [textField setText:@""];
    }
    [textField setSecureTextEntry:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{   
    if ([textField.text isEqualToString:@""]) {
        switch (textField.tag) {
            case 1:
                [textField setText:@"Current Password"];
                break;
            case 2:
                [textField setText:@"New Password"];
                break;
            case 3:
                [textField setText:@"Confirm Password"];
                break;
        }
        [textField setSecureTextEntry:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

#pragma mark onClickEditButton
- (IBAction)onClickEditButton:(id)sender
{
    NSString *currentPassword = [[DataManager getInstance].currentUser objectForKey:@"password"];
    if (![currentPasswordField.text isEqualToString:currentPassword]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Current password is not corrent.Please check again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [currentPasswordField becomeFirstResponder];
    } else if ([passwordField.text isEqualToString:@""]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the new password!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [passwordField becomeFirstResponder];
    }else if (![passwordField.text isEqualToString:confirmPasswordField.text]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Confirm password is not same. Please check again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [confirmPasswordField becomeFirstResponder];
    } else {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DataManager getInstance].currentUser setObject:passwordField.text forKey:@"password"];
        NSData *data = UIImageJPEGRepresentation(profileImage, 1.0f);
        PFFile *imageFile = [PFFile fileWithName:@"profile.jpg" data:data];
        [[DataManager getInstance].currentUser setObject:imageFile forKey:@"profile_image"];
        [[DataManager getInstance].currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            [HUD hide:YES];
            if (!error) {
                // Hooray! Let them use the app now.
                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Success!" message:@"Sent email verification message. Please verify your email address!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"%@", errorString);
            }
        }];
    }
}

#pragma mark alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        [picker setSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        [picker setDelegate: self];
        picker.allowsEditing = YES;
        [self presentViewController:picker animated: YES completion:nil];
    } else if (buttonIndex == 0){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Camera" message:@"Can't use this functionality!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        [picker setSourceType: UIImagePickerControllerSourceTypeCamera];
        [picker setDelegate: self];
        picker.allowsEditing = YES;
        [self presentViewController:picker animated: YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    profileImage = [self imageWithImage:info[UIImagePickerControllerEditedImage] scaledToSize:CGSizeMake(75, 75)];
    [avatorImageView setImage:profileImage];
    
}

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
