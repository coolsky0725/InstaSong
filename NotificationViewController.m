//
//  NotificationViewController.m
//  InstaSong
//
//  Created by zongda liang on 2/5/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "NotificationViewController.h"
#import "PostGroupViewController.h"
#import "PreviewViewController.h"

@implementation NotificationViewController
@synthesize notificationTableView;

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
    swipedIndex = -1;
    myNotificationList = [NSMutableArray array];
    [notificationTableView setBackgroundColor:[UIColor clearColor]];
    [self createHeaderView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doSingleTap:)];
    [notificationTableView addGestureRecognizer:singleTap];
    [self showRefreshHeader:YES];
    [self beginToReloadData:EGORefreshHeader];
}

- (void)doSingleTap:(UITapGestureRecognizer*)recognizer
{
    if (swipedIndex != -1) {
        int prevIndex;
        prevIndex = swipedIndex;
        swipedIndex = -1;
        [notificationTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:prevIndex inSection: 0], nil] withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self showRefreshHeader:YES];
    [self beginToReloadData:EGORefreshHeader];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark get notification list
- (void)getNotificationList:(BOOL) flag
{
    PFQuery *query1 = [PFQuery queryWithClassName:@"Notification"];
    [query1 whereKey:@"receiver_id" equalTo:[[DataManager getInstance].currentUser objectId]];
    PFQuery *query2 = [PFQuery queryWithClassName:@"Notification"];
    [query2 whereKey:@"sender_id" equalTo:[[DataManager getInstance].currentUser objectId]];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [query orderByDescending:@"updatedAt"];
    if (false) {
        [query setLimit:30];
    } else {
        [query setLimit: [myNotificationList count] + 30];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        reloading = NO;
        
        if (!error) {
            if (refreshHeaderView) {
                [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:notificationTableView];
                myNotificationList = [NSMutableArray arrayWithArray:objects];
                [notificationTableView reloadData];
            }
            if (refreshFooterView) {
                [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:notificationTableView];
                myNotificationList = [NSMutableArray arrayWithArray:objects];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:reloadIndex inSection:0];
                [notificationTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            [self setFooterView];
        } else {
            if (refreshHeaderView) {
                [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:notificationTableView];
            }
            if (refreshFooterView) {
                [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:notificationTableView];
            }
        }
    }];
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of sections.
    return [myNotificationList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    PFObject *obj = [myNotificationList objectAtIndex:indexPath.row];
    if ([[obj objectForKey:@"type"] intValue] == 1 && [[obj objectForKey:@"receiver_id"] isEqualToString:[[DataManager getInstance].currentUser objectId]]) {
        
        if (swipedIndex != indexPath.row && [[obj objectForKey:@"status"] intValue] == 1) {
            UIButton *bkImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,47)];
            [bkImageView setImage:[UIImage imageNamed:@"cell_bk.png"] forState:UIControlStateNormal];
            [bkImageView setTag:indexPath.row];
            [bkImageView addTarget:self action:@selector(onClickNotificationButton:) forControlEvents:UIControlEventTouchUpInside];
            CALayer *bkLayer = [bkImageView layer];
            [bkLayer setMasksToBounds:YES];
            [bkLayer setCornerRadius:3];
            
            UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToLeftWithGestureRecognizer:)];
            swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            [bkImageView addGestureRecognizer:swipeLeftRecognizer];
            [cell addSubview:bkImageView];
            
            PFFile *imageFile = [obj objectForKey:@"sender_image"];
            UIImage *senderImage = [UIImage imageWithData:[imageFile getData]];
            UIImageView *senderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40)];
            [senderImageView setImage:senderImage];
            CALayer * l = [senderImageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:senderImageView.frame.size.width / 2];
            [cell addSubview:senderImageView];
            
            PFFile *receiverImageFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
            UIImage *receiverImage = [UIImage imageWithData:[receiverImageFile getData]];
            UIImageView *receiverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(46, 3, 40, 40)];
            [receiverImageView setImage:receiverImage];
            CALayer * rl = [receiverImageView layer];
            [rl setMasksToBounds:YES];
            [rl setCornerRadius:receiverImageView.frame.size.width / 2];
            [cell addSubview:receiverImageView];
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 3, tableView.frame.size.width - 125, 40)];
            [messageLabel setTextColor:[UIColor whiteColor]];
            [messageLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [messageLabel setNumberOfLines:2];
            [messageLabel setText:[NSString stringWithFormat:@"%@ has sent group post to you!", [obj objectForKey:@"sender_name"]]];
            [cell addSubview:messageLabel];
            
            UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 33, 3, 30, 20)];
            [durationLabel setTextColor:[UIColor whiteColor]];
            [durationLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [durationLabel setTextAlignment:NSTextAlignmentRight];
            NSDate *createdDate = [obj updatedAt];
            NSDate *now = [NSDate date];
            NSTimeInterval interval = [now timeIntervalSinceDate:createdDate];
            int numberOfHours = interval / 3600;
            if (interval < 3600) {
                [durationLabel setText:[NSString stringWithFormat:@"%im", (int)interval / 60]];
            } else if (numberOfHours < 24) {
                [durationLabel setText:[NSString stringWithFormat:@"%iH", numberOfHours]];
            } else if ( numberOfHours < 168) {
                [durationLabel setText:[NSString stringWithFormat:@"%iD", numberOfHours / 24]];
            } else if ( numberOfHours <  720) {
                [durationLabel setText:[NSString stringWithFormat:@"%iW", numberOfHours / 168]];
            } else if ( numberOfHours < 8670) {
                [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 720]];
            } else {
                [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 8670]];
            }
            [cell addSubview:durationLabel];
            
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 53, 20, 50, 20)];
            [statusLabel setTextColor:[UIColor whiteColor]];
            [statusLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [statusLabel setTextAlignment:NSTextAlignmentRight];
            [statusLabel setText:@"Pending"];
            [cell addSubview: statusLabel];
            
        } else if ([[obj objectForKey:@"status"] intValue] == 1){
            
            UIButton *bkImageView = [[UIButton alloc] initWithFrame:CGRectMake( 0, 0, tableView.frame.size.width,47)];
            [bkImageView setImage:[UIImage imageNamed:@"cell_bk.png"] forState:UIControlStateNormal];
            [bkImageView setTag:indexPath.row];
            [bkImageView addTarget:self action:@selector(onClickNotificationButton:) forControlEvents:UIControlEventTouchUpInside];
            CALayer *bkLayer = [bkImageView layer];
            [bkLayer setMasksToBounds:YES];
            [bkLayer setCornerRadius:3];
            
            UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToLeftWithGestureRecognizer:)];
            swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            [bkImageView addGestureRecognizer:swipeLeftRecognizer];
            
            [cell addSubview:bkImageView];
            
            PFFile *imageFile = [obj objectForKey:@"sender_image"];
            UIImage *senderImage = [UIImage imageWithData:[imageFile getData]];
            UIImageView *senderImageView = [[UIImageView alloc] initWithFrame:CGRectMake( - 77, 3, 40, 40)];
            [senderImageView setImage:senderImage];
            CALayer * l = [senderImageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:senderImageView.frame.size.width / 2];
            [cell addSubview:senderImageView];
            
            PFFile *receiverImageFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
            UIImage *receiverImage = [UIImage imageWithData:[receiverImageFile getData]];
            UIImageView *receiverImageView = [[UIImageView alloc] initWithFrame:CGRectMake( - 24, 3, 40, 40)];
            [receiverImageView setImage:receiverImage];
            CALayer * rl = [receiverImageView layer];
            [rl setMasksToBounds:YES];
            [rl setCornerRadius:receiverImageView.frame.size.width / 2];
            [cell addSubview:receiverImageView];
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake( 20, 3, tableView.frame.size.width - 125, 40)];
            [messageLabel setTextColor:[UIColor whiteColor]];
            [messageLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [messageLabel setNumberOfLines:2];
            [messageLabel setText:[NSString stringWithFormat:@"%@ has sent group post to you!", [obj objectForKey:@"sender_name"]]];
            [cell addSubview:messageLabel];
            
            UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 113, 3, 33, 40)];
            [durationLabel setTextColor:[UIColor whiteColor]];
            [durationLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [durationLabel setTextAlignment:NSTextAlignmentCenter];
            NSDate *createdDate = [obj updatedAt];
            NSDate *now = [NSDate date];
            NSTimeInterval interval = [now timeIntervalSinceDate:createdDate];
            int numberOfHours = interval / 3600;
            if (interval < 3600) {
                [durationLabel setText:[NSString stringWithFormat:@"%im", (int)interval / 60]];
            } else if (numberOfHours < 24) {
                [durationLabel setText:[NSString stringWithFormat:@"%iH", numberOfHours]];
            } else if ( numberOfHours < 168) {
                [durationLabel setText:[NSString stringWithFormat:@"%iD", numberOfHours / 24]];
            } else if ( numberOfHours <  720) {
                [durationLabel setText:[NSString stringWithFormat:@"%iW", numberOfHours / 168]];
            } else if ( numberOfHours < 8670) {
                [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 720]];
            } else {
                [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 8670]];
            }
            [cell addSubview:durationLabel];
            
            UIButton *rejectButton = [[UIButton alloc] initWithFrame: CGRectMake(tableView.frame.size.width - 70, 8, 60, 30)];
            [rejectButton setImage:[UIImage imageNamed:@"reject_button.png"] forState: UIControlStateNormal];
            [rejectButton setTag:indexPath.row];
            [rejectButton addTarget:self action:@selector(onClickRejectButton:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview: rejectButton];
            
        } else if ( [[obj objectForKey:@"status"] intValue] == 2 ) {

            UIButton *bkImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,47)];
            [bkImageView setImage:[UIImage imageNamed:@"cell_bk.png"] forState:UIControlStateNormal];
            [bkImageView setTag:indexPath.row];
            [bkImageView addTarget:self action:@selector(onClickResendButton:) forControlEvents:UIControlEventTouchUpInside];
            CALayer *bkLayer = [bkImageView layer];
            [bkLayer setMasksToBounds:YES];
            [bkLayer setCornerRadius:3];
            [cell addSubview:bkImageView];
            
            PFFile *imageFile = [obj objectForKey:@"sender_image"];
            UIImage *senderImage = [UIImage imageWithData:[imageFile getData]];
            UIImageView *senderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40)];
            [senderImageView setImage:senderImage];
            CALayer * l = [senderImageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:senderImageView.frame.size.width / 2];
            [cell addSubview:senderImageView];
            
            PFFile *receiverImageFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
            UIImage *receiverImage = [UIImage imageWithData:[receiverImageFile getData]];
            UIImageView *receiverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(46, 3, 40, 40)];
            [receiverImageView setImage:receiverImage];
            CALayer * rl = [receiverImageView layer];
            [rl setMasksToBounds:YES];
            [rl setCornerRadius:receiverImageView.frame.size.width / 2];
            [cell addSubview:receiverImageView];
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 3, tableView.frame.size.width - 125, 40)];
            [messageLabel setTextColor:[UIColor whiteColor]];
            [messageLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [messageLabel setNumberOfLines:2];
            [messageLabel setText:[NSString stringWithFormat:@"%@ has sent group post to you!", [obj objectForKey:@"sender_name"]]];
            [cell addSubview:messageLabel];
            
            UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 33, 3, 30, 20)];
            [durationLabel setTextColor:[UIColor whiteColor]];
            [durationLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [durationLabel setTextAlignment:NSTextAlignmentRight];
            NSDate *createdDate = [obj updatedAt];
            NSDate *now = [NSDate date];
            NSTimeInterval interval = [now timeIntervalSinceDate:createdDate];
            int numberOfHours = interval / 3600;
            if (interval < 3600) {
                [durationLabel setText:[NSString stringWithFormat:@"%im", (int)interval / 60]];
            } else if (numberOfHours < 24) {
                [durationLabel setText:[NSString stringWithFormat:@"%iH", numberOfHours]];
            } else if ( numberOfHours < 168) {
                [durationLabel setText:[NSString stringWithFormat:@"%iD", numberOfHours / 24]];
            } else if ( numberOfHours <  720) {
                [durationLabel setText:[NSString stringWithFormat:@"%iW", numberOfHours / 168]];
            } else if ( numberOfHours < 8670) {
                [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 720]];
            } else {
                [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 8670]];
            }
            [cell addSubview:durationLabel];
            
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 63, 20, 60, 20)];
            [statusLabel setTextColor:[UIColor whiteColor]];
            [statusLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [statusLabel setTextAlignment:NSTextAlignmentRight];
            [statusLabel setText:@"Rejected"];
            [cell addSubview: statusLabel];
        } else if ( [[obj objectForKey:@"status"] intValue] == 3 ) {
            UIButton *bkImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,47)];
            [bkImageView setImage:[UIImage imageNamed:@"cell_bk.png"] forState:UIControlStateNormal];
            [bkImageView setTag:indexPath.row];
            [bkImageView addTarget:self action:@selector(onClickResendButton:) forControlEvents:UIControlEventTouchUpInside];
            CALayer *bkLayer = [bkImageView layer];
            [bkLayer setMasksToBounds:YES];
            [bkLayer setCornerRadius:3];
            [cell addSubview:bkImageView];
            
            PFFile *imageFile = [obj objectForKey:@"sender_image"];
            UIImage *senderImage = [UIImage imageWithData:[imageFile getData]];
            UIImageView *senderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40)];
            [senderImageView setImage:senderImage];
            CALayer * l = [senderImageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:senderImageView.frame.size.width / 2];
            [cell addSubview:senderImageView];
            
            PFFile *receiverImageFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
            UIImage *receiverImage = [UIImage imageWithData:[receiverImageFile getData]];
            UIImageView *receiverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(46, 3, 40, 40)];
            [receiverImageView setImage:receiverImage];
            CALayer * rl = [receiverImageView layer];
            [rl setMasksToBounds:YES];
            [rl setCornerRadius:receiverImageView.frame.size.width / 2];
            [cell addSubview:receiverImageView];
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 3, tableView.frame.size.width - 125, 40)];
            [messageLabel setTextColor:[UIColor whiteColor]];
            [messageLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [messageLabel setNumberOfLines:2];
            [messageLabel setText:[NSString stringWithFormat:@"%@ has sent group post to you!", [obj objectForKey:@"sender_name"]]];
            [cell addSubview:messageLabel];
            
            UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 33, 3, 30, 20)];
            [durationLabel setTextColor:[UIColor whiteColor]];
            [durationLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [durationLabel setTextAlignment:NSTextAlignmentRight];
            NSDate *createdDate = [obj updatedAt];
            NSDate *now = [NSDate date];
            NSTimeInterval interval = [now timeIntervalSinceDate:createdDate];
            int numberOfHours = interval / 3600;
            if (interval < 3600) {
                [durationLabel setText:[NSString stringWithFormat:@"%im", (int)interval / 60]];
            } else if (numberOfHours < 24) {
                [durationLabel setText:[NSString stringWithFormat:@"%iH", numberOfHours]];
            } else if ( numberOfHours < 168) {
                [durationLabel setText:[NSString stringWithFormat:@"%iD", numberOfHours / 24]];
            } else if ( numberOfHours <  720) {
                [durationLabel setText:[NSString stringWithFormat:@"%iW", numberOfHours / 168]];
            } else if ( numberOfHours < 8670) {
                [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 720]];
            } else {
                [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 8670]];
            }
            [cell addSubview:durationLabel];
            
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 63, 20, 60, 20)];
            [statusLabel setTextColor:[UIColor whiteColor]];
            [statusLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [statusLabel setTextAlignment:NSTextAlignmentRight];
            [statusLabel setText:@"Posted"];
            [cell addSubview: statusLabel];
        }
        
    } else if ([[obj objectForKey:@"type"] intValue] == 1 && [[obj objectForKey:@"sender_id"] isEqualToString:[[DataManager getInstance].currentUser objectId]]) {

        UIButton *bkImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,47)];
        [bkImageView setImage:[UIImage imageNamed:@"cell_bk.png"] forState:UIControlStateNormal];
        [bkImageView setTag:indexPath.row];
        [bkImageView addTarget:self action:@selector(onClickResendButton:) forControlEvents:UIControlEventTouchUpInside];
        CALayer *bkLayer = [bkImageView layer];
        [bkLayer setMasksToBounds:YES];
        [bkLayer setCornerRadius:3];
        [cell addSubview:bkImageView];
        
        PFFile *imageFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
        UIImage *senderImage = [UIImage imageWithData:[imageFile getData]];
        UIImageView *senderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 40, 40)];
        [senderImageView setImage:senderImage];
        CALayer * l = [senderImageView layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:senderImageView.frame.size.width / 2];
        [cell addSubview:senderImageView];
        
        PFFile *receiverImageFile = [obj objectForKey:@"receiver_image"];
        UIImage *receiverImage = [UIImage imageWithData:[receiverImageFile getData]];
        UIImageView *receiverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(46, 3, 40, 40)];
        [receiverImageView setImage:receiverImage];
        CALayer * rl = [receiverImageView layer];
        [rl setMasksToBounds:YES];
        [rl setCornerRadius:receiverImageView.frame.size.width / 2];
        [cell addSubview:receiverImageView];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 3, tableView.frame.size.width - 125, 40)];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [messageLabel setNumberOfLines:2];
        [messageLabel setText:[NSString stringWithFormat:@"You has sent group post to %@!", [obj objectForKey:@"receiver_name"]]];
        [cell addSubview:messageLabel];
        
        UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 33, 3, 30, 20)];
        [durationLabel setTextColor:[UIColor whiteColor]];
        [durationLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [durationLabel setTextAlignment:NSTextAlignmentRight];
        NSDate *createdDate = [obj createdAt];
        NSDate *now = [NSDate date];
        NSTimeInterval interval = [now timeIntervalSinceDate:createdDate];
        int numberOfHours = interval / 3600;
        if (interval < 3600) {
            [durationLabel setText:[NSString stringWithFormat:@"%im", (int)interval / 60]];
        } else if (numberOfHours < 24) {
            [durationLabel setText:[NSString stringWithFormat:@"%iH", numberOfHours]];
        } else if ( numberOfHours < 168) {
            [durationLabel setText:[NSString stringWithFormat:@"%iD", numberOfHours / 24]];
        } else if ( numberOfHours <  720) {
            [durationLabel setText:[NSString stringWithFormat:@"%iW", numberOfHours / 168]];
        } else if ( numberOfHours < 8670) {
            [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 720]];
        } else {
            [durationLabel setText:[NSString stringWithFormat:@"%iM", numberOfHours / 8670]];
        }
        [cell addSubview:durationLabel];
        
        if ([[obj objectForKey:@"status"] intValue] == 1){
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 73, 20, 70, 20)];
            [statusLabel setTextColor:[UIColor whiteColor]];
            [statusLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [statusLabel setTextAlignment:NSTextAlignmentRight];
            [statusLabel setText:@"Pending"];
            [cell addSubview: statusLabel];
        } else if ([[obj objectForKey:@"status"] intValue] == 2){
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 73, 20, 70, 20)];
            [statusLabel setTextColor:[UIColor whiteColor]];
            [statusLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [statusLabel setTextAlignment:NSTextAlignmentRight];
            [statusLabel setText:@"Rejected"];
            [cell addSubview: statusLabel];
        } else if ([[obj objectForKey:@"status"] intValue] == 2){
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 73, 20, 70, 20)];
            [statusLabel setTextColor:[UIColor whiteColor]];
            [statusLabel setFont:[UIFont systemFontOfSize:13.0f]];
            [statusLabel setTextAlignment:NSTextAlignmentRight];
            [statusLabel setText:@"Posted"];
            [cell addSubview: statusLabel];
        }
    }
    return cell;
}

