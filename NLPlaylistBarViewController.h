//
//  NLPlaylistBarViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"

#import "iCarousel.h"
@class NLFacebookFriend, NLYoutubeVideo;

@protocol PlaylistItemDelegate <NSObject>
- (NSURL *)getPictureURL;
@end

@interface NLPlaylistBarViewController : NLViewController <iCarouselDelegate, iCarouselDataSource>

+ (NLPlaylistBarViewController *)sharedInstance;

- (void)receiveFacebookFriend:(NLFacebookFriend *)facebookFriend;
- (void)receiveYoutubeVideo:(NLYoutubeVideo *)video;

@end
