//
//  NSArray+Videos.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSArray+Videos.h"
#import "NLYoutubeVideo.h"

@implementation NSArray (Videos)

- (BOOL)containsVideo:(NLYoutubeVideo *)video
{
    BOOL containsVideo = NO;
    for (NLYoutubeVideo *addedVideo in self) {
        if ([[addedVideo.videoURL absoluteString] isEqualToString:[video.videoURL absoluteString]]) {
            containsVideo = YES;
        }
    }
    return containsVideo;
}

- (NSUInteger)indexOfVideo:(NLYoutubeVideo *)video
{
    NSUInteger index = NSNotFound;
    for (int i = 0; i < [self count]; i++) {
        NLYoutubeVideo *addedVideo = [self objectAtIndex:i];
        if ([[addedVideo.videoURL absoluteString] isEqualToString:[video.videoURL absoluteString]]) {
            index = i;
        }
    }
    
    return index;
}

@end
