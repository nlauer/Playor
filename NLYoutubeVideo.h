//
//  NLYoutubeVideo.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLPlaylistBarViewController.h"

@interface NLYoutubeVideo : NSObject <PlaylistItemDelegate, NSCoding>

@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic) NSString *title;

+ (BOOL)isMusicLinkForDataDictionary:(NSDictionary *)dataDictonary;
- (id)initWithDataDictionary:(NSDictionary *)dataDictionary;

@end
