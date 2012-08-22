//
//  NLVideoLoadingView.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLVideoLoadingView.h"

#import "NLYoutubeVideo.h"

@implementation NLVideoLoadingView

- (id)initWithFrame:(CGRect)frame andDelegate:(id)loadingViewDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.5]];
        
        UIButton *stopButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [stopButton setBackgroundColor:[UIColor blackColor]];
        [stopButton addTarget:loadingViewDelegate action:@selector(stopLoadingVideo) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:stopButton];
    }
    return self;
}

- (void)updateLoadingViewForVideo:(NLYoutubeVideo *)video
{
    
}

@end
