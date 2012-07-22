//
//  NLFriendsViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"
#import "iCarousel.h"
#import "NLFacebookFriendFactory.h"

@interface NLFriendsViewController : NLViewController <iCarouselDelegate, iCarouselDataSource, FacebookFriendDelegate>

@end
