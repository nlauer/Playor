//
//  NLFacebookFriendFactory.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLFacebookManager.h"

@protocol FacebookFriendDelegate <NSObject>
- (void)receiveFacebookFriends:(NSArray *)friends;
@end

@interface NLFacebookFriendFactory : NSObject <FBRequestDelegate>

@property (weak, nonatomic) id <FacebookFriendDelegate> facebookFriendDelegate;
@property (strong, nonatomic) NSMutableArray *friendsArray;

+ (NLFacebookFriendFactory *)sharedInstance;

- (void)createFacebookFriendsWithDelegate:(id)delegate;

@end
