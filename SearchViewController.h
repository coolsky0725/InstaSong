//
//  SearchViewController.h
//  InstaSong
//
//  Created by betcoin on 1/14/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "MBProgressHUD.h"

@interface SearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, EGORefreshTableDelegate,UIScrollViewDelegate>
{
    NSString                    *searchString;
    NSMutableArray              *searchList;
    
    NSString                    *following_string;
    NSMutableArray              *followingList;
    
    int                         selectedIndex;
    BOOL                        showAddCommentViewFlag;
    
    BOOL                        reloading;
    int                         reloadIndex;
    EGORefreshTableHeaderView   *refreshHeaderView;
    EGORefreshTableFooterView   *refreshFooterView;
    
    BOOL                        isPlaying;
    int                         songIndex;
    NSTimer                     *timer;
    AVAudioPlayer               *player;
}

@property (nonatomic, retain) IBOutlet UISearchBar      *searchBar;
@property (nonatomic, retain) IBOutlet UITableView      *searchTableView;
@property (nonatomic, retain) IBOutlet UIProgressView   *progressView;
@property (nonatomic, retain) IBOutlet UIView           *playerView;
@property (nonatomic, retain) IBOutlet UIImageView      *albumImgView;
@property (nonatomic, retain) IBOutlet UILabel          *titleLable;
@property (nonatomic, retain) IBOutlet UILabel          *durTimeLabel;
@property (nonatomic, retain) IBOutlet UISlider         *progressSlider;
@property (nonatomic, retain) IBOutlet UIButton         *playButton;
@property (nonatomic, retain) IBOutlet UIButton         *stopButton;
@property (nonatomic, retain) MBProgressHUD             *HUD;
@end
