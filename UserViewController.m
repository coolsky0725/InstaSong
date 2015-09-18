//
//  UserViewController.m
//  InstaSong
//
//  Created by zongda liang on 1/21/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "UserViewController.h"
#import "SVPullToRefresh.h"
#import "AddCommentViewController.h"
#import "UserListViewController.h"

@implementation UserViewController
@synthesize postTableView;
@synthesize usernameLabel;
@synthesize profileImageView;
@synthesize followerLabel;
@synthesize followingLabel;
@synthesize postLabel;
@synthesize HUD;
@synthesize pullToRefreshFlag;
@synthesize userObject;
@synthesize followingButton;
@synthesize followerBkButton;
@synthesize followingBkButton;

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
    [postTableView setBackgroundColor:[UIColor clearColor]];
    CALayer * l = [profileImageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:profileImageView.frame.size.width / 2];
    
    [usernameLabel setText:[userObject username]];
    PFFile *profileFile = [userObject objectForKey:@"profile_image"];
    profileImage = [UIImage imageWithData:[profileFile getData]];
    [profileImageView setImage:profileImage];
    NSMutableArray *followingArray = [userObject objectForKey:@"following"];
    [followingLabel setText:[NSString stringWithFormat:@"%i", (int)[followingArray count]]];
    NSMutableArray *followerArray = [userObject objectForKey:@"follower"];
    [followerLabel setText:[NSString stringWithFormat:@"%i", (int)[followerArray count]]];
    [postLabel setText:[userObject objectForKey:@"post_number"]];
    
    myPostList = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    [postTableView addPullToRefreshWithActionHandler:^{
        weakSelf.pullToRefreshFlag = YES;
        [weakSelf getPostList];
    }];
    [self getPostList];
    
    showAddCommentViewFlag = NO;
    
    currentUserFollowingArray = [[DataManager getInstance].currentUser objectForKey:@"following"];
    if ([currentUserFollowingArray containsObject:[userObject objectId]]) {
        [followingButton setBackgroundImage:[UIImage imageNamed:@"following_profile.png"] forState:UIControlStateNormal];
        [followingButton setTitle:@"Following" forState:UIControlStateNormal];
        [followingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [followingButton setBackgroundImage:[UIImage imageNamed:@"follow_profile.png"] forState:UIControlStateNormal];
        [followingButton setTitle:@"Follow" forState:UIControlStateNormal];
        [followingButton setTitleColor:[UIColor colorWithRed:0.0f green:0.702f blue:0.525f alpha:1.0f] forState:UIControlStateNormal];
    }
    
    [followingBkButton addTarget:self action:@selector(onClickFollowingBkButton:) forControlEvents:UIControlEventTouchUpInside];
    [followerBkButton addTarget:self action:@selector(onClickFollowerBkButton:) forControlEvents:UIControlEventTouchUpInside];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"following_string" containsString:[userObject objectId]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (error == nil) {
            [followerLabel setText:[NSString stringWithFormat:@"%i", number]];
        } else {
            [followerLabel setText:[NSString stringWithFormat:@"%i", 0]]; 
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (showAddCommentViewFlag) {
        [myPostList removeObjectAtIndex:selectedIndex];
        [myPostList insertObject:[DataManager getInstance].postObject atIndex:selectedIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        [postTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        selectedIndex = -1;
    }
}

#pragma mark onClickFollowingBkButton
- (void)onClickFollowingBkButton:(UIButton*)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UserListViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"UserList"];
    viewController.controllerType = 2;
    viewController.selectedObject = userObject;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark onClickFollowerBkButton
-(void)onClickFollowerBkButton:(UIButton*)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UserListViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"UserList"];
    viewController.controllerType = 1;
    viewController.selectedObject = userObject;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark get current user post list
- (void)getPostList
{
    if (!pullToRefreshFlag) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"userid" equalTo:[userObject objectId]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (![HUD isHidden]) {
            [HUD hide:YES];
        }
        if (pullToRefreshFlag) {
            pullToRefreshFlag = NO;
            [postTableView.pullToRefreshView stopAnimating ];
        }
        [HUD hide:YES];
        if (!error) {
            myPostList = [NSMutableArray arrayWithArray:objects];
            [postTableView reloadData];
        }
    }];
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of sections.
    return [myPostList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int offsetY = 75;
    PFObject *obj = [myPostList objectAtIndex:indexPath.row];
    NSMutableArray *likesArray = [obj objectForKey:@"likes"];
    if ([likesArray count] > 0) {
        offsetY += 25;
    }
    NSString *description = [obj objectForKey:@"description"];
    NSMutableArray *commentsArray = [obj objectForKey:@"comments"];
    
    if ([description length] != 0) {
        
        description = [NSString stringWithFormat:@"%@ %@",[userObject username], description];
        NSRange range = [description rangeOfString:[userObject username]];
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:description attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:15.0f]}];
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f green:0.58f blue:1.0f alpha:1.0f] range:range];
        CGRect rt = [attriString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 40, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        offsetY += rt.size.height + 5;
    }
    
    for (int i = 0; i < [commentsArray count]; i++) {
        NSMutableDictionary *dic = [commentsArray objectAtIndex:i];
        NSString *publisherName = [dic objectForKey:@"commenterName"];
        NSString *comment = [dic objectForKey:@"comment"];
        
        NSString *commentString = [NSString stringWithFormat:@"%@ %@", publisherName, comment];
        NSRange range = [commentString rangeOfString:publisherName];
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:commentString attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:15.0f]}];
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f green:0.58f blue:1.0f alpha:1.0f] range:range];
        CGRect rt = [attriString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 40, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        offsetY += rt.size.height + 5;
    }
    return offsetY + 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    PFObject *obj = [myPostList objectAtIndex:indexPath.row];
    
    float cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    UIImageView *bkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,cellHeight - 5)];
    [bkImageView setImage:[UIImage imageNamed:@"cell_bk.png"]];
    CALayer *bkLayer = [bkImageView layer];
    [bkLayer setMasksToBounds:YES];
    [bkLayer setCornerRadius:3];
    [cell addSubview:bkImageView];
    
    
    UIImageView *publisherImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 13, 35, 35)];
    [publisherImageView setImage:profileImage];
    CALayer * l = [publisherImageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:publisherImageView.frame.size.width / 2];
    [cell addSubview:publisherImageView];
    
    UILabel *publisherNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 21, tableView.frame.size.width - 80, 23)];
    [publisherNameLabel setTextColor:[UIColor whiteColor]];
    [publisherNameLabel setFont:[UIFont systemFontOfSize:19.0f]];
    [publisherNameLabel setText:[userObject username]];
    [cell addSubview:publisherNameLabel];
    
    UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 33, 21, 33, 23)];
    [durationLabel setTextColor:[UIColor whiteColor]];
    [durationLabel setFont:[UIFont systemFontOfSize:13.0f]];
    
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
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 56, tableView.frame.size.width - 10, 19)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [titleLabel setText:[NSString stringWithFormat:@"Title: %@", [obj objectForKey:@"title"]]];
    [cell addSubview:titleLabel];
    
    int offsetY = 75;
    
    NSMutableArray *likesArray = [obj objectForKey:@"likes"];
    if ([likesArray count] > 3) {
        UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, offsetY, 20, 20)];
        [likeImageView setImage:[UIImage imageNamed:@"feed_button_like.png"]];
        [cell addSubview:likeImageView];
        
        UIButton *likesButton = [[UIButton alloc] initWithFrame:CGRectMake(30, offsetY, 100, 20)];
        [likesButton setTitle:[NSString stringWithFormat:@"%i likes", (int)[likesArray count]] forState:UIControlStateNormal];
        [likesButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [likesButton addTarget:self action:@selector(onClickLikesButton:) forControlEvents:UIControlEventTouchUpInside];
        [likesButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [likesButton setTag:indexPath.row];
        
        offsetY += 25;
        
    } else if ([likesArray count] > 0) {
        UIImageView *likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, offsetY, 20, 20)];
        [likeImageView setImage:[UIImage imageNamed:@"feed_button_like.png"]];
        [cell addSubview:likeImageView];
        
        int offsetX = 30;
        for (int i = 0; i < [likesArray count]; i ++) {
            NSMutableDictionary *dic = [likesArray objectAtIndex:i];
            NSString *likerName = [dic objectForKey:@"likerName"];
            int width = [self findWidthForText:likerName havingHeight:20.0f andFont:[UIFont systemFontOfSize:15.0f]] + 5;
            UIButton *likerbutton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, width, 20.0f)];
            [likerbutton setTitle:likerName forState:UIControlStateNormal];
            [likerbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [likerbutton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [likerbutton addTarget:self action:@selector(onClickLikerButton:) forControlEvents:UIControlEventTouchUpInside];
            [likerbutton setTag:indexPath.row];
            [likerbutton.titleLabel setTag:i];
            [cell addSubview:likerbutton];
            offsetX += width + 10;
        }
        offsetY += 25;
    }
    
    NSString *description = [obj objectForKey:@"description"];
    NSMutableArray *commentsArray = [obj objectForKey:@"comments"];
    if ([description length] != 0 || [commentsArray count] != 0) {
        UIImageView *commentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, offsetY, 20, 20)];
        [commentImageView setImage:[UIImage imageNamed:@"feed_button_comment.png"]];
        [cell addSubview:commentImageView];
    }
    
    if ([description length] != 0) {
        
        description = [NSString stringWithFormat:@"%@ %@",[userObject username], description];
        NSRange range = [description rangeOfString:[userObject username]];
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:description attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:15.0f]}];
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f green:0.58f blue:1.0f alpha:1.0f] range:range];
        CGRect rt = [attriString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 40, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        
        UILabel *descriptionLable = [[UILabel alloc] initWithFrame:CGRectMake(30, offsetY, cell.frame.size.width - 40, rt.size.height)];
        [descriptionLable setAttributedText:attriString];
        descriptionLable.numberOfLines = 0;
        [cell addSubview:descriptionLable];
        
        UIButton *publisherButton = [[UIButton alloc] initWithFrame:CGRectMake(30, offsetY, 150, 20)];
        [publisherButton setTitleColor:[UIColor colorWithRed:0.0f green:0.58f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        publisherButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //        [publisherButton addTarget:self action:@selector(onClickMeButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:publisherButton];
        offsetY += rt.size.height + 5;
    }
    
    for (int i = 0; i < [commentsArray count]; i++) {
        NSMutableDictionary *dic = [commentsArray objectAtIndex:i];
        NSString *publisherName = [dic objectForKey:@"commenterName"];
        NSString *comment = [dic objectForKey:@"comment"];
        
        NSString *commentString = [NSString stringWithFormat:@"%@ %@", publisherName, comment];
        NSRange range = [commentString rangeOfString:publisherName];
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:commentString attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont systemFontOfSize:15.0f]}];
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f green:0.58f blue:1.0f alpha:1.0f] range:range];
        CGRect rt = [attriString boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 40, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        
        UILabel *descriptionLable = [[UILabel alloc] initWithFrame:CGRectMake(30, offsetY, cell.frame.size.width - 40, rt.size.height)];
        [descriptionLable setAttributedText:attriString];
        descriptionLable.numberOfLines = 0;
        [cell addSubview:descriptionLable];
        
        UIButton *publisherButton = [[UIButton alloc] initWithFrame:CGRectMake(30, offsetY, 150, 20)];
        [publisherButton setTitleColor:[UIColor colorWithRed:0.0f green:0.58f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        publisherButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [publisherButton setTag:indexPath.row];
        [publisherButton.titleLabel setTag:i];
        [publisherButton addTarget:self action:@selector(onClickCommenterButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:publisherButton];
        
        offsetY += rt.size.height + 5;
    }
    
    BOOL flag = NO;
    for (int i = 0; i < [likesArray count]; i++) {
        NSMutableDictionary *dic = [likesArray objectAtIndex:i];
        NSString *objectID = [dic objectForKey:@"likerID"];
        if ([objectID isEqualToString:[userObject objectId]]) {
            flag = YES;
            break;
        }
    }
    
    if (flag) {
        UIButton *likeButton = [[UIButton alloc] initWithFrame: CGRectMake(5, offsetY, 70, 24)];
        [likeButton.titleLabel setTag:indexPath.row];
        [likeButton setTitle:@" Liked" forState:UIControlStateNormal];
        [likeButton setImage:[UIImage imageNamed:@"feed_button_like_active.png"] forState:UIControlStateNormal];
//        [likeButton addTarget:self action:@selector(onClickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        [likeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [likeButton setTag:indexPath.row];
        [cell addSubview:likeButton];
    } else {
        UIButton *likeButton = [[UIButton alloc] initWithFrame: CGRectMake(5, offsetY, 60, 24)];
        [likeButton.titleLabel setTag:indexPath.row];
        [likeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [likeButton setTitle:@" Like" forState:UIControlStateNormal];
        [likeButton setImage:[UIImage imageNamed:@"feed_button_like.png"] forState:UIControlStateNormal];
//        [likeButton addTarget:self action:@selector(onClickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        [likeButton setTag:indexPath.row];
        [cell addSubview:likeButton];
    }
    
    UIButton *commentButton = [[UIButton alloc] initWithFrame: CGRectMake(80, offsetY, 115, 24)];
    [commentButton setImage:[UIImage imageNamed:@"feed_button_comment.png"] forState:UIControlStateNormal];
    [commentButton setTitle:@" Comment" forState:UIControlStateNormal];
    [commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commentButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
//    [commentButton addTarget:self action:@selector(onClickAddComment:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:commentButton];
    return cell;
}

- (void)onClickMeButton:(UIButton*)sender
{
    int rowIndex = (int)sender.tag;
    PFObject *obj = [myPostList objectAtIndex:rowIndex];
    NSString *likerID = [obj objectForKey:@"userid"];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:likerID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [HUD hide:YES];
        if ([objects count] == 1) {
            PFUser *user = [objects objectAtIndex:0];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
            viewController.userObject = user;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

- (void)onClickCommenterButton:(UIButton*)sender
{
    int rowIndex = (int)sender.tag;
    int colIndex = (int)sender.titleLabel.tag;
    PFObject *obj = [myPostList objectAtIndex:rowIndex];
    NSMutableArray *commentsArray = [obj objectForKey:@"comments"];
    NSMutableDictionary *dic = [commentsArray objectAtIndex:colIndex];
    NSString *likerID = [dic objectForKey:@"commentID"];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:likerID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [HUD hide:YES];
        if ([objects count] == 1) {
            PFUser *user = [objects objectAtIndex:0];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
            viewController.userObject = user;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

- (void)onClickLikesButton:(UIButton*)sender
{
    
}

- (void)onClickLikerButton:(UIButton*)sender
{
    int rowIndex = (int)sender.tag;
    int colIndex = (int)sender.titleLabel.tag;
    PFObject *obj = [myPostList objectAtIndex:rowIndex];
    NSMutableArray *likesArray = [obj objectForKey:@"likes"];
    NSMutableDictionary *dic = [likesArray objectAtIndex:colIndex];
    NSString *likerID = [dic objectForKey:@"likerID"];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:likerID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [HUD hide:YES];
        if ([objects count] == 1) {
            PFUser *user = [objects objectAtIndex:0];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
            viewController.userObject = user;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }];
}

- (void)onClickLikeButton:(UIButton*)sender
{
    NSLog(@"%@", sender.titleLabel.text);
    PFObject *obj = [myPostList objectAtIndex:sender.tag];
    NSMutableArray *likesArray = [obj objectForKey:@"likes"];
    if ([sender.titleLabel.text isEqualToString:@" Liked"]) {
        for (int i = 0; i < [likesArray count]; i++) {
            NSMutableDictionary *dic = [likesArray objectAtIndex:i];
            NSString *objectID = [dic objectForKey:@"likerID"];
            if ([objectID isEqualToString:[userObject objectId]]) {
                [likesArray removeObjectAtIndex:i];
                break;
            }
        }
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[userObject username],@"likerName", [userObject objectId], @"likerID", nil];
        [likesArray addObject:dic];
    }
    [obj setObject:likesArray forKey:@"likes"];
    [myPostList removeObjectAtIndex:sender.tag];
    [myPostList insertObject:obj atIndex:sender.tag];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [postTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [obj saveInBackground];
}

- (void)onClickAddComment:(UIButton*)sender
{
    selectedIndex = (int) sender.tag;
    showAddCommentViewFlag = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AddCommentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddComment"];
    viewController.object = [myPostList objectAtIndex:sender.tag];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark click following button
- (IBAction)onClickFollowingButton:(id)sender
{
    currentUserFollowingString = [[DataManager getInstance].currentUser objectForKey:@"following_string"];
    currentUserFollowingArray = [[DataManager getInstance].currentUser objectForKey:@"following"];
    if (!currentUserFollowingArray) {
        currentUserFollowingArray = [NSMutableArray array];
    }
    
    if ([currentUserFollowingArray containsObject:[userObject objectId]]) {
        
        [followingButton setBackgroundImage:[UIImage imageNamed:@"follow_profile.png"] forState:UIControlStateNormal];
        [followingButton setTitle:@"Follow" forState:UIControlStateNormal];
        [followingButton setTitleColor:[UIColor colorWithRed:0.0f green:0.702f blue:0.525f alpha:1.0f] forState:UIControlStateNormal];
        [currentUserFollowingArray removeObject:[userObject objectId]];
        currentUserFollowingString = [currentUserFollowingString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:", [userObject objectId]] withString:@""];        
    } else {
        
        [followingButton setBackgroundImage:[UIImage imageNamed:@"following_profile.png"] forState:UIControlStateNormal];
        [followingButton setTitle:@"Following" forState:UIControlStateNormal];
        [followingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [currentUserFollowingArray addObject:[userObject objectId]];
        currentUserFollowingString = [NSString stringWithFormat:@"%@%@:", currentUserFollowingString, [userObject objectId]];
    }
    [[DataManager getInstance].currentUser setObject:currentUserFollowingArray forKey:@"following"];
    [[DataManager getInstance].currentUser setObject:currentUserFollowingString forKey:@"following_string"];
    [[DataManager getInstance].currentUser saveInBackground];
}

#pragma mark onClickBackButton
- (IBAction)onClickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark calculate the height of text
- (CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font
{
    CGSize constraint = CGSizeMake(widthValue, NSUIntegerMax);
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [text boundingRectWithSize:constraint
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:attributes
                                     context:nil];
    return rect.size.height;
}

- (CGFloat)findWidthForText:(NSString *)text havingHeight:(CGFloat)heightValue andFont:(UIFont *)font
{
    CGSize constraint = CGSizeMake(self.view.frame.size.width, heightValue);
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [text boundingRectWithSize:constraint
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:attributes
                                     context:nil];
    return rect.size.width;
}

@end