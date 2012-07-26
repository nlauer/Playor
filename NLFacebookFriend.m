//
//  NLFacebookFriend.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFacebookFriend.h"

@implementation NLFacebookFriend

@synthesize name = _name, ID = _ID, profilePictureURL = _profilePictureURL;

- (id)initWithID:(NSNumber *)ID name:(NSString *)name andPicture:(NSURL *)picture
{
    self = [super init];
    if (self) {
        self.ID = ID;
        self.name = name;
        self.profilePictureURL = picture;
    }
    
    return self;
}

#pragma mark -
#pragma mark PlaylistItemDelegate
- (NSURL *)getPictureURL
{
    return self.profilePictureURL;
}

@end
