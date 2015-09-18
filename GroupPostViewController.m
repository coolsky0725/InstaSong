//
//  GroupPostViewController.m
//  InstaSong
//
//  Created by zongda liang on 1/21/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "GroupPostViewController.h"
#import "DataManager.h"

@implementation GroupPostViewController
@synthesize searchBar;
@synthesize searchTableView;
@synthesize progressView;
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
    [self createHeaderView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark search bar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
    [self.view endEditing:YES];
}

- (void)searchBar:(UISearchBar *)bar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    if ([bar.text length] == 0) {
        return;
    }
    [progressView setProgress:0.25f];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *temp = searchString;
        [NSThread sleepForTimeInterval:2];
        if ([temp isEqualToString:searchString]) {
            PFQuery *query = [PFQuery queryWithClassName:@"_User"];
            [query whereKey:@"username" containsString:bar.text];
            [query setLimit:30];
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
}

- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText
{
    if ([bar.text length] != 0 && ![searchString isEqualToString:bar.text]) {
        searchString = bar.text;
        [progressView setProgress:0.25f];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *temp = searchString;
            [NSThread sleepForTimeInterval:2];
            if ([temp isEqualToString:searchString]) {
                PFQuery *query = [PFQuery queryWithClassName:@"_User"];
                [query whereKey:@"username" containsString:bar.text];
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
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCell"];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    PFObject *userObject = [searchList objectAtIndex:indexPath.row];
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
    return cell;
}

#pragma mark onClickBackButton
- (IBAction)onClickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark onClickSendButton
- (IBAction)onClickSendButton:(id)sender
{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HUD setLabelText:@"sending..."];
    NSIndexPath *selectedIndexPath = [searchTableView indexPathForSelectedRow];
    if (!selectedIndexPath) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Please select the receiver!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
    
    PFObject *notificationObj = [PFObject objectWithClassName:@"Notification"];
    [notificationObj setObject:[[DataManager getInstance].currentUser objectId] forKey:@"sender_id"];
    [notificationObj setObject:[[DataManager getInstance].currentUser username] forKey:@"sender_name"];
    PFFile *profileImageFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
    [notificationObj setObject:profileImageFile forKey:@"sender_image"];
    
    PFUser *userObject = [searchList objectAtIndex:selectedIndexPath.row];
    [notificationObj setObject:[userObject objectId] forKey:@"receiver_id"];
    [notificationObj setObject:[userObject username] forKey:@"receiver_name"];
    PFFile *receiverprofileImageFile = [userObject objectForKey:@"profile_image"];
    [notificationObj setObject:receiverprofileImageFile forKey:@"receiver_image"];    
    
    NSString *path = [[DataManager getInstance].groupPostSoundUrl path];
    NSData *soundData = [[NSFileManager defaultManager] contentsAtPath:path];
    PFFile *soundFile = [PFFile fileWithName:[DataManager getInstance].groupPostFileName data:soundData];
    [notificationObj setObject:soundFile forKey:@"audio"];
    [notificationObj setObject:[DataManager getInstance].groupPostFileName forKey:@"filename"];
    
    [notificationObj setObject:[DataManager getInstance].groupPostTitile forKey:@"title"];
    [notificationObj setObject:[DataManager getInstance].groupPostDescription forKey:@"description"];
    [notificationObj setObject:[DataManager getInstance].groupPostTags forKey:@"tags"];
    [notificationObj setObject:[NSNumber numberWithInt:1] forKey:@"type"];
    [notificationObj setObject:[NSNumber numberWithInt:1] forKey:@"status"];
    [notificationObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [HUD hide:YES];
        if (!error) {
            [DataManager getInstance].groupPostFlag = YES;
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Success!" message:@"Notification sent successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Error!" message:@"Notification didn't send. please check your connection and send again!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

#pragma mark scale uiimage
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
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
}


#pragma mark data reloading methods that must be overide by the subclass

-(void)beginToReloadData:(EGORefreshPos)aRefreshPos{
	
	//  should be calling your tableviews data source model to reload
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
