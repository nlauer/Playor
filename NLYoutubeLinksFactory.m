//
//  NLYoutubeLinksFactory.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeLinksFactory.h"
#import "NLYoutubeVideo.h"
#import "NSObject+SBJSON.h"

@implementation NLYoutubeLinksFactory {
    int numberOfActiveConnections_;
}
@synthesize youtubeLinksDelegate = _youtubeLinksDelegate, youtubeLinksArray = _youtubeLinksArray;

static NLYoutubeLinksFactory *sharedInstance = NULL;

+ (NLYoutubeLinksFactory *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == NULL) {
            sharedInstance = [[NLYoutubeLinksFactory alloc] init];
        }
    }
    
    return sharedInstance;
}

- (void)createYoutubeLinksForFriendID:(NSNumber *)friendID andDelegate:(id)delegate
{
    if (numberOfActiveConnections_ != 0) {
        sharedInstance = [[NLYoutubeLinksFactory alloc] init];
    }
    self.youtubeLinksDelegate = delegate;
    numberOfActiveConnections_ = 0;
    _youtubeLinksArray = [[NSMutableArray alloc] init];
    NSString *graphPath = [NSString stringWithFormat:@"%@/links?limit=15", friendID];
    [[[NLFacebookManager sharedInstance] facebook] requestWithGraphPath:graphPath andDelegate:self];
}

- (NSString*)getVideoIdFromYoutubeLink:(NSString*)link
{
    NSString *stringStartingWithVideoID = [[link componentsSeparatedByString:@"v="] objectAtIndex:1];
    NSString *videoID = [[stringStartingWithVideoID componentsSeparatedByString:@"&"] objectAtIndex:0];
    return videoID;
}

#pragma mark -
#pragma mark FBRequestDelegate
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"youtube links factory fail:%@", error);
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSDictionary *items = [(NSDictionary *)result objectForKey:@"data"];
    for (NSDictionary *friend in items) {
        NSString *link = [friend objectForKey:@"link"];
        if ([link rangeOfString:@"www.youtube.com/watch?v="].length > 0) {
            NSString *videoID = [self getVideoIdFromYoutubeLink:link];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=json", videoID]]];
            NLURLConnectionManager *manager = [[NLURLConnectionManager alloc] initWithDelegate:self];
            NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:manager];
            if (!connection) {
                NSLog(@"couldnt create connection");
            } else {
                numberOfActiveConnections_++;
            }
        }
    }
    [self sendYoutubeLinks];
}

- (void)sendYoutubeLinks
{
    if (numberOfActiveConnections_ == 0) {
        [_youtubeLinksDelegate receiveYoutubeLinks:_youtubeLinksArray];
    }
}

#pragma mark -
#pragma mark URLConnectionManagerDelegate
- (void)receiveFinishedData:(NSData *)data
{
    NSDictionary *dataDictionary = [[data JSONValue] objectForKey:@"entry"];
    if (dataDictionary) {
        if ([NLYoutubeVideo isMusicLinkForDataDictionary:dataDictionary]) {
            NLYoutubeVideo *youtubeVideo = [[NLYoutubeVideo alloc] initWithDataDictionary:dataDictionary];
            if (youtubeVideo) {
                [_youtubeLinksArray addObject:youtubeVideo];
            }
        }
    } else {
        NSLog(@"failed to create data dictionary:%@ for YoutubeLinksFactory", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
    
    numberOfActiveConnections_--;
    [self sendYoutubeLinks];
}

@end
