//
//  NLFriendsDetailViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeResultsViewController.h"
#import "NLYoutubeLinksFactory.h"
#import "NLYoutubeLinksFromFBLikesFactory.h"

@class NLFacebookFriend;

@interface NLFriendsDetailViewController : NLYoutubeResultsViewController <YoutubeLinksDelegate, YoutubeLinksFromFBLikesDelegate>

- (id)initWithFacebookFriend:(NLFacebookFriend *)facebookFriend;

@end
