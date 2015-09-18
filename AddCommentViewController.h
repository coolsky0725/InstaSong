//
//  AddCommentViewController.h
//  InstaSong
//
//  Created by betcoin on 1/13/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddCommentViewController : UIViewController <UITableViewDataSource, UITableViewDataSource, UITextViewDelegate>
{
    CGRect               keyboardRect;
    NSMutableArray      *commentArray;
    NSMutableDictionary *descriptionDic;
}
@property (nonatomic, retain) IBOutlet UITableView *commentTableView;
@property (nonatomic, retain) PFObject *object;
@property (nonatomic, retain) IBOutlet UIView *inputView;
@property (nonatomic, retain) IBOutlet UITextView *commentTextView;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;


@end
