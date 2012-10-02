//
//  NLPlaylistManager.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPlaylistManager.h"

#import "NLPlaylist.h"
#import "NLPlaylistBarViewController.h"

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
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self playlistsSaveFilePath]]) {
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:[self playlistsSaveFilePath]];
        _playlists = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        _playlists = [[NSMutableArray alloc] init];
    }
}

- (void)savePlaylistsToFile
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_playlists];
    [data writeToFile:[self playlistsSaveFilePath] atomically:YES];
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

- (NLPlaylist *)getCurrentPlaylist
{
    int currentPlaylistIndex;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"currentIndex"]) {
        currentPlaylistIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentIndex"];
    } else {
        currentPlaylistIndex = 0;
    }
    if (currentPlaylistIndex >= [_playlists count]) {
        NLPlaylist *playlist = [[NLPlaylist alloc] init];
        [_playlists addObject:playlist];
    }
    
    return [_playlists objectAtIndex:currentPlaylistIndex];
}

- (void)setCurrentPlaylist:(int)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"currentIndex"];
    [[NLPlaylistBarViewController sharedInstance] updatePlaylist:[_playlists objectAtIndex:index]];
}

@end
