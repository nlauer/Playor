//
//  NLPlaylistManager.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPlaylistManager.h"

#import "NLPlaylist.h"

@implementation NLPlaylistManager
@synthesize playlists = _playlists;

static NLPlaylistManager *sharedInstance = NULL;

+ (NLPlaylistManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == NULL) {
            sharedInstance = [[NLPlaylistManager alloc] init];
        }
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadPlaylistsFromFile];
    }
    
    return self;
}

- (NSString *)playlistsSaveFilePath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    return [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"playlists.plist"]];
}

- (void)loadPlaylistsFromFile
{
    _playlists = [[NSMutableArray alloc] initWithContentsOfFile:[self playlistsSaveFilePath]];
}

- (void)savePlaylistsToFile
{
    [_playlists writeToFile:[self playlistsSaveFilePath] atomically:YES];
}

- (void)addPlaylist:(NLPlaylist *)playlist
{
    [_playlists addObject:playlist];
    [self savePlaylistsToFile];
}

- (void)removePlaylist:(NLPlaylist *)playlist
{
    [_playlists removeObject:playlist];
    [self savePlaylistsToFile];
}

@end
