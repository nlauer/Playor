//
//  NLPlaylist.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPlaylist.h"

@implementation NLPlaylist
@synthesize name = _name, videos = _videos;

- (id)init
{
    self = [super init];
    if (self) {
        self.videos = [[NSMutableArray alloc] init];
        self.name = @"ALL SONGS";
    }
    
    return self;
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _videos = [decoder decodeObjectForKey:@"videos"];
        _name = [decoder decodeObjectForKey:@"name"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_videos forKey:@"videos"];
    [encoder encodeObject:_name forKey:@"name"];
}

@end