- (void)onClickNotificationButton:(UIButton*)sender
{
    if (swipedIndex != -1) {
        [self doSingleTap:nil];
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PostGroupViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PostGroup"];
    viewController.object = [myNotificationList objectAtIndex:sender.tag];
    viewController.parentController = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onClickResendButton:(UIButton*)sender
{
    if (swipedIndex != -1) {
        [self doSingleTap:nil];
        return;
    }
    selectedIndex = (int) sender.tag;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PreviewViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"Preview"];
    viewController.object = [myNotificationList objectAtIndex:sender.tag];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)replaceNotificationObject :(PFObject*)obj
{
    [myNotificationList removeObjectAtIndex:selectedIndex];
    [myNotificationList insertObject:obj atIndex:selectedIndex];
    reloadFlag = YES;
}

- (void)onClickRejectButton:(UIButton*)sender
{
    
    if (swipedIndex != -1) {
        
        PFObject *obj = [myNotificationList objectAtIndex:swipedIndex];
        [obj setObject:[NSNumber numberWithInt:2] forKey:@"status"];
        [myNotificationList removeObjectAtIndex:swipedIndex];
        [myNotificationList insertObject:obj atIndex:swipedIndex];
        [self doSingleTap:nil];
        [obj saveInBackground];
    }
}

- (void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint swipeLocation = [recognizer locationInView: notificationTableView];
        NSIndexPath *swipedIndexPath = [notificationTableView indexPathForRowAtPoint:swipeLocation];
        PFObject *obj = [myNotificationList objectAtIndex:swipedIndexPath.row];
        if ([[obj objectForKey:@"type"] intValue] == 1) {
            int prevIndex;
            prevIndex = swipedIndex;
            swipedIndex = (int) swipedIndexPath.row;
            NSArray *indexArray;
            if (prevIndex == swipedIndex) {
                return;
            } else if (prevIndex == -1) {
                indexArray = [NSArray arrayWithObjects:swipedIndexPath, nil];
            } else {
                indexArray = [NSArray arrayWithObjects:swipedIndexPath, [NSIndexPath indexPathForRow:prevIndex inSection: 0], nil];
            }
            [notificationTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

#pragma mark force to show the refresh headerView
-(void)showRefreshHeader:(BOOL)animated{
	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		notificationTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        // scroll the table view to the top region
        [notificationTableView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
        [UIView commitAnimations];
	} else {
        notificationTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[notificationTableView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
	}
    
    [refreshHeaderView setState:EGOOPullRefreshLoading];
}
//===============

#pragma methods for creating and removing the header view

-(void)createHeaderView{
    if (refreshHeaderView && [refreshHeaderView superview]) {
        [refreshHeaderView removeFromSuperview];
    }
	refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame: CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
    refreshHeaderView.delegate = self;
	[notificationTableView addSubview:refreshHeaderView];
    [refreshHeaderView refreshLastUpdatedDate];
}

-(void)removeHeaderView{
    if (refreshHeaderView && [refreshHeaderView superview]) {
        [refreshHeaderView removeFromSuperview];
    }
    refreshHeaderView = nil;
}

-(void)setFooterView{
    // if the footerView is nil, then create it, reset the position of the footer
    CGFloat height = MAX(notificationTableView.contentSize.height, notificationTableView.frame.size.height);
    if (refreshFooterView && [refreshFooterView superview]) {
        // reset position
        refreshFooterView.frame = CGRectMake(0.0f, height, notificationTableView.frame.size.width, notificationTableView.bounds.size.height);
    }else {
        // create the footerView
        refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame: CGRectMake(0.0f, height, notificationTableView.frame.size.width, self.view.bounds.size.height)];
        refreshFooterView.delegate = self;
        [notificationTableView addSubview:refreshFooterView];
    }
    if (refreshFooterView) {
        [refreshFooterView refreshLastUpdatedDate];
    }
}

-(void)removeFooterView{
    if (refreshFooterView && [refreshFooterView superview]) {
        [refreshFooterView removeFromSuperview];
    }
    refreshFooterView = nil;
}


#pragma mark data reloading methods that must be overide by the subclass

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
	
	//  should be calling your tableviews data source model to reload
    reloading = YES;
    if (aRefreshPos == EGORefreshHeader) {
        [self getNotificationList:YES];
    }else if(aRefreshPos == EGORefreshFooter){
        [self getNotificationList:NO];
    }
}

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (refreshHeaderView) {
        [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	if (refreshFooterView) {
        [refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if (refreshHeaderView) {
        [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
	if (refreshFooterView) {
        [refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark EGORefreshTableDelegate Methods

- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
	[self beginToReloadData:aRefreshPos];
	
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
	return reloading;
}

- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view{
	return [NSDate date]; // should return date data source was last changed
}

@end
