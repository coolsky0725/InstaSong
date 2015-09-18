//
//  GroupPostViewController.h
//  InstaSong
//
//  Created by zongda liang on 1/21/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "MBProgressHUD.h"

@interface GroupPostViewController : UIViewController <UISearchBarDelegate, UIAlertViewDelegate, EGORefreshTableDelegate,UIScrollViewDelegate>
{
    NSString                    *searchString;
    NSMutableArray              *searchList;
    BOOL                        reloading;
    int                         reloadIndex;
    EGORefreshTableHeaderView   *refreshHeaderView;
    EGORefreshTableFooterView   *refreshFooterView;
}
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *searchTableView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) MBProgressHUD *HUD;
@end
