//
//  NLYoutubeLinksFromFBLikesFactory.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLFacebookManager.h"
#import "NLURLConnectionManager.h"
#import "NLSearchQueriesFactory.h"

@protocol YoutubeLinksFromFBLikesDelegate <NSObject>
- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links;
@end

@interface NLYoutubeLinksFromFBLikesFactory : NSObject <FBRequestDelegate, URLConnectionManagerDelegate, SearchQueriesFactoryDelegate>

@property (weak, nonatomic) id <YoutubeLinksFromFBLikesDelegate> youtubeLinksFromFBLikesDelegate;
@property (strong, nonatomic) NSMutableArray *youtubeLinksArray;
@property (strong, nonatomic) NSMutableArray *activeConnections;

+ (NLYoutubeLinksFromFBLikesFactory *)sharedInstance;

- (void)createYoutubeLinksForFriendID:(NSNumber *)friendID andDelegate:(id)delegate;
- (void)createYoutubeLinksForSearchQuery:(NSString *)searchQuery batchSize:(int)size startIndex:(int)index andDelegate:(id)delegate;
- (void)createYoutubeLinksForMostPopularVideos:(id)delegate;

@end
