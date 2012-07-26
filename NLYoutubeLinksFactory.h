//
//  NLYoutubeLinksFactory.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLFacebookManager.h"
#import "NLURLConnectionManager.h"

@protocol YoutubeLinksDelegate <NSObject>
- (void)receiveYoutubeLinks:(NSArray *)links;
@end

@interface NLYoutubeLinksFactory : NSObject <FBRequestDelegate, URLConnectionManagerDelegate>

@property (weak, nonatomic) id <YoutubeLinksDelegate> youtubeLinksDelegate;
@property (strong, nonatomic) NSMutableArray *youtubeLinksArray;

+ (NLYoutubeLinksFactory *)sharedInstance;

- (void)createYoutubeLinksForFriendID:(NSNumber *)friendID andDelegate:(id)delegate;

@end
