//
//  NLFriendsDetailViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"
#import "NLFacebookFriend.h"
#import "NLYoutubeLinksFactory.h"
#import "NLYoutubeLinksFromFBLikesFactory.h"
#import "iCarousel.h"

@interface NLFriendsDetailViewController : NLViewController <YoutubeLinksDelegate, YoutubeLinksFromFBLikesDelegate, UITableViewDelegate, UITableViewDataSource>

- (id)initWithFacebookFriend:(NLFacebookFriend *)facebookFriend;

@end
