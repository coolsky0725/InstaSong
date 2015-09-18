//
//  NotificationViewController.h
//  InstaSong
//
//  Created by zongda liang on 2/5/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "MBProgressHUD.h"

@interface NotificationViewController : UIViewController< UITableViewDataSource, UITableViewDelegate, EGORefreshTableDelegate,UIScrollViewDelegate>
{
    int            swipedIndex;
    int            selectedIndex;
    NSMutableArray *myNotificationList;
    BOOL           reloadFlag;
    
    BOOL                        reloading;
    int                         reloadIndex;
    EGORefreshTableHeaderView   *refreshHeaderView;
    EGORefreshTableFooterView   *refreshFooterView;
}

@property (nonatomic, retain) IBOutlet UITableView *notificationTableView;

- (void)replaceNotificationObject :(PFObject*)obj;
@end
