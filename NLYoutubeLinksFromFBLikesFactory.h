//
//  NLYoutubeLinksFromFBLikesFactory.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLFacebookManager.h"

@protocol YoutubeLinksFromFBLikesDelegate <NSObject>
- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links;
@end

@interface NLYoutubeLinksFromFBLikesFactory : NSObject <FBRequestDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) id <YoutubeLinksFromFBLikesDelegate> youtubeLinksFromFBLikesDelegate;
@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) NSMutableArray *youtubeLinksArray;

+ (NLYoutubeLinksFromFBLikesFactory *)sharedInstance;

- (void)createYoutubeLinksForFriendID:(NSNumber *)friendID andDelegate:(id)delegate;

@end
