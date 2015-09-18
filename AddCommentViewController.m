//
//  AddCommentViewController.m
//  InstaSong
//
//  Created by betcoin on 1/13/15.
//  Copyright (c) 2015 com.liang.instasong. All rights reserved.
//

#import "DataManager.h"
#import "AddCommentViewController.h"

@implementation AddCommentViewController
@synthesize commentTableView;
@synthesize object;
@synthesize inputView;
@synthesize commentTextView;

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
    commentArray = [object objectForKey:@"comments"];
    [commentTableView setBackgroundColor:[UIColor clearColor]];
    
    CALayer * l = [commentTextView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:3];
    
    [self registerForKeyboardNotifications];
    [commentTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark keyboard notification

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardWillShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)UIKeyboardWillShowNotification:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardRect = [keyboardFrameBegin CGRectValue];
    [inputView setFrame:CGRectMake(0, keyboardRect.origin.y - inputView.frame.size.height, self.view.frame.size.width, 40)];
    [commentTableView setFrame:CGRectMake(0, 55, commentTableView.frame.size.width, self.view.frame.size.height - 55 - keyboardRect.size.height - inputView.frame.size.height)];
}

#pragma mark onClickBackButton
- (IBAction)onClickBackButton:(id)sender
{
    [DataManager getInstance].postObject = object;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark onClickSendButton
- (IBAction)onClickSendButton:(id)sender
{
    if ([commentTextView.text length] == 0) {
        return;
    }
    [self addComment:commentTextView.text];
    [commentTextView setText:@""];
    [inputView setFrame:CGRectMake(0, keyboardRect.origin.y - 40, self.view.frame.size.width, 40)];
}

- (void)addComment:(NSString*)comment
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[[DataManager getInstance].currentUser username] forKey:@"commenterName"];
    [dic setObject:[[DataManager getInstance].currentUser objectId] forKey:@"commentID"];
    [dic setObject:comment forKey:@"comment"];
    
    PFFile *profileFile = [[DataManager getInstance].currentUser objectForKey:@"profile_image"];
    UIImage *profileImage = [UIImage imageWithData:[profileFile getData]];
    profileImage = [self imageWithImage:profileImage scaledToSize:CGSizeMake(50, 50)];
    NSData *data = UIImageJPEGRepresentation(profileImage, 1.0f);
    [dic setObject:data forKey:@"profileData"];
    if (commentArray == nil) {
        commentArray = [NSMutableArray array];
    }
    [commentArray addObject:dic];
    [object setObject:commentArray forKey:@"comments"];
    [object saveInBackground];  
    [commentTableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[commentArray count] - 1 inSection:0];
    [commentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of sections.
    return [commentArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int offsetY = 25;
    NSMutableDictionary *dic = [commentArray objectAtIndex:indexPath.row];
    NSString *comment = [dic objectForKey:@"comment"];
    int height = [self findHeightForText:comment havingWidth:tableView.frame.size.width - 76 andFont:[UIFont systemFontOfSize:15.0f]] + 13;
    if (offsetY + height + 5 < 65) {
        return 67;
    }
    return offsetY + height + 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    NSMutableDictionary *dic = [commentArray objectAtIndex:indexPath.row];
    NSData *profileData = [dic objectForKey:@"profileData"];
    UIImage *profileImage = [UIImage imageWithData:profileData];
    UIImageView *profileImageView = (UIImageView*)[cell viewWithTag:1];
    CALayer * l = [profileImageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:profileImageView.frame.size.width / 2];
    [profileImageView setImage:profileImage];
    
    UIButton *commenterButton = (UIButton*)[cell viewWithTag:2];
    [commenterButton setTitle:[dic objectForKey:@"commenterName"] forState:UIControlStateNormal];
    [commenterButton setTag:indexPath.row];
    [commenterButton addTarget:self action:@selector(onClickCommenterButton:) forControlEvents:UIControlEventTouchUpInside];
    
    int height = [self findHeightForText:[dic objectForKey:@"comment"] havingWidth:tableView.frame.size.width - 76 andFont:[UIFont systemFontOfSize:15.0f]];
    UILabel *commentLabel = (UILabel*)[cell viewWithTag:4];
    [commentLabel setFrame:CGRectMake(65, 25, tableView.frame.size.width - 75, height + 13)];
    [commentLabel setText:[dic objectForKey:@"comment"]];
    [commentLabel setNumberOfLines:0];
    [cell addSubview:commentLabel];
    return cell;
}

- (void)onClickCommenterButton:(UIButton*)sender
{
    
}

#pragma mark uitextview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([textView.text length] == 0) {
            return NO;
        }
        [self addComment:textView.text];
        [textView setText:@""];
        [inputView setFrame:CGRectMake(0, keyboardRect.origin.y - 40, self.view.frame.size.width, 40)];
        return NO;
    } else {
        int height = [self findHeightForText:textView.text havingWidth:textView.frame.size.width andFont:[UIFont systemFontOfSize:15.0f]];
        int lineNumber = height / textView.font.lineHeight + 1;
        [inputView setFrame:CGRectMake(0, keyboardRect.origin.y - lineNumber * 20 - 20, keyboardRect.size.width, lineNumber * 20 + 20)];
    }
    return YES;
}

#pragma mark calculate the height of tex
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

#pragma mark scale uiimage
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
