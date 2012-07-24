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

@implementation NLYoutubeLinksFromFBLikesFactory {
    int numberOfActiveConnections_;
}
@synthesize youtubeLinksFromFBLikesDelegate = _youtubeLinksFromFBLikesDelegate, data = _data;
@synthesize youtubeLinksArray = _youtubeLinksArray;

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

- (void)createYoutubeLinksForFriendID:(NSNumber *)friendID andDelegate:(id)delegate
{
    self.youtubeLinksFromFBLikesDelegate = delegate;
    _data = [[NSMutableData alloc] init];
    _youtubeLinksArray = [[NSMutableArray alloc] init];
    numberOfActiveConnections_ = 0;
    NSString *graphPath = [NSString stringWithFormat:@"%@/music?limit=3", friendID];
    [[[NLFacebookManager sharedInstance] facebook] requestWithGraphPath:graphPath andDelegate:self];
}

- (void)sendYoutubeLinks
{
    if (numberOfActiveConnections_ == 0) {
        [_youtubeLinksFromFBLikesDelegate receiveYoutubeLinksFromFBLikes:_youtubeLinksArray];
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
    for (NSDictionary *musicLikes in items) {
        NSString *name = [[musicLikes objectForKey:@"name"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://gdata.youtube.com/feeds/api/videos?q=%@&orderby=relevance&max-results=3&v=2&alt=json&category=music&format=1", name]]];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        if (!connection) {
            NSLog(@"couldnt create connection");
        } else {
            numberOfActiveConnections_++;
        }
    }
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error requesting youtube data from facebook likes:%@", error);
    numberOfActiveConnections_--;
    [self sendYoutubeLinks];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *dataDictionary = [_data JSONValue];
    if (dataDictionary) {
        NSArray *entries = [[dataDictionary objectForKey:@"feed"] objectForKey:@"entry"];
        for (NSDictionary *feedEntry in entries) {
            NLYoutubeVideo *youtubeVideo = [[NLYoutubeVideo alloc] initWithDataDictionary:feedEntry];
            [_youtubeLinksArray addObject:youtubeVideo];
        }
    } else {
        NSLog(@"failed to create data dictionary for YoutubeLinksFromFBLikesFactory");
    }
    
    numberOfActiveConnections_--;
    [self sendYoutubeLinks];
    
    _data = nil;
    _data = [[NSMutableData alloc] init];
}

@end
