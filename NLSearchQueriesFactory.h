//
//  NLSongNamesFactory.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NLURLConnectionManager.h"

@protocol SearchQueriesFactoryDelegate <NSObject>
- (void)receiveSearchQueries:(NSArray *)searchQueries;
@end

@interface NLSearchQueriesFactory : NSObject <URLConnectionManagerDelegate>

@property (weak, nonatomic) id <SearchQueriesFactoryDelegate> searchQueriesFactoryDelegate;
@property (strong, nonatomic) NSMutableArray *searchQueriesArray;
@property (strong, nonatomic) NSMutableArray *activeConnections;

+ (NLSearchQueriesFactory *)sharedInstance;
- (void)createSongsArrayForArtists:(NSArray *)artists andDelegate:(id)delegate;

@end
