//
//  NLYoutubeLinksFromFBLikesFactory.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeLinksFromFBLikesFactory.h"

#import "NLYoutubeVideo.h"
#import "NSObject+SBJSON.h"
#import "NLSearchQueriesFactory.h"
#import "NSArray+Videos.h"

#define YOUTUBE_SEARCH_STRING @"https://gdata.youtube.com/feeds/api/videos?q=%@&max-results=1&v=2&alt=json&format=5,1"

@implementation NLYoutubeLinksFromFBLikesFactory {
    int numberOfActiveConnections_;
}
@synthesize youtubeLinksFromFBLikesDelegate = _youtubeLinksFromFBLikesDelegate;
@synthesize youtubeLinksArray = _youtubeLinksArray, activeConnections = _activeConnections;

static NLYoutubeLinksFromFBLikesFactory *sharedInstance = NULL;

+ (NLYoutubeLinksFromFBLikesFactory *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == NULL) {
            sharedInstance = [[NLYoutubeLinksFromFBLikesFactory alloc] init];
        }
    }
    
    return sharedInstance;
}

- (void)clearActiveConnections
{
    if ([_activeConnections count] > 0) {
        for (NSURLConnection *connection in _activeConnections) {
            [connection cancel];
        }
    }
}

- (void)createYoutubeLinksForFriendID:(NSNumber *)friendID andDelegate:(id)delegate
{
    [self clearActiveConnections];
    
    self.youtubeLinksFromFBLikesDelegate = delegate;
    _youtubeLinksArray = [[NSMutableArray alloc] init];
    _activeConnections = [[NSMutableArray alloc] init];
    numberOfActiveConnections_ = 0;
    NSString *graphPath = [NSString stringWithFormat:@"%@/music?limit=15", friendID];
    [[[NLFacebookManager sharedInstance] facebook] requestWithGraphPath:graphPath andDelegate:self];
}

- (void)sendYoutubeLinks
{
    if (numberOfActiveConnections_ == 0) {
        [_youtubeLinksFromFBLikesDelegate receiveYoutubeLinksFromFBLikes:_youtubeLinksArray];
        _youtubeLinksArray = nil;
    }
}

#pragma mark -
#pragma mark FBRequestDelegate
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Friends music likes failed with error:%@", error);
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSDictionary *items = [(NSDictionary *)result objectForKey:@"data"];
    NSMutableArray *artists = [[NSMutableArray alloc] init];
    for (NSDictionary *musicLikes in items) {
        NSString *name = [musicLikes objectForKey:@"name"];
        [artists addObject:name];
    }
    [[NLSearchQueriesFactory sharedInstance] createSongsArrayForArtists:artists andDelegate:self];
}

#pragma mark -
#pragma mark SearchQueriesFactoryDelegate
- (void)receiveSearchQueries:(NSArray *)searchQueries
{
    for (NSString *query in searchQueries) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[NSString stringWithFormat:YOUTUBE_SEARCH_STRING, query] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        NLURLConnectionManager *manager = [[NLURLConnectionManager alloc] initWithDelegate:self];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:manager];
        if (!connection) {
            NSLog(@"couldnt create connection");
        } else {
            [_activeConnections addObject:connection];
            numberOfActiveConnections_++;
        }
    }
    [self sendYoutubeLinks];
}

#pragma mark -
#pragma mark URLConnectionManagerDelegate
- (void)receiveFinishedData:(NSData *)data fromConnection:(NSURLConnection *)connection
{
    NSDictionary *dataDictionary = [data JSONValue];
    if (dataDictionary) {
        NSArray *entries = [[dataDictionary objectForKey:@"feed"] objectForKey:@"entry"];
        NSMutableArray *unsortedYoutubeLinks = [[NSMutableArray alloc] init];
        for (NSDictionary *feedEntry in entries) {
            NLYoutubeVideo *youtubeVideo = [[NLYoutubeVideo alloc] initWithDataDictionary:feedEntry];
            if (youtubeVideo) {
                [unsortedYoutubeLinks addObject:youtubeVideo];
            }
        }
        if ([unsortedYoutubeLinks count] != 0 && ![_youtubeLinksArray containsVideo:[unsortedYoutubeLinks objectAtIndex:0]]) {
            [_youtubeLinksArray addObject:[unsortedYoutubeLinks objectAtIndex:0]];
        }
    } else {
        NSLog(@"failed to create data dictionary:%@ for YoutubeLinksFromFBLikesFactory", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
    
    [_activeConnections removeObject:connection];
    numberOfActiveConnections_--;
    [self sendYoutubeLinks];
}

@end
