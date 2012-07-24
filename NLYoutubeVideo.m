//
//  NLYoutubeVideo.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeVideo.h"

@implementation NLYoutubeVideo
@synthesize videoURL = _videoURL, thumbnailURL = _thumbnailURL, title = _title;

- (id)initWithDataDictionary:(NSDictionary *)dataDictionary
{
    self = [super init];
    if (self) {
        self.title = [self getVideoTitleFromDictionary:dataDictionary];
        self.videoURL = [self getVideoURLFromDictionary:dataDictionary];
        self.thumbnailURL = [self getVideoThumnailURLFromDictionary:dataDictionary];
    }
    
    return self;
}

#pragma mark -
#pragma mark DataDictionary

+ (BOOL)isMusicLinkForDataDictionary:(NSDictionary *)dataDictonary
{
    return [((NSString *)[[[[dataDictonary objectForKey:@"media$group"] objectForKey:@"media$category"] objectAtIndex:0] objectForKey:@"label"]) isEqualToString:@"Music"];
}

- (NSString *)getVideoCategoryFromDictionary:(NSDictionary *)dataDictionary
{
    NSString *category = [[[[dataDictionary objectForKey:@"media$group"] objectForKey:@"media$category"] objectAtIndex:0] objectForKey:@"label"];
    return category;
}

- (NSString *)getVideoTitleFromDictionary:(NSDictionary *)dataDictionary
{
    NSString *title = [[[dataDictionary objectForKey:@"media$group"] objectForKey:@"media$title"] objectForKey:@"$t"];
    return title;
}

- (NSURL *)getVideoURLFromDictionary:(NSDictionary *)dataDictionary
{
    NSString *videoString = [[[dataDictionary objectForKey:@"media$group"] objectForKey:@"yt$videoid"] objectForKey:@"$t"];
    NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@", videoString]];
    return videoURL;
}

- (NSURL *)getVideoThumnailURLFromDictionary:(NSDictionary *)dataDictionary
{
    NSString *thumbnailString = [[[[dataDictionary objectForKey:@"media$group"] objectForKey:@"media$thumbnail"] objectAtIndex:1] objectForKey:@"url"];
    return [NSURL URLWithString:thumbnailString];
}
@end
