//
//  NLFacebookFriendFactory.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFacebookFriendFactory.h"
#import "NLFacebookFriend.h"

@implementation NLFacebookFriendFactory
@synthesize facebookFriendDelegate = _facebookFriendDelegate, friendsArray = _friendsArray;

static NLFacebookFriendFactory *sharedInstance = NULL;

+ (NLFacebookFriendFactory *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == NULL) {
            sharedInstance = [[NLFacebookFriendFactory alloc] init];
        }
    }
    
    return sharedInstance;
}

- (void)createFacebookFriendsWithDelegate:(id)delegate
{
    _friendsArray = [[NSMutableArray alloc] init];
    self.facebookFriendDelegate = delegate;
    [[[NLFacebookManager sharedInstance] facebook] requestWithGraphPath:@"/me/friends?fields=name,picture,id" andDelegate:self];
}

#pragma mark -
#pragma mark FBRequestDelegate
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"FB Request failed:%@", error);
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSDictionary *items = [(NSDictionary *)result objectForKey:@"data"];
    for (NSDictionary *friend in items) {
        NSNumber *fbid = [friend objectForKey:@"id"];
        NSString *name = [friend objectForKey:@"name"];
        NSString *pictureURL = [[[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"_q.jpg" withString:@"_o.jpg"];
        
        NLFacebookFriend *facebookFriend = [[NLFacebookFriend alloc] initWithID:fbid name:name andPicture:[NSURL URLWithString:pictureURL]];
        [_friendsArray addObject:facebookFriend];
    }
    [_facebookFriendDelegate receiveFacebookFriends:_friendsArray];
}

@end
