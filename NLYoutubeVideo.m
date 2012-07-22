//
//  NLYoutubeVideo.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeVideo.h"

@implementation NLYoutubeVideo
@synthesize videoURL = _videoURL, title = _title;

- (id)initWithDataDictionary:(NSDictionary *)dataDictionary
{
    self = [super init];
    if (self) {
        self.title = [self getVideoTitleFromDictionary:dataDictionary];
        self.videoURL = [self getVideoURLFromDictionary:dataDictionary];
    }
    
    return self;
}

+ (BOOL)isMusicLinkForDataDictionary:(NSDictionary *)dataDictonary
{
    return [((NSString *)[[[[[dataDictonary objectForKey:@"entry"] objectForKey:@"media$group"] objectForKey:@"media$category"] objectAtIndex:0] objectForKey:@"label"]) isEqualToString:@"Music"];
}

- (NSString *)getVideoCategoryFromDictionary:(NSDictionary *)dataDictionary
{
    NSString *category = [[[[[dataDictionary objectForKey:@"entry"] objectForKey:@"media$group"] objectForKey:@"media$category"] objectAtIndex:0] objectForKey:@"label"];
    return category;
}

- (NSString *)getVideoTitleFromDictionary:(NSDictionary *)dataDictionary
{
    NSString *title = [[[[dataDictionary objectForKey:@"entry"] objectForKey:@"media$group"] objectForKey:@"media$title"] objectForKey:@"$t"];
    return title;
}

- (NSURL *)getVideoURLFromDictionary:(NSDictionary *)dataDictionary
{
    NSString *videoID = [[[[dataDictionary objectForKey:@"entry"] objectForKey:@"media$group"] objectForKey:@"yt$videoid"] objectForKey:@"$t"];
    NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@", videoID]];
    return videoURL;
}

@end
