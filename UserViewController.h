//
//  UserViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/21/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "MBProgressHUD.h"

@interface UserViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UIImage *profileImage;
    NSMutableArray *myPostList;

    int     selectedIndex;
    BOOL    showAddCommentViewFlag;
    
    NSMutableArray *currentUserFollowingArray;
    NSString       *currentUserFollowingString;
}
@property (nonatomic, retain) IBOutlet UITableView *postTableView;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) IBOutlet UILabel *followerLabel;
@property (nonatomic, retain) IBOutlet UILabel *followingLabel;
@property (nonatomic, retain) IBOutlet UILabel *postLabel;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic)         BOOL    pullToRefreshFlag;
@property (nonatomic, retain) PFUser    *userObject;
@property (nonatomic, retain) IBOutlet UIButton *followingButton;
@property (nonatomic, retain) IBOutlet UIButton *followingBkButton;
@property (nonatomic, retain) IBOutlet UIButton *followerBkButton;
@end
