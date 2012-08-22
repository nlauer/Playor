//
//  NLPlaylistBarViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"

#import "iCarousel.h"
#import "NLYoutubeLinksFromFBLikesFactory.h"
#import "NLAppDelegate.h"
@class NLFacebookFriend, NLYoutubeVideo, NLPlaylist;

@protocol PlaylistItemDelegate <NSObject>
- (NSURL *)getPictureURL;
@end

@interface NLPlaylistBarViewController : NLViewController <iCarouselDelegate, iCarouselDataSource, YoutubeLinksFromFBLikesDelegate, VideoPlayerDelegate>

+ (NLPlaylistBarViewController *)sharedInstance;

- (void)receiveFacebookFriend:(NLFacebookFriend *)facebookFriend;
- (void)receiveYoutubeVideo:(NLYoutubeVideo *)video;
- (void)updatePlaylist:(NLPlaylist *)playlist;

@end
