//
//  Global.h
//  PartyU
//
//  Created by zongda liang on 12/14/14.
//  Copyright (c) 2014 com.liang. All rights reserved.
//
#import "DataManager.h"
static DataManager *sharedInstance = nil;

@implementation DataManager
@synthesize currentUser;
@synthesize postObject;
@synthesize savedFlag;
@synthesize recordingSoundUrl;
@synthesize groupPostTitile;
@synthesize groupPostSoundUrl;
@synthesize groupPostDescription;
@synthesize groupPostTags;
@synthesize groupPostFileName;
@synthesize groupPostFlag;

+(DataManager*)getInstance{
    if (sharedInstance == nil)
	{
		sharedInstance = [[DataManager alloc] init];
	}
	return sharedInstance;
}

-(id)init
{
    if((self = [super init]))
	{
        savedFlag = NO;
    }
	return self;
}

@end