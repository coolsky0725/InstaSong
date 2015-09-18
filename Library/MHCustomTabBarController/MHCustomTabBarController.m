/*
 * Copyright (c) 2013 Martin Hartl
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "MHCustomTabBarController.h"
#import "MHTabBarSegue.h"
#import  <Parse/Parse.h>
#import "DataManager.h"

NSString *const MHCustomTabBarControllerViewControllerChangedNotification = @"MHCustomTabBarControllerViewControllerChangedNotification";
NSString *const MHCustomTabBarControllerViewControllerAlreadyVisibleNotification = @"MHCustomTabBarControllerViewControllerAlreadyVisibleNotification";

@implementation MHCustomTabBarController
{
    NSMutableDictionary *_viewControllersByIdentifier;
}
@synthesize notificationLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewControllersByIdentifier = [NSMutableDictionary dictionary];
    [self performSegueWithIdentifier:@"viewController1" sender:nil];
    CALayer *bkLayer = [notificationLabel layer];
    [bkLayer setMasksToBounds:YES];
    [bkLayer setCornerRadius:10];
    [notificationLabel setHidden:YES];
    timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(updateNotifications) userInfo:nil repeats:YES];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.destinationViewController.view.frame = self.container.bounds;
}

- (void)updateNotifications
{
    PFQuery *query1 = [PFQuery queryWithClassName:@"Notification"];
    [query1 whereKey:@"receiver_id" equalTo:[[DataManager getInstance].currentUser objectId]];
    [query1 whereKey:@"status" equalTo:[NSNumber numberWithInt:1]];
    PFQuery *query2 = [PFQuery queryWithClassName:@"Notification"];
    [query2 whereKey:@"sender_id" equalTo:[[DataManager getInstance].currentUser objectId]];
    [query2 whereKey:@"status" equalTo:[NSNumber numberWithInt:1]];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [query orderByDescending:@"updatedAt"];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            if (number == 0) {
                [notificationLabel setHidden:YES];
            } else {
                [notificationLabel setText:[NSString stringWithFormat:@"%i", number]];
                [notificationLabel setHidden:YES];
            }
        }
    }];
}
#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if (![segue isKindOfClass:[MHTabBarSegue class]]) {
        [super prepareForSegue:segue sender:sender];
        return;
    }
    self.oldViewController = self.destinationViewController;
    
    //if view controller isn't already contained in the viewControllers-Dictionary
    if (![_viewControllersByIdentifier objectForKey:segue.identifier]) {
        [_viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
    }
    
    for (UIButton *aButton in self.buttons) {
        [aButton setSelected:NO];
    }
        
    UIButton *button = (UIButton *)sender;
    [button setSelected:YES];
    self.destinationIdentifier = segue.identifier;
    self.destinationViewController = [_viewControllersByIdentifier objectForKey:self.destinationIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerChangedNotification object:nil]; 

    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.destinationIdentifier isEqual:identifier]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerAlreadyVisibleNotification object:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [[_viewControllersByIdentifier allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (![self.destinationIdentifier isEqualToString:key]) {
            [_viewControllersByIdentifier removeObjectForKey:key];
        }
    }];
}

@end
