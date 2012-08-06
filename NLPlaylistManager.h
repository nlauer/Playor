//
//  NLPlaylistManager.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NLPlaylist;

@interface NLPlaylistManager : NSObject

@property (strong, nonatomic) NSMutableArray *playlists;

+ (NLPlaylistManager *)sharedInstance;

- (void)loadPlaylistsFromFile;
- (void)savePlaylistsToFile;
- (void)addPlaylist:(NLPlaylist *)playlist;
- (void)removePlaylist:(NLPlaylist *)playlist;
- (NLPlaylist *)getCurrentPlaylist;
- (void)setCurrentPlaylist:(int)index;

@end
