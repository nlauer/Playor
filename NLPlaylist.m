//
//  NLPlaylist.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPlaylist.h"

#import "NSMutableArray+Shuffle.h"

@implementation NLPlaylist
@synthesize name = _name, videos = _videos, isContinuous = _isContinuous, isShuffled = _isShuffled;

- (id)init
{
    self = [super init];
    if (self) {
        self.videos = [[NSMutableArray alloc] init];
        self.name = @"Default Playlist";
    }
    
    return self;
}

- (void)shuffle
{
    [_videos shuffle];
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _videos = [decoder decodeObjectForKey:@"videos"];
        _name = [decoder decodeObjectForKey:@"name"];
        _isContinuous = [decoder decodeBoolForKey:@"continuous"];
        _isShuffled = [decoder decodeBoolForKey:@"shuffle"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_videos forKey:@"videos"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeBool:_isContinuous forKey:@"continuous"];
    [encoder encodeBool:_isShuffled forKey:@"shuffle"];
}

@end
