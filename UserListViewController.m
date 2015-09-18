//
//  UserListViewController.m
//  InstaSong
//
//  Created by zongda liang on 1/21/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "UserListViewController.h"
#import "UserViewController.h"

@implementation UserListViewController
@synthesize titleLabel;
@synthesize userTableView;
@synthesize controllerType;
@synthesize HUD;
@synthesize selectedObject;

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
    if (controllerType == 1) {
        [titleLabel setText:@"Follower"];
    } else if (controllerType == 2) {
        [titleLabel setText:@"Following"];
    }
    followingList = [[DataManager getInstance].currentUser objectForKey:@"following"];
    if (followingList == nil) {
        followingList =[NSMutableArray array];
    }
    [userTableView setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (controllerType == 1) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        PFQuery *query = [PFUser query];
        [query whereKey:@"following_string" containsString:[selectedObject objectId]];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (![HUD isHidden]) {
                [HUD hide:YES];
            }
            if (!error) {
                userList = [NSMutableArray arrayWithArray:objects];
                [userTableView reloadData];
            }
        }];
        
    } else if (controllerType == 2) {
        
        NSMutableArray *followingArray = [selectedObject objectForKey:@"following"];
        if ([followingArray count] > 0) {
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            PFQuery *query = [PFUser query];
            [query whereKey:@"objectId" containedIn:followingArray];
            [query orderByDescending:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (![HUD isHidden]) {
                    [HUD hide:YES];
                }
                if (!error) {
                    userList = [NSMutableArray arrayWithArray:objects];
                    [userTableView reloadData];
                }
            }];
        }
    }
}

#pragma mark onClickBackButton
- (IBAction)onClickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of sections.
    return [userList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCell"];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    PFObject *userObject = [userList objectAtIndex:indexPath.row];
    
    UIButton *bkImageView = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, tableView.frame.size.width - 10, 59)];
    [bkImageView setImage:[UIImage imageNamed:@"cell_bk.png"] forState:UIControlStateNormal];
    [bkImageView setTag:indexPath.row];
    CALayer *bkLayer = [bkImageView layer];
    [bkLayer setMasksToBounds:YES];
    [bkLayer setCornerRadius:3];
    [bkImageView setTag:indexPath.row];
    [bkImageView addTarget:self action:@selector(onClickUser:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:bkImageView];
    
    PFFile  *userImgFile = [userObject objectForKey:@"profile_image"];
    UIImage *userImage = [UIImage imageWithData:[userImgFile getData]];
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 44, 44)];
    CALayer * l = [userImageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:userImageView.frame.size.width / 2];
    [userImageView setImage:userImage];
    [cell addSubview:userImageView];
    
    NSString *username = [userObject objectForKey:@"username"];
    UILabel *usernameLable = [[UILabel alloc] initWithFrame:CGRectMake(57, 13, tableView.frame.size.width - 132, 33)];
    [usernameLable setTextColor:[UIColor whiteColor]];
    [usernameLable setFont:[UIFont systemFontOfSize:17.0f]];
    [usernameLable setText:username];
    [cell addSubview:usernameLable];
    
    UIButton *followButton = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width -85, 15, 77, 30)];
    [followButton setTag:indexPath.row];
    NSString *userid = [userObject objectId];
    if ([followingList containsObject:userid]) {
        [followButton setImage:[UIImage imageNamed:@"followed_button"] forState:UIControlStateNormal];
    } else {
        [followButton setImage:[UIImage imageNamed:@"follow_button"] forState:UIControlStateNormal];
    }
    [followButton addTarget:self action:@selector(onClickFollowButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:followButton];
    return cell;
}

- (void)onClickUser:(UIButton*)sender
{
    int rowIndex = (int)sender.tag;
    PFUser *obj = [userList objectAtIndex:rowIndex];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    viewController.userObject = obj;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onClickFollowButton:(UIButton*)sender
{
    PFUser *userObj = [userList objectAtIndex:sender.tag];
    if ([followingList containsObject:[userObj objectId]]) {
        [followingList removeObject:[userObj objectId]];
        [sender setImage:[UIImage imageNamed:@"follow_button"] forState:UIControlStateNormal];
    } else {
        [followingList addObject:[userObj objectId]];
        [sender setImage:[UIImage imageNamed:@"followed_button"] forState:UIControlStateNormal];
    }
    [[DataManager getInstance].currentUser setObject:followingList forKey:@"following"];
    [[DataManager getInstance].currentUser saveInBackground];
}

@end
