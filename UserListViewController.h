//
//  UserListViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/21/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface UserListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray  *userList;
    NSMutableArray  *followingList;
}
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UITableView *userTableView;
@property (nonatomic, assign) int controllerType;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) PFUser    *selectedObject;
@end
