//
//  NLVideoInfoView.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLVideoInfoView.h"
#import "NLYoutubeVideo.h"

@implementation NLVideoInfoView

typedef enum {
    TITLE = 99,
    
} infoViews;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor darkGrayColor]];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 60)];
        [titleLabel setNumberOfLines:3];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTag:TITLE];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)updateViewWithVideo:(NLYoutubeVideo *)video
{
    UILabel *titleLabel = (UILabel *)[self viewWithTag:TITLE];
    [titleLabel setText:video.title];
    CGSize size = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - 20, 60) lineBreakMode:titleLabel.lineBreakMode];
    [titleLabel setFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, size.width, size.height)];
}

@end
