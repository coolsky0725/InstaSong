//
//  ProfileViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/7/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "MBProgressHUD.h"

@interface ProfileViewController : UIViewController< UITableViewDataSource, UITableViewDelegate, EGORefreshTableDelegate,UIScrollViewDelegate, UIActionSheetDelegate>
{
    UIImage *profileImage;
    PFUser  *currentUser;
    NSMutableArray *myPostList;
    
    int     selectedIndex;
    BOOL    showAddCommentViewFlag;
    
    BOOL                        reloading;
    int                         reloadIndex;
    EGORefreshTableHeaderView   *refreshHeaderView;
    EGORefreshTableFooterView   *refreshFooterView;
    
    int     deleteIndex;
}
@property (nonatomic, retain) IBOutlet UITableView *postTableView;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) IBOutlet UILabel *followerLabel;
@property (nonatomic, retain) IBOutlet UILabel *followingLabel;
@property (nonatomic, retain) IBOutlet UILabel *postLabel;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) IBOutlet UIButton *followingBkButton;
@property (nonatomic, retain) IBOutlet UIButton *followerBkButton;
@end
