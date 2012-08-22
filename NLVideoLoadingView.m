//
//  NLVideoLoadingView.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLVideoLoadingView.h"

#import "NLYoutubeVideo.h"
#import "UIColor+NLColors.h"
#import "FXImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NLVideoLoadingView {
    UIButton *dismissButton_;
    FXImageView *thumbnailImageView_;
    UILabel *titleLabel_;
    NSTimer *loadingTimer_;
}

@synthesize loadingViewDelegate = _loadingViewDelegate;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)loadingViewDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.loadingViewDelegate = loadingViewDelegate;
        [self setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.7]];
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, self.frame.size.width - 100, self.frame.size.height - 260)];
        [contentView setBackgroundColor:[UIColor baseViewBackgroundColor]];
        [contentView.layer setCornerRadius:6];
        [contentView setClipsToBounds:YES];
        [self addSubview:contentView];
        
        dismissButton_ = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [dismissButton_ setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"loading_close_btn"]]];
        [dismissButton_ addTarget:self action:@selector(dismissButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:dismissButton_];
        
        UILabel *loadingLabel = [[UILabel alloc] init];
        [loadingLabel setBackgroundColor:[UIColor clearColor]];
        [loadingLabel setTextColor:[UIColor whiteColor]];
        [loadingLabel setText:@"Loading..."];
        [loadingLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [loadingLabel sizeToFit];
        [loadingLabel setCenter:CGPointMake(contentView.frame.size.width/2 - 15, 12 + loadingLabel.frame.size.height/2)];
        [contentView addSubview:loadingLabel];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator startAnimating];
        [activityIndicator setCenter:CGPointMake(loadingLabel.frame.origin.x + loadingLabel.frame.size.width + 10 + activityIndicator.frame.size.width/2, loadingLabel.frame.origin.y + loadingLabel.frame.size.height/2)];
        [contentView addSubview:activityIndicator];
        
        thumbnailImageView_ = [[FXImageView alloc] initWithFrame:CGRectMake(10, dismissButton_.frame.origin.y + dismissButton_.frame.size.height, contentView.frame.size.width - 20, 100)];
        [thumbnailImageView_ setBackgroundColor:[UIColor grayColor]];
        [thumbnailImageView_ setContentMode:UIViewContentModeScaleAspectFill];
        [thumbnailImageView_ setAsynchronous:YES];
        [contentView addSubview:thumbnailImageView_];
        
        titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, thumbnailImageView_.frame.origin.y + thumbnailImageView_.frame.size.height + 10, contentView.frame.size.width - 20, 50)];
        [titleLabel_ setBackgroundColor:[UIColor clearColor]];
        [titleLabel_ setTextColor:[UIColor whiteColor]];
        [titleLabel_ setFont:[UIFont boldSystemFontOfSize:16]];
        [titleLabel_ setNumberOfLines:2];
        [titleLabel_ setLineBreakMode:UILineBreakModeWordWrap];
        [contentView addSubview:titleLabel_];
        
    }
    return self;
}

- (void)showInView:(UIView *)view withVideo:(NLYoutubeVideo *)video
{
    [self setAlpha:0.0];
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:1.0];
    }];
    
    if (loadingTimer_) {
        [loadingTimer_ invalidate];
        loadingTimer_ = nil;
    }
    loadingTimer_ = [[NSTimer alloc] initWithFireDate:[[NSDate date] dateByAddingTimeInterval:20] interval:0 target:self selector:@selector(videoLoadTimedOut) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:loadingTimer_ forMode:NSDefaultRunLoopMode];
    
    [dismissButton_ setUserInteractionEnabled:YES];
    [dismissButton_ setAlpha:1.0];
    
    [thumbnailImageView_ setImageWithContentsOfURL:[video thumbnailURL]];
    [titleLabel_ setText:[video title]];
}

- (void)videoLoadTimedOut
{
    [_loadingViewDelegate loadTimedOut];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dismissLoadingView
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dismissButtonPressed
{
    [_loadingViewDelegate stopLoadingVideo];
    [self dismissLoadingView];
}

- (void)hideDismissButton
{
    [dismissButton_ setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [dismissButton_ setAlpha:0.0];
    }];
}

- (void)removeFromSuperview
{
    [loadingTimer_ invalidate];
    loadingTimer_ = nil;
    [super removeFromSuperview];
}

@end
