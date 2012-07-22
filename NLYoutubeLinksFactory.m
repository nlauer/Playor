//
//  NLYoutubeLinksFactory.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeLinksFactory.h"
#import "NLYoutubeVideo.h"

@implementation NLYoutubeLinksFactory {
    int numberOfActiveConnections_;
}
@synthesize youtubeLinksDelegate = _youtubeLinksDelegate, youtubeLinksArray = _youtubeLinksArray;
@synthesize data = _data;

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
    self.youtubeLinksDelegate = delegate;
    numberOfActiveConnections_ = 0;
    _data = [[NSMutableData alloc] init];
    _youtubeLinksArray = [[NSMutableArray alloc] init];
    NSString *graphPath = [NSString stringWithFormat:@"%@/links", friendID];
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
            [NSURLConnection connectionWithRequest:request delegate:self];
            numberOfActiveConnections_++;
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
#pragma mark NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *e;
    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingAllowFragments error:&e];
    if (dataDictionary) {
        if ([NLYoutubeVideo isMusicLinkForDataDictionary:dataDictionary]) {
            NLYoutubeVideo *youtubeVideo = [[NLYoutubeVideo alloc] initWithDataDictionary:dataDictionary];
            [_youtubeLinksArray addObject:youtubeVideo];
        }
    }
    
    numberOfActiveConnections_--;
    [self sendYoutubeLinks];
    
    _data = nil;
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    numberOfActiveConnections_--;
    [self sendYoutubeLinks];
    
    NSLog(@"error requesting youtube info:%@", error);
}

@end
