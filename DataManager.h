//
//  DataManager.h
//  PartyU
//
//  Created by zongda liang on 12/14/14.
//  Copyright (c) 2014 com.liang. All rights reserved.
//

// user info
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface DataManager : NSObject
{
    
}
@property (nonatomic, retain) PFUser    *currentUser;
@property (nonatomic, retain) PFObject  *postObject;
@property (nonatomic, assign) BOOL       savedFlag;
@property (nonatomic, retain) NSURL     *recordingSoundUrl;
@property (nonatomic, retain) NSString  *groupPostTitile;
@property (nonatomic, retain) NSURL     *groupPostSoundUrl;
@property (nonatomic, retain) NSString  *groupPostDescription;
@property (nonatomic, retain) NSString  *groupPostTags;
@property (nonatomic, retain) NSString  *groupPostFileName;
@property (nonatomic, assign) BOOL      groupPostFlag;
+ (DataManager*)getInstance;

@end