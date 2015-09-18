//
//  HomeViewController.h
//  InstaSong
//
//  Created by betcoin on 1/13/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "MBProgressHUD.h"
#import "CircleProgressBar.h"

@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, EGORefreshTableDelegate,UIScrollViewDelegate, UIActionSheetDelegate>
{
    NSMutableArray              *myPostList;
    int                         selectedIndex;
    BOOL                        showAddCommentViewFlag;
    
    BOOL                        isPlaying;
    int                         songIndex;
    NSTimer                     *timer;
    AVAudioPlayer               *player;
    
    BOOL                        reloading;
    int                         reloadIndex;
    EGORefreshTableHeaderView   *refreshHeaderView;
    EGORefreshTableFooterView   *refreshFooterView;    
}
@property (nonatomic, retain) IBOutlet UITableView *postTableView;
@property (nonatomic, retain) IBOutlet CircleProgressBar *myCircleProgressBar;
@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) IBOutlet UIView       *playerView;
@property (nonatomic, retain) IBOutlet UIImageView  *albumImgView;
@property (nonatomic, retain) IBOutlet UILabel      *titleLable;
@property (nonatomic, retain) IBOutlet UILabel      *durTimeLabel;
@property (nonatomic, retain) IBOutlet UISlider     *progressSlider;
@property (nonatomic, retain) IBOutlet UIButton     *playButton;
@property (nonatomic, retain) IBOutlet UIButton     *stopButton;

@end
