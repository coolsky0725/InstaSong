//
//  SearchViewController.m
//  InstaSong
//
//  Created by betcoin on 1/14/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "AddCommentViewController.h"
#import "SearchViewController.h"
#import "DataManager.h"
#import "UserViewController.h"


@implementation SearchViewController
@synthesize searchBar;
@synthesize searchTableView;
@synthesize progressView;
@synthesize playerView;
@synthesize albumImgView;
@synthesize titleLable;
@synthesize progressSlider;
@synthesize playButton;
@synthesize stopButton;
@synthesize durTimeLabel;
@synthesize HUD;

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
    searchList = [NSMutableArray array];
    [searchTableView setBackgroundColor:[UIColor clearColor]];
    UITapGestureRecognizer *tableTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTapped:)];
    [searchTableView addGestureRecognizer:tableTap];
    [self createHeaderView];
    
    followingList = [[DataManager getInstance].currentUser objectForKey:@"following"];
    if (followingList == nil) {
        followingList =[NSMutableArray array];
    }
    
    following_string = [[DataManager getInstance].currentUser objectForKey:@"following"];
    if (following_string == nil) {
        following_string = @"";
    }
    
    [playerView setHidden:YES];
    
    [progressSlider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
    [progressSlider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateHighlighted];
    [progressSlider setMaximumTrackImage:[UIImage imageNamed:@"maximum_track.png"] forState:UIControlStateNormal];
    UIImage *minImage = [[UIImage imageNamed:@"minimum_track.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [progressSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];

    player = [[AVAudioPlayer alloc] init];
    timer = nil;
    
    selectedIndex = -1;
    songIndex = -1;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    if (showAddCommentViewFlag) {
        [searchList removeObjectAtIndex:selectedIndex];
        [searchList insertObject:[DataManager getInstance].postObject atIndex:selectedIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        [searchTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) tableTapped:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
    CGPoint location = [tap locationInView:searchTableView];
    NSIndexPath *path = [searchTableView indexPathForRowAtPoint:location];
    if (path) {
        [self tableView:searchTableView didSelectRowAtIndexPath:path];
    } else {
        [self.view endEditing:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark search post
- (void)searchPost:(NSString*)query
{
    
}

#pragma mark search bar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
    [self.view endEditing:YES];
}

- (void)searchBar:(UISearchBar *)bar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    
    if (bar.selectedScopeButtonIndex == 0) {
        if (![playerView isHidden]) {
            [playerView setHidden:YES];
            [searchTableView setFrame:CGRectMake(searchTableView.frame.origin.x, searchTableView.frame.origin.y, searchTableView.frame.size.width, searchTableView.frame.size.height + 55)];
        }
    } else {
        if ([playerView isHidden]) {
            [playerView setHidden:NO];
            [searchTableView setFrame:CGRectMake(searchTableView.frame.origin.x, searchTableView.frame.origin.y, searchTableView.frame.size.width, searchTableView.frame.size.height - 55)];
        }
    }
    
    if ([bar.text length] == 0) {
        return;
    }
    
    if (bar.selectedScopeButtonIndex == 0) {
        [progressView setProgress:0.25f];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *temp = searchString;
            [NSThread sleepForTimeInterval:2];
            if ([temp isEqualToString:searchString]) {
                PFQuery *query = [PFQuery queryWithClassName:@"_User"];
                [query whereKey:@"username" containsString:searchString];
                [query setLimit:30];
                [query whereKey:@"objectId" notEqualTo:[[DataManager getInstance].currentUser objectId]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if ([temp isEqualToString:searchString]) {
                        if (!error) {
                            searchList = [NSMutableArray arrayWithArray:objects];
                            [self showWithProgress];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [progressView setProgress:0.0f];
                            });
                        }
                    }
                }];
            }
        });
    } else {
        [progressView setProgress:0.25f];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *temp = searchString;
            [NSThread sleepForTimeInterval:2];
            if ([temp isEqualToString:searchString]) {
                PFQuery *query = [PFQuery queryWithClassName:@"Post"];
                [query whereKey:@"tags" containsString:searchString];
                [query setLimit:30];
                [progressView setProgress:0.25f];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        searchList = [NSMutableArray arrayWithArray:objects];
                        [self showWithProgress];
                    } else {
                        [progressView setProgress:0.0f];
                    }
                }];
            }
        });
    }
}

- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText
{
    
    if ([bar.text length] != 0 && ![searchString isEqualToString:bar.text]) {
        searchString = bar.text;
        [progressView setProgress:0.25f];
        if (bar.selectedScopeButtonIndex == 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *temp = searchString;
                [NSThread sleepForTimeInterval:2];
                if ([temp isEqualToString:searchString]) {
                    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
                    [query whereKey:@"username" containsString:searchString];
                    [query whereKey:@"objectId" notEqualTo:[[DataManager getInstance].currentUser objectId]];
                    [query setLimit:30];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            searchList = [NSMutableArray arrayWithArray:objects];
                            [self showWithProgress];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [progressView setProgress:0.0f];
                            });
                        }
                    }];
                }
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *temp = searchString;
                [NSThread sleepForTimeInterval:2];
                if ([temp isEqualToString:searchString]) {
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
                    [query whereKey:@"tags" containsString:searchString];
                    [query setLimit:30];
                    [progressView setProgress:0.25f];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            searchList = [NSMutableArray arrayWithArray:objects];
                            [self showWithProgress];
                        } else {
                            [progressView setProgress:0.0f];
                        }
                    }];
                }
            });
        }
    } else {
        searchString = bar.text;
    }
}

-(void)showWithProgress {
    
    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.0];
}

-(void)increaseProgress {
    
    [progressView setProgress:progressView.progress + 0.1f animated:YES];
    
    if(progressView.progress < 1.0f)
    {
        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.1];
    } else {
        [self performSelector:@selector(dismissProgress) withObject:nil afterDelay:1.0];
    }
}

