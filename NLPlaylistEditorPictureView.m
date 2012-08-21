//
//  NLPlaylistEditorPictureView.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPlaylistEditorPictureView.h"

#import "FXImageView.h"
#import "NLYoutubeVideo.h"

@implementation NLPlaylistEditorPictureView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        for (int i = 0; i < 6; i++) {
            int stepSize = self.frame.size.width/5;
            FXImageView *thumbnailImageView = [[FXImageView alloc] initWithFrame:CGRectMake(i*stepSize, 0, stepSize, self.frame.size.height)];
            [thumbnailImageView setBackgroundColor:[UIColor grayColor]];
            [thumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
            [thumbnailImageView setTag:i+1];
            [thumbnailImageView setAsynchronous:YES];
            
            [self addSubview:thumbnailImageView];
        }
    }
    return self;
}

- (void)updatePlaylistVideos:(NSArray *)playlistVideos
{
    for (int i = 0; i < 5; i++) {
        FXImageView *thumbnailImageView = (FXImageView *)[self viewWithTag:i+1];
        if (i < [playlistVideos count]) {
            NLYoutubeVideo *video = [playlistVideos objectAtIndex:i];
            [thumbnailImageView setImageWithContentsOfURL:[video thumbnailURL]];
        } else {
            [thumbnailImageView setImage:nil];
        }
    }
}

@end
