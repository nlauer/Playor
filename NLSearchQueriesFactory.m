//
//  NLSongNamesFactory.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLSearchQueriesFactory.h"

#import "NLURLConnectionManager.h"
#import "NSObject+SBJSON.h"

#define ITUNES_SEARCH_QUERY @"http://itunes.apple.com/search?term=%@&limit=4&media=music"

@implementation NLSearchQueriesFactory {
    int numberOfActiveConnections_;
}
@synthesize searchQueriesArray = _searchQueriesArray, searchQueriesFactoryDelegate = _searchQueriesFactoryDelegate, activeConnections = _activeConnections;

static NLSearchQueriesFactory *sharedInstance = NULL;

+ (NLSearchQueriesFactory *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == NULL) {
            sharedInstance = [[NLSearchQueriesFactory alloc] init];
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

- (void)createSongsArrayForArtists:(NSArray *)artists andDelegate:(id)delegate
{
    [self clearActiveConnections];
    
    self.searchQueriesFactoryDelegate = delegate;
    self.searchQueriesArray = [[NSMutableArray alloc] init];
    numberOfActiveConnections_ = 0;
    for (NSString *artist in artists) {
        NSURL *searchURL = [NSURL URLWithString:[[NSString stringWithFormat:ITUNES_SEARCH_QUERY, artist] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:searchURL];
        
        NLURLConnectionManager *manager = [[NLURLConnectionManager alloc] initWithDelegate:self];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:manager];
        if (!connection) {
            NSLog(@"couldnt create connection");
        } else {
            [_activeConnections addObject:connection];
            numberOfActiveConnections_++;
        }
    }
    [self sendSearchQueries];
}

- (void)sendSearchQueries
{
    if (numberOfActiveConnections_ == 0) {
        [_searchQueriesFactoryDelegate receiveSearchQueries:_searchQueriesArray];
        _searchQueriesArray = nil;
    }
}

#pragma mark -
#pragma mark URLConnectionManagerDelegate
- (void)receiveFinishedData:(NSData *)data fromConnection:(NSURLConnection *)connection
{
    numberOfActiveConnections_--;
    [_activeConnections removeObject:connection];
    
    NSDictionary *dataDictionary = [data JSONValue];
    for (NSDictionary *results in [dataDictionary objectForKey:@"results"]) {
        NSString *trackName = [results objectForKey:@"trackName"];
        NSString *artistName = [results objectForKey:@"artistName"];
        NSString *youtubeSearchQuery = [NSString stringWithFormat:@"%@ %@", trackName, artistName];
        [_searchQueriesArray addObject:youtubeSearchQuery];
    }
    [self sendSearchQueries];
}

@end
