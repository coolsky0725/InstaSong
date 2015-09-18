//
//  SignInViewController.m
//  InstaSong
//
//  Created by zongda liang on 1/6/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "SignInViewController.h"
#import "DataManager.h"
#import "AppDelegate.h"

@implementation SignInViewController
@synthesize backgroundView;
@synthesize emailField;
@synthesize passwordField;
@synthesize HUD;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeBackground) userInfo:nil repeats:YES];
}

- (void)changeBackground
{
    bkFlag = !bkFlag;
    if (bkFlag) {
        [backgroundView setImage:[UIImage imageNamed:@"background1.png"]];
    } else {
        [backgroundView setImage:[UIImage imageNamed:@"background2.png"]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
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

- (void)UIKeyboardWillShowNotification:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSNumber *durationValue = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    [UIView animateWithDuration:durationValue.doubleValue delay:0.0 options:(animationCurve << 16) animations:^(void) {
        [self.view setFrame:CGRectOffset(self.view.frame, 0, - 50)];
    } completion:nil];
    
}

- (void)UIKeyboardWillHideNotification:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSNumber *durationValue = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = keyboardInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    [UIView animateWithDuration:durationValue.doubleValue delay:0.0 options:(animationCurve << 16) animations:^(void) {
        [self.view setFrame:CGRectOffset(self.view.frame, 0, 50)];
    } completion:nil];
}


#pragma mark click back button
-  (IBAction)onClickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark click Sign In buttonok thanks
- (IBAction)onClickSignInButton:(id)sender
{
    if ([emailField.text isEqualToString:@""]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the email address!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [emailField becomeFirstResponder];
    } else if (![self Emailvalidate:emailField.text]) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the valied email address!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [emailField becomeFirstResponder];
    } else if ([passwordField.text isEqualToString:@""]){
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please input the password!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
        [passwordField becomeFirstResponder];
    } else {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [HUD setLabelText:@"Sign In..."];
        PFQuery *query = [PFUser query];
        [query whereKey:@"email" equalTo:emailField.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if ([objects count] == 1) {
                PFUser *user = [objects objectAtIndex:0];
                NSString *username = [user username];
                [PFUser logInWithUsernameInBackground:username password:passwordField.text
                  block:^(PFUser *user, NSError *error) {
                      [HUD hide:YES];
                      if (user) {
                          // Do stuff after successful login.
                          [DataManager getInstance].currentUser = user;
                          BOOL isEmailVerified = [user[@"emailVerified"] boolValue];
                          if (isEmailVerified) {
                              [self performSegueWithIdentifier:@"home" sender:nil];
                          } else {
                              UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please verify your email address!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Resend", nil];
                              [alert show];
                          }
                      } else {
                          UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Email or password is incorrect.Please check again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                          [alert show];
                      }
                  }];
            } else {
                [HUD hide:YES];
                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Email or password is incorrect.Please check again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

#pragma mark alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            NSString *email = [[alertView textFieldAtIndex:0] text];
            [PFUser requestPasswordResetForEmailInBackground:email];
        }
        return;
    }
    
    if (buttonIndex == 1) {
        [[DataManager getInstance].currentUser setObject:emailField.text forKey:@"email"];
        [[DataManager getInstance].currentUser saveInBackground];
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Alarm!" message:@"Resent email verification message. Please verify your email address!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
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

#pragma mark UITextfield delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"Email"]) {
        [textField setText:@""];
    } else if ([textField.text isEqualToString:@"Password"]) {
        [textField setText:@""];
        [textField setSecureTextEntry:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        switch (textField.tag) {
            case 1:
                [textField setText:@"Email"];
                break;
            case 2:
                [textField setText:@"Password"];
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

#pragma mark facebook
- (IBAction)onClickFacebookButton:(id)sender
{
    // this button's job is to flip-flop the session from open to closed
    if (FBSession.activeSession.isOpen) {
        // login is integrated with the send button -- so if open, we send
        [self getUserInfo];
    } else {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"public_profile, email", nil];
        [FBSession openActiveSessionWithReadPermissions:permissions  allowLoginUI:YES
             completionHandler:^(FBSession *session,
                                 FBSessionState status,
                                 NSError *error) {
                 // if login fails for any reason, we alert
                 if (error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                     message:error.localizedDescription
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                     // send our requests if we successfully logged in
                     [self getUserInfo];
                 }
             }];
    }
}

- (void) getUserInfo
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *fbuser, NSError *error) {
         if (!error) {
             PFQuery *query = [PFUser query];
             [query whereKey:@"email" equalTo: [NSString stringWithFormat:@"%@@gmail.com", [fbuser id]]];
             [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                 if ([objects count] == 1) {
                     PFUser *user = [objects objectAtIndex:0];
                     [DataManager getInstance].currentUser = user;
                     [self performSegueWithIdentifier:@"home" sender:nil];
                 } else {
                     PFUser *user = [PFUser user];
                     user.username = [fbuser objectForKey:@"name"];
                     user.password = @"123456";
                     user.email = [NSString stringWithFormat:@"%@@gmail.com", [fbuser id]];
                     NSString *imageUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [fbuser id]];
                     UIImage *profileImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
                     profileImage = [self imageWithImage:profileImage scaledToSize:CGSizeMake(75, 75)];
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
                             [DataManager getInstance].currentUser = user;
                             [self performSegueWithIdentifier:@"home" sender:nil];
                         }
                     }];
                 }
             }];
         }
     }];
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

- (IBAction)onClickForgotPasswordButton:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"forgot password?" message:@"Please input the email address!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
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
