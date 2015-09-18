//
//  SignUpViewController.m
//  InstaSong
//
//  Created by zongda liang on 1/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@implementation SignUpViewController
@synthesize usernameField;
@synthesize emailField;
@synthesize passwordField;
@synthesize confirmPasswordField;
@synthesize profileView;
@synthesize HUD;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CALayer * l = [profileView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:profileView.frame.size.width / 2];
    
    profileImage = nil;
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark click backButton
 - (IBAction)onClickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark click signup button
- (IBAction)onClickSignupButton:(id)sender
{
    if ([usernameField.text isEqualToString:@"User Name"]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the last name!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [usernameField becomeFirstResponder];
    } else if ([emailField.text isEqualToString:@"Email"]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the email address!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [emailField becomeFirstResponder];
    } else if (![self Emailvalidate:emailField.text]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the valied email address!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [emailField becomeFirstResponder];
    } else if ([passwordField.text isEqualToString:@"Password"]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the password!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [passwordField becomeFirstResponder];
    } else if (![confirmPasswordField.text isEqualToString:passwordField.text]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Confirm password is not equal!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [confirmPasswordField becomeFirstResponder];
    } else if (profileImage == nil) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please select the avator!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    } else {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [HUD setLabelText:@"Sign Up..."];
        
        PFUser *user = [PFUser user];
        user.username = usernameField.text;
        user.password = passwordField.text;
        user.email = emailField.text;
        NSData *data = UIImageJPEGRepresentation(profileImage, 1.0f);
        PFFile *imageFile = [PFFile fileWithName:@"profile.jpg" data:data];
        [user setObject:imageFile forKey:@"profile_image"];
        [user setObject:@"0" forKey:@"post_number"];
        [user setObject:@"0" forKey:@"follower_number"];
        [user setObject:@"0" forKey:@"following_number"];
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

#pragma mark upload profile image
-(IBAction)onClickProfileImageButton:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Gallery", nil];
    [actionSheet showInView:self.view];
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
    [profileView setImage:profileImage];
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

#pragma mark check email validate
-(BOOL) Emailvalidate:(NSString *)tempMail
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:tempMail];
}

#pragma mark alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextfield delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
//    if (self.view.frame.origin.y != -100) {
//        [self.view setFrame: CGRectOffset(self.view.frame, 0, -100)];
//    }
    if (textField.tag == 2 && [textField.text isEqualToString:@"User Name"]) {
        [textField setText:@""];
    } else if (textField.tag == 3 && [textField.text isEqualToString:@"Email"]) {
        [textField setText:@""];
    } else if (textField.tag == 4 && [textField.text isEqualToString:@"Password"]) {
        [textField setText:@""];
        [textField setSecureTextEntry:YES];
    } else if (textField.tag == 5 && [textField.text isEqualToString:@"Confirm Password"]) {
        [textField setText:@""];
        [textField setSecureTextEntry:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
//    if (self.view.frame.origin.y != 0) {
//        [self.view setFrame: CGRectOffset(self.view.frame, 0, 100)];
//    }
    
    if ([textField.text isEqualToString:@""]) {
        switch (textField.tag) {
            case 1:
                
                break;
            case 2:
                [textField setText:@"User Name"];
                break;
            case 3:
                [textField setText:@"Email"];
                break;
            case 4:
                [textField setText:@"Password"];
                [textField setSecureTextEntry:NO];
                break;
            case 5:
                [textField setText:@"Confirm Password"];
                [textField setSecureTextEntry:NO];
                break;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
