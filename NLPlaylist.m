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
@synthesize name = _name, videos = _videos, isContinuous = _isContinuous, isShuffle = _isShuffle;

- (id)init
{
    self = [super init];
    if (self) {
        self.videos = [[NSMutableArray alloc] init];
        self.name = @"Default Playlist";
    }
    
    return self;
}

- (void)setIsShuffle:(BOOL)isShuffle
{
    _isShuffle = isShuffle;
    if (isShuffle) {
        [_videos shuffle];
    } else {
        _videos = [NSMutableArray arrayWithArray:[_videos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"addedDate" ascending:YES]]]];
    }
}

- (BOOL)isShuffle
{
    return _isShuffle;
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _videos = [decoder decodeObjectForKey:@"videos"];
        _name = [decoder decodeObjectForKey:@"name"];
        _isContinuous = [decoder decodeBoolForKey:@"continuous"];
        _isShuffle = [decoder decodeBoolForKey:@"shuffle"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_videos forKey:@"videos"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeBool:_isContinuous forKey:@"continuous"];
    [encoder encodeBool:_isShuffle forKey:@"shuffle"];
}

@end
