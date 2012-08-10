//
//  NSArray+Videos.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NLYoutubeVideo;

@interface NSArray (Videos)

- (BOOL)containsVideo:(NLYoutubeVideo *)video;
- (NSUInteger)indexOfVideo:(NLYoutubeVideo *)video;

@end