-(void)dismissProgress
{
    [searchTableView reloadData];
    [progressView setProgress:0.0f animated:NO];
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of sections.
    return [searchList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchBar.selectedScopeButtonIndex == 0) {
        return 60;
    } else {
        int offsetY;
        PFObject *obj = [searchList objectAtIndex:indexPath.row];
        int type = [[obj objectForKey:@"type"] intValue];
        if (type == 1) {
            offsetY = 75;
        } else {
            offsetY = 115;
        }
        
        NSMutableArray *likesArray = [obj objectForKey:@"likes"];
        if ([likesArray count] > 0) {
            offsetY += 25;
        }
        NSString *description = [obj objectForKey:@"description"];
        NSMutableArray *commentsArray = [obj objectForKey:@"comments"];
        
        if ([description length] != 0) {
            
            description = [NSString stringWithFormat:@"%@ %@",[[DataManager getInstance].currentUser username], description];
            NSRange range = [description rangeOfString:[[DataManager getInstance].currentUser username]];
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
        return offsetY + 28;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchBar.selectedScopeButtonIndex == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCell"];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        PFObject *userObject = [searchList objectAtIndex:indexPath.row];
        
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
        
    } else {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PostCell"];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        PFObject *obj = [searchList objectAtIndex:indexPath.row];
        
        int type = [[obj objectForKey:@"type"] intValue];
        
        if ( type == 1 ) {
            float cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            UIButton *bkImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,cellHeight - 3)];
            [bkImageView setImage:[UIImage imageNamed:@"cell_bk.png"] forState:UIControlStateNormal];
            [bkImageView setTag:indexPath.row];
            [bkImageView addTarget:self action:@selector(onClickAudioButton:) forControlEvents:UIControlEventTouchUpInside];
            CALayer *bkLayer = [bkImageView layer];
            [bkLayer setMasksToBounds:YES];
            [bkLayer setCornerRadius:3];
            [cell addSubview:bkImageView];
            
            PFFile  *publisherImgFile = [obj objectForKey:@"publisher_image"];
            UIImage *publisherImage = [UIImage imageWithData:[publisherImgFile getData]];
            UIImageView *publisherImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 35, 35)];
            [publisherImageView setImage:publisherImage];
            CALayer * l = [publisherImageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:publisherImageView.frame.size.width / 2];
            [cell addSubview:publisherImageView];
            
            UILabel *publisherNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 10, tableView.frame.size.width - 80, 35)];
            [publisherNameLabel setTextColor:[UIColor whiteColor]];
            [publisherNameLabel setFont:[UIFont systemFontOfSize:19.0f]];
            [publisherNameLabel setText:[obj objectForKey:@"publisher_name"]];
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
                [durationLabel setText:[NSString stringWithFormat:@"%iY", numberOfHours / 8670]];
            }
            [cell addSubview:durationLabel];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 50, tableView.frame.size.width - 10, 25)];
            [titleLabel setTextColor:[UIColor whiteColor]];
            [titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
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
                
                description = [NSString stringWithFormat:@"%@ %@",[obj objectForKey:@"publisher_name"], description];
                NSRange range = [description rangeOfString:[obj objectForKey:@"publisher_name"]];
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
                [publisherButton setTag:indexPath.row];
                [publisherButton addTarget:self action:@selector(onClickMeButton:) forControlEvents:UIControlEventTouchUpInside];
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
                if ([objectID isEqualToString:[[DataManager getInstance].currentUser objectId]]) {
                    flag = YES;
                    break;
                }
            }
            
            if (flag) {
                UIButton *likeButton = [[UIButton alloc] initWithFrame: CGRectMake(5, offsetY, 70, 24)];
                [likeButton.titleLabel setTag:indexPath.row];
                [likeButton setTitle:@" Liked" forState:UIControlStateNormal];
                [likeButton setImage:[UIImage imageNamed:@"feed_button_like_active.png"] forState:UIControlStateNormal];
                [likeButton addTarget:self action:@selector(onClickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
                [likeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
                [likeButton setTag:indexPath.row];
                [cell addSubview:likeButton];
            } else {
                UIButton *likeButton = [[UIButton alloc] initWithFrame: CGRectMake(5, offsetY, 60, 24)];
                [likeButton.titleLabel setTag:indexPath.row];
                [likeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
                [likeButton setTitle:@" Like" forState:UIControlStateNormal];
                [likeButton setImage:[UIImage imageNamed:@"feed_button_like.png"] forState:UIControlStateNormal];
                [likeButton addTarget:self action:@selector(onClickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
                [likeButton setTag:indexPath.row];
                [cell addSubview:likeButton];
            }
            
            UIButton *commentButton = [[UIButton alloc] initWithFrame: CGRectMake(80, offsetY, 115, 24)];
            [commentButton setImage:[UIImage imageNamed:@"feed_button_comment.png"] forState:UIControlStateNormal];
            [commentButton setTitle:@" Comment" forState:UIControlStateNormal];
            [commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [commentButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [commentButton addTarget:self action:@selector(onClickAddComment:) forControlEvents:UIControlEventTouchUpInside];
            [commentButton setTag:indexPath.row];
            [cell addSubview:commentButton];
            
            return cell;
            
        } else {
            
            float cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            UIButton *bkImageView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,cellHeight - 3)];
            [bkImageView setImage:[UIImage imageNamed:@"cell_bk.png"] forState:UIControlStateNormal];
            [bkImageView setTag:indexPath.row];
            [bkImageView addTarget:self action:@selector(onClickAudioButton:) forControlEvents:UIControlEventTouchUpInside];
            CALayer *bkLayer = [bkImageView layer];
            [bkLayer setMasksToBounds:YES];
            [bkLayer setCornerRadius:3];
            [cell addSubview:bkImageView];
            
            PFFile  *publisherImgFile = [obj objectForKey:@"publisher_image"];
            UIImage *publisherImage = [UIImage imageWithData:[publisherImgFile getData]];
            UIImageView *publisherImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 35, 35)];
            [publisherImageView setImage:publisherImage];
            CALayer * l = [publisherImageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:publisherImageView.frame.size.width / 2];
            [cell addSubview:publisherImageView];
            
            UILabel *publisherNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 10, tableView.frame.size.width - 80, 35)];
            [publisherNameLabel setTextColor:[UIColor whiteColor]];
            [publisherNameLabel setFont:[UIFont systemFontOfSize:19.0f]];
            [publisherNameLabel setText:[obj objectForKey:@"publisher_name"]];
            [cell addSubview:publisherNameLabel];
            
            UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 33, 21, 33, 23)];
            [durationLabel setTextColor:[UIColor whiteColor]];
            [durationLabel setFont:[UIFont systemFontOfSize:13.0f]];
            
            PFFile  *groupPublisherImgFile = [obj objectForKey:@"group_publisher_image"];
            UIImage *groupPublisherImage = [UIImage imageWithData:[groupPublisherImgFile getData]];
            UIImageView *groupPublisherImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 50, 35, 35)];
            [groupPublisherImageView setImage:groupPublisherImage];
            CALayer * gl = [groupPublisherImageView layer];
            [gl setMasksToBounds:YES];
            [gl setCornerRadius:groupPublisherImageView.frame.size.width / 2];
            [cell addSubview:groupPublisherImageView];
            
            UILabel *groupPublisherNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 50, tableView.frame.size.width - 80, 35)];
            [groupPublisherNameLabel setTextColor:[UIColor whiteColor]];
            [groupPublisherNameLabel setFont:[UIFont systemFontOfSize:19.0f]];
            [groupPublisherNameLabel setText:[obj objectForKey:@"group_publisher_name"]];
            [cell addSubview:groupPublisherNameLabel];
            
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
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 90, tableView.frame.size.width - 10, 25)];
            [titleLabel setTextColor:[UIColor whiteColor]];
            [titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
            [titleLabel setText:[NSString stringWithFormat:@"Title: %@", [obj objectForKey:@"title"]]];
            [cell addSubview:titleLabel];
            
            int offsetY = 115;
            
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
                
                description = [NSString stringWithFormat:@"%@ %@",[obj objectForKey:@"publisher_name"], description];
                NSRange range = [description rangeOfString:[obj objectForKey:@"publisher_name"]];
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
                [publisherButton setTag:indexPath.row];
                [publisherButton addTarget:self action:@selector(onClickMeButton:) forControlEvents:UIControlEventTouchUpInside];
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
                if ([objectID isEqualToString:[[DataManager getInstance].currentUser objectId]]) {
                    flag = YES;
                    break;
                }
            }
            
            if (flag) {
                UIButton *likeButton = [[UIButton alloc] initWithFrame: CGRectMake(5, offsetY, 70, 24)];
                [likeButton.titleLabel setTag:indexPath.row];
                [likeButton setTitle:@" Liked" forState:UIControlStateNormal];
                [likeButton setImage:[UIImage imageNamed:@"feed_button_like_active.png"] forState:UIControlStateNormal];
                [likeButton addTarget:self action:@selector(onClickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
                [likeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
                [likeButton setTag:indexPath.row];
                [cell addSubview:likeButton];
            } else {
                UIButton *likeButton = [[UIButton alloc] initWithFrame: CGRectMake(5, offsetY, 60, 24)];
                [likeButton.titleLabel setTag:indexPath.row];
                [likeButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
                [likeButton setTitle:@" Like" forState:UIControlStateNormal];
                [likeButton setImage:[UIImage imageNamed:@"feed_button_like.png"] forState:UIControlStateNormal];
                [likeButton addTarget:self action:@selector(onClickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
                [likeButton setTag:indexPath.row];
                [cell addSubview:likeButton];
            }
            
            UIButton *commentButton = [[UIButton alloc] initWithFrame: CGRectMake(80, offsetY, 115, 24)];
            [commentButton setImage:[UIImage imageNamed:@"feed_button_comment.png"] forState:UIControlStateNormal];
            [commentButton setTitle:@" Comment" forState:UIControlStateNormal];
            [commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [commentButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [commentButton addTarget:self action:@selector(onClickAddComment:) forControlEvents:UIControlEventTouchUpInside];
            [commentButton setTag:indexPath.row];
            [cell addSubview:commentButton];
            return cell;
        }
    }
}

- (void)onClickAudioButton:(UIButton*)sender
{
    PFObject *obj = [searchList objectAtIndex:sender.tag];
    [titleLable setText:[obj objectForKey:@"title"]];
    
    HUD = [MBProgressHUD showHUDAddedTo:playerView animated:YES];
    HUD.color = [UIColor clearColor];
    HUD.minSize = CGSizeMake(30, 30);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFFile *audioFile = [obj objectForKey:@"audio_file"];
        if (isPlaying) {
            [player stop];
        }
        
        NSString *filename = [obj objectForKey:@"filename"];
        if ([filename rangeOfString:@".mp3"].location != NSNotFound) {
            player  = [[AVAudioPlayer alloc] initWithData:[audioFile getData] fileTypeHint:AVFileTypeMPEGLayer3 error:nil];
        } else if([filename rangeOfString:@".wav"].location != NSNotFound){
            player  = [[AVAudioPlayer alloc] initWithData:[audioFile getData] fileTypeHint:AVFileTypeWAVE error:nil];
        } else if([filename rangeOfString:@".m4a"].location != NSNotFound) {
            player  = [[AVAudioPlayer alloc] initWithData:[audioFile getData] fileTypeHint:AVFileTypeAppleM4A error:nil];
        } else if([filename rangeOfString:@".caf"].location != NSNotFound) {
            player  = [[AVAudioPlayer alloc] initWithData:[audioFile getData] fileTypeHint:AVFileTypeCoreAudioFormat error:nil];
        } else {
            player  = [[AVAudioPlayer alloc] initWithData:[audioFile getData] fileTypeHint:AVFileTypeAIFF error:nil];
        }
        [player setDelegate:self];
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update the UI on the main thread.
            [playButton setBackgroundImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
            NSString *duration =[ NSString stringWithFormat:@"0:00 / %i:%02i", (int)player.duration / 60, (int) player.duration % 60];
            [durTimeLabel setText:duration];
            [HUD hide:YES];
            [progressSlider setMinimumValue:0.0f];
            [progressSlider setMaximumValue:player.duration];
            [progressSlider setValue:0.0f];
            songIndex = (int)sender.tag;
        });
    });
}

#pragma mark play audio
- (IBAction)onClickPlayButton:(id)sender
{
    if (songIndex >= 0) {
        isPlaying = !isPlaying;
        if (isPlaying) {
            [player prepareToPlay];
            [player play];
            [playButton setBackgroundImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateNormal];
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        } else {
            [player pause];
            [playButton setBackgroundImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
            [timer invalidate];
            timer = nil;
        }
    }
}

#pragma mark stop audio
- (IBAction)onClickStopButton:(id)sender
{
    if (isPlaying && songIndex >= 0) {
        isPlaying = NO;
        [player stop];
        player.currentTime = 0;
        [playButton setBackgroundImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
        [timer invalidate];
        [progressSlider setValue:0.0f];
        NSString *duration =[ NSString stringWithFormat:@"0:00 / %i:%02i", (int)player.duration / 60, (int) player.duration % 60];
        [durTimeLabel setText:duration];
    }
}

- (void)updateProgress
{
    [progressSlider setValue:player.currentTime];
    [durTimeLabel setText:[NSString stringWithFormat:@"%i:%02i / %i:%02i",(int)player.currentTime/60, (int)player.currentTime %60,  (int)player.duration / 60, (int) player.duration % 60]];
}

#pragma mark avaudio delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self onClickStopButton:nil];
}


- (void)onClickUser:(UIButton*)sender
{
    int rowIndex = (int)sender.tag;
    PFUser *obj = [searchList objectAtIndex:rowIndex];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    viewController.userObject = obj;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onClickMeButton:(UIButton*)sender
{
    int rowIndex = (int)sender.tag;
    PFObject *obj = [searchList objectAtIndex:rowIndex];
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
    PFObject *obj = [searchList objectAtIndex:rowIndex];
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
    PFObject *obj = [searchList objectAtIndex:rowIndex];
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
    PFObject *obj = [searchList objectAtIndex:sender.tag];
    NSMutableArray *likesArray = [obj objectForKey:@"likes"];
    if ([sender.titleLabel.text isEqualToString:@" Liked"]) {
        for (int i = 0; i < [likesArray count]; i++) {
            NSMutableDictionary *dic = [likesArray objectAtIndex:i];
            NSString *objectID = [dic objectForKey:@"likerID"];
            if ([objectID isEqualToString:[[DataManager getInstance].currentUser objectId]]) {
                [likesArray removeObjectAtIndex:i];
                break;
            }
        }
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[DataManager getInstance].currentUser username],@"likerName", [[DataManager getInstance].currentUser objectId], @"likerID", nil];
        [likesArray addObject:dic];
    }
    [obj setObject:likesArray forKey:@"likes"];
    [searchList removeObjectAtIndex:sender.tag];
    [searchList insertObject:obj atIndex:sender.tag];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [searchTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [obj saveInBackground];
}

- (void)onClickAddComment:(UIButton*)sender
{
    selectedIndex = (int) sender.tag;
    showAddCommentViewFlag = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AddCommentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"AddComment"];
    viewController.object = [searchList objectAtIndex:sender.tag];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)onClickFollowButton:(UIButton*)sender
{
    PFUser *userObj = [searchList objectAtIndex:sender.tag];
    
    if ([followingList containsObject:[userObj objectId]]) {
        [followingList removeObject:[userObj objectId]];
        [sender setImage:[UIImage imageNamed:@"follow_button"] forState:UIControlStateNormal];
        following_string = [following_string stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:", [userObj objectId]] withString:@""];
    } else {
        [followingList addObject:[userObj objectId]];
        [sender setImage:[UIImage imageNamed:@"followed_button"] forState:UIControlStateNormal];
        following_string = [NSString stringWithFormat:@"%@%@:", following_string, [userObj objectId]];
    }
    
    [[DataManager getInstance].currentUser setObject:followingList forKey:@"following"];
    [[DataManager getInstance].currentUser setObject:following_string forKey:@"following_string"];
    [[DataManager getInstance].currentUser saveInBackground];
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

#pragma mark force to show the refresh headerView
-(void)showRefreshHeader:(BOOL)animated{
	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		searchTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        // scroll the table view to the top region
        [searchTableView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
        [UIView commitAnimations];
	} else {
        searchTableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[searchTableView scrollRectToVisible:CGRectMake(0, 0.0f, 1, 1) animated:NO];
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
	[searchTableView addSubview:refreshHeaderView];
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
    CGFloat height = MAX(searchTableView.contentSize.height, searchTableView.frame.size.height);
    if (refreshFooterView && [refreshFooterView superview]) {
        // reset position
        refreshFooterView.frame = CGRectMake(0.0f, height, searchTableView.frame.size.width, searchTableView.bounds.size.height);
    }else {
        // create the footerView
        refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame: CGRectMake(0.0f, height, searchTableView.frame.size.width, self.view.bounds.size.height)];
        refreshFooterView.delegate = self;
        [searchTableView addSubview:refreshFooterView];
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

-(void)getSearchList: (BOOL)positionFlag
{
    if (searchBar.selectedScopeButtonIndex == 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *temp = searchString;
            [NSThread sleepForTimeInterval:2];
            if ([temp isEqualToString:searchString]) {
                PFQuery *query = [PFQuery queryWithClassName:@"_User"];
                [query whereKey:@"username" containsString:searchString];
                if (positionFlag) {
                    [query setLimit:30];
                } else {
                    [query setLimit: [searchList count] + 30];
                }
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    reloading = NO;
                    if ([temp isEqualToString:searchString]) {
                        if (!error) {
                            searchList = [NSMutableArray arrayWithArray:objects];
                            if (refreshHeaderView) {
                                [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
                                [searchTableView reloadData];
                            }
                            if (refreshFooterView) {
                                [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:reloadIndex inSection:0];
                                [searchTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                            }
                            [self setFooterView];
                        } else {
                            if (refreshHeaderView) {
                                [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
                            }
                            if (refreshFooterView) {
                                [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
                            }
                        }
                    }
                }];
            }
        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *temp = searchString;
            [NSThread sleepForTimeInterval:2];
            if ([temp isEqualToString:searchString]) {
                PFQuery *query = [PFQuery queryWithClassName:@"Post"];
                [query whereKey:@"tags" containsString:searchString];
                if (positionFlag) {
                    [query setLimit:30];
                } else {
                    [query setLimit: [searchList count] + 30];
                }
                [progressView setProgress:0.25f];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    reloading = NO;
                    if ([temp isEqualToString:searchString]) {
                        if (!error) {
                            searchList = [NSMutableArray arrayWithArray:objects];
                            if (refreshHeaderView) {
                                [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
                                [searchTableView reloadData];
                            }
                            if (refreshFooterView) {
                                [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:reloadIndex inSection:0];
                                [searchTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                            }
                            [self setFooterView];
                        } else {
                            if (refreshHeaderView) {
                                [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
                            }
                            if (refreshFooterView) {
                                [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
                            }
                        }
                    }
                }];
            }
        });
    }
}

#pragma mark data reloading methods that must be overide by the subclass
-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
	
	//  should be calling your tableviews data source model to reload
    if ([searchString length] == 0 || !searchString ) {
        if (refreshHeaderView) {
            [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
        }
        if (refreshFooterView) {
            [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:searchTableView];
        }
        return;
    }
    reloading = YES;
    if (aRefreshPos == EGORefreshHeader) {
        [self getSearchList:YES];
    }else if(aRefreshPos == EGORefreshFooter){
        [self getSearchList:NO];
    }
}

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([searchString length] == 0 || !searchString ) {
        return;
    }
	if (refreshHeaderView) {
        [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
	if (refreshFooterView) {
        [refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([searchString length] == 0 || !searchString ) {
        return;
    }
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
