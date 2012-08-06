//
//  NLPlaylistBarViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPlaylistBarViewController.h"

#import "NLFacebookFriend.h"
#import "NLYoutubeVideo.h"
#import "FXImageView.h"
#import "NLVideoInfoView.h"
#import "NLPlaylistEditorViewController.h"
#import "NLAppDelegate.h"

#define timeBetweenVideos 5.0

@interface NLPlaylistBarViewController ()
@property (strong, nonatomic) iCarousel *iCarousel;
@property (strong, nonatomic) NSMutableArray *playlistItems;
@property (strong, nonatomic) UIWebView *videoWebView;
@end

@implementation NLPlaylistBarViewController {
    int timerRepeats;
    NSTimer *playlistTimer_;
    BOOL isPlayerMode_;
    BOOL isShowingEditor_;
}
@synthesize iCarousel = _iCarousel, playlistItems = _playlistItems, videoWebView = _videoWebView;

static NLPlaylistBarViewController *sharedInstance = NULL;

+ (NLPlaylistBarViewController *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == NULL) {
            sharedInstance = [[NLPlaylistBarViewController alloc] init];
        }
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.playlistItems = [[NSMutableArray alloc] init];
    }
    return self;
}

typedef enum {
    COUNTDOWN_LABEL = 11,
    PLAYER_BAR,
    VIDEO_INFO,
} PlayerViews;

- (void)viewDidLoad
{
    [super viewDidLoad];
    timerRepeats = 0;
    isPlayerMode_ = NO;
    isShowingEditor_ = NO;
	[self.view setFrame:CGRectMake(0, self.view.frame.size.height- 108, self.view.frame.size.width, 128)];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setText:@"Swipe items down to add to playlist"];
    [infoLabel setFont:[UIFont systemFontOfSize:14]];
    [infoLabel setTextColor:[UIColor whiteColor]];
    [infoLabel sizeToFit];
    [infoLabel setTag:69];
    [infoLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - 10 - 32)];
    [self.view addSubview:infoLabel];
    
    UIView *playlistTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 20 - 64)];
    [playlistTitleView setBackgroundColor:[UIColor colorWithWhite:0.15 alpha:1.0]];
    [self.view addSubview:playlistTitleView];
    
    UILabel *playlistTitleLabel = [[UILabel alloc] init];
    [playlistTitleLabel setBackgroundColor:[UIColor clearColor]];
    [playlistTitleLabel setText:@"MY PLAYLIST"];
    [playlistTitleLabel setFont:[UIFont systemFontOfSize:16]];
    [playlistTitleLabel setTextColor:[UIColor whiteColor]];
    [playlistTitleLabel sizeToFit];
    [playlistTitleLabel setFrame:CGRectMake(10, playlistTitleView.frame.size.height/2 - playlistTitleLabel.frame.size.height/2, playlistTitleLabel.frame.size.width, playlistTitleLabel.frame.size.height)];
    [playlistTitleView addSubview:playlistTitleLabel];
    
    UIButton *playlistEditorButton = [[UIButton alloc] initWithFrame:CGRectMake(playlistTitleView.frame.size.width - 44, 0, 44, 44)];
    [playlistEditorButton setBackgroundColor:[UIColor greenColor]];
    [playlistEditorButton addTarget:self action:@selector(togglePlaylistEditor) forControlEvents:UIControlEventTouchUpInside];
    [playlistTitleView addSubview:playlistEditorButton];
}

- (void)togglePlaylistEditor
{
    if (!isShowingEditor_) {
        NLPlaylistEditorViewController *playlistEditor = [[NLPlaylistEditorViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:playlistEditor];
        [((NLAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController.topViewController presentViewController:nav animated:YES completion:nil];
    } else {
        [[((NLAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController.topViewController presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    isShowingEditor_ = !isShowingEditor_;
}

- (void)updateICarousel
{
    if (!_iCarousel) {
        [[self.view viewWithTag:69] removeFromSuperview];
        
        iCarousel *carousel;
        if (isPlayerMode_) {
            carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 44 + 10, self.view.frame.size.width, 140)];
        } else {
            carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 64 - 10, self.view.frame.size.width, 64)];
        }
        [carousel setType:iCarouselTypeLinear];
        [carousel setDataSource:self];
        [carousel setDelegate:self];
        [carousel setContentOffset:CGSizeMake(0, 0)];
        [self setICarousel:carousel];
        [self.view addSubview:carousel];
    } else {
        [_iCarousel insertItemAtIndex:[_playlistItems count]-1 animated:YES];
    }
}

- (void)loadNewVideoWithIndex:(int)index
{
    if (![[self.view subviews] containsObject:_videoWebView]) {
        _videoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(-1, -1, 1, 1)];
        [_videoWebView setBackgroundColor:[UIColor clearColor]];
        [_videoWebView.scrollView setScrollEnabled:NO];
        [self.view addSubview:_videoWebView];
    }
    
    [_videoWebView loadRequest:nil];
    NSString *youTubeVideoHTML = @"<html><head>\
    <body style='margin:0'>\
    <embed id='yt' src='%@' type='application/x-shockwave-flash' \
    width='%0.0f' height='%0.0f'></embed>\
    </body></html>";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, [[_playlistItems objectAtIndex:index] videoURL], _videoWebView.frame.size.width, _videoWebView.frame.size.height];
    
    // Load the html into the webview
    [_videoWebView loadHTMLString:html baseURL:nil];
    [_videoWebView setDelegate:self];
}

- (CGRect)getViewFrame
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (isPlayerMode_) {
        return CGRectMake(0, 20, screenBounds.size.width, screenBounds.size.height - 20);
    } else {
        return CGRectMake(0, screenBounds.size.height - 128, screenBounds.size.width, 128);
    }
}

#pragma mark -
#pragma mark Playlist Methods

// Renew the carousel when switching into player mode because the views are different sizes
- (void)renewCarouselWithIndex:(int)index
{
    [_iCarousel removeFromSuperview];
    _iCarousel = nil;
    [self updateICarousel];
    [_iCarousel scrollToItemAtIndex:index animated:NO];
}

// Handles the animation of switching to the player video and plays the video that the user pressed
- (void)startPlayerWithIndex:(int)index
{
    isPlayerMode_ = YES;
    
    [self.view setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view setFrame:CGRectMake(0, self.view.frame.origin.y + self.view.frame.size.height - 20, self.view.frame.size.width, self.view.frame.size.height)];
    } completion:^(BOOL finished) {
        [self renewCarouselWithIndex:index];
        [self setupPlaylistPlayer];
        [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view setFrame:[self getViewFrame]];
        } completion:^(BOOL finished) {
            [self playVideoAfterDelay:index];
            [self.view setUserInteractionEnabled:YES];
        }];
    }];
}

// Handles setup of the extra views that are required for player mode
- (void)setupPlaylistPlayer
{
    CGRect frame = [self getViewFrame];
    
    UIToolbar *playerBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, frame.size.height - 44, frame.size.width, 44)];
    [playerBar setBarStyle:UIBarStyleBlack];
    [playerBar setTag:PLAYER_BAR];
    [self.view addSubview:playerBar];
    
    UIBarButtonItem *leftSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rewindButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(rewindPlayer)];
    UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopPlayer)];
    UIBarButtonItem *playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPlayer)];
    UIBarButtonItem *fastForwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(fastForwardPlayer)];
    UIBarButtonItem *rightSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [playerBar setItems:[NSArray arrayWithObjects:leftSpacer, rewindButton, stopButton, playButton, fastForwardButton, rightSpacer, nil]];
    
    NLVideoInfoView *videoInfoView = [[NLVideoInfoView alloc] initWithFrame:CGRectMake(0, _iCarousel.frame.origin.y + _iCarousel.frame.size.height + 10, frame.size.width, frame.size.height - playerBar.frame.size.height -10 - _iCarousel.frame.size.height - _iCarousel.frame.origin.y - 10)];
    [videoInfoView setTag:VIDEO_INFO];
    [self updateVideoInfoView];
    
    [self.view addSubview:videoInfoView];
}

- (void)updateVideoInfoView
{
    [((NLVideoInfoView *)[self.view viewWithTag:VIDEO_INFO]) updateViewWithVideo:[_playlistItems objectAtIndex:[_iCarousel currentItemIndex]]];
}

// Cleans up the views that were added for player mode
- (void)removePlaylistPlayer
{
    [self stopCountdownTimer];
    for (int i = COUNTDOWN_LABEL; i <= VIDEO_INFO; i++) {
        [[self.view viewWithTag:i] removeFromSuperview];
    }
}

- (void)stopCountdownTimer
{
    [playlistTimer_ invalidate];
    playlistTimer_ = nil;
    timerRepeats = 0;
    [((UILabel *)[self.view viewWithTag:COUNTDOWN_LABEL]) setHidden:YES];
}

#pragma mark Player Bar Methods

// Exit player mode
- (void)stopPlayer
{
    isPlayerMode_ = NO;
    [self.view setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view setFrame:CGRectMake(0, self.view.frame.origin.y + self.view.frame.size.height - 20, self.view.frame.size.width, [self getViewFrame].size.height)];
    } completion:^(BOOL finished){
        [self renewCarouselWithIndex:[_iCarousel currentItemIndex]];
        [self removePlaylistPlayer];
        
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            [self.view setFrame:[self getViewFrame]];
        } completion:^(BOOL finished) {
            [self.view setUserInteractionEnabled:YES];
        }];
    }];
}

- (void)rewindPlayer
{
    [self playVideoAfterDelay:[_iCarousel currentItemIndex] -1];
}

- (void)fastForwardPlayer
{
    [self playVideoAfterDelay:[_iCarousel currentItemIndex] +1];
}

- (void)playPlayer
{
    [self playVideoAfterDelay:[_iCarousel currentItemIndex]];
    // change play button to pause button
}

#pragma mark Playing Videos

- (void)playVideoAfterDelay:(int)index
{
    CGRect frame = [self getViewFrame];
    UILabel *countdownLabel;
    if (![self.view viewWithTag:COUNTDOWN_LABEL]) {
        countdownLabel = [[UILabel alloc] init];
        [countdownLabel setTag:COUNTDOWN_LABEL];
        [countdownLabel setTextColor:[UIColor whiteColor]];
        [countdownLabel setBackgroundColor:[UIColor clearColor]];
        [countdownLabel setFrame:CGRectMake(10, frame.size.height - 44 - 44 - 10, frame.size.width - 20, 44)];
        [countdownLabel setTextAlignment:UITextAlignmentCenter];
        [self.view addSubview:countdownLabel];
    } else {
        countdownLabel = (UILabel *)[self.view viewWithTag:COUNTDOWN_LABEL];
        [countdownLabel setHidden:NO];
    }
    [countdownLabel setText:[NSString stringWithFormat:@"Video starts in %d", (int)timeBetweenVideos]];
    
    if (index < [_playlistItems count]) {
        [_iCarousel scrollToItemAtIndex:index animated:YES];
        if (playlistTimer_) {
            [playlistTimer_ invalidate];
            timerRepeats = 0;
        }
        playlistTimer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playNextVideo:) userInfo:nil repeats:YES];
    }
}

- (void)playNextVideo:(NSTimer *)timer
{
    timerRepeats++;
    int timeUntil = timeBetweenVideos - timerRepeats;
    [((UILabel *)[self.view viewWithTag:COUNTDOWN_LABEL]) setText:[NSString stringWithFormat:@"Video starts in %d", timeUntil]];
    if (timerRepeats >= timeBetweenVideos) {
        [self stopCountdownTimer];
        [self loadNewVideoWithIndex:[_iCarousel currentItemIndex]];
    }
}

- (void)playbackStateDidChange:(NSNotification *)note
{
    int playbackState = [[note.userInfo objectForKey:@"MPAVControllerNewStateParameter"] intValue];
    if (playbackState == 0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self playVideoAfterDelay:([_iCarousel currentItemIndex] + 1)];
    }
}


#pragma mark -
#pragma mark iCarousel methods
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_playlistItems count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    FXImageView *imageView = nil;
    
    if (view == nil) {
        view = isPlayerMode_ ? [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 130)] : [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 64)];
        [view setBackgroundColor:[UIColor blackColor]];
        
        imageView = [[FXImageView alloc] initWithFrame:view.bounds];
        [imageView setAsynchronous:YES];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setTag:2];
        [view addSubview:imageView];
        
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deletePlaylistItem:)];
        [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
        [view addGestureRecognizer:swipeRecognizer];
    } else {
        imageView = (FXImageView *)[view viewWithTag:2];
    }
    
    [imageView setImage:nil];
    [imageView setImageWithContentsOfURL:[[_playlistItems objectAtIndex:index] getPictureURL]];
    [view setUserInteractionEnabled:YES];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return NO;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value*1.05;
        }
        default:
        {
            return value;
        }
    }
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    return nil;
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    for (UIView *view in [carousel visibleItemViews]) {
        [view setUserInteractionEnabled:YES];
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    isPlayerMode_ ? [self playVideoAfterDelay:index] : [self startPlayerWithIndex:index];
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    [self updateVideoInfoView];
}

#pragma mark -
#pragma mark YoutubeLinksFromFBLikesDelegate

- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links
{
    for (NLYoutubeVideo *video in links) {
        [self receiveYoutubeVideo:video];
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserver:self selector:@selector(playbackStateDidChange:) name:@"MPAVControllerPlaybackStateChangedNotification" object:nil];
    
    UIButton *b = [self findButtonInView:webView];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)findButtonInView:(UIView *)view {
    UIButton *button = nil;
    
    if ([view isMemberOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    
    if (view.subviews && [view.subviews count] > 0) {
        for (UIView *subview in view.subviews) {
            button = [self findButtonInView:subview];
            if (button) return button;
        }
    }
    
    return button;
}

#pragma mark -
#pragma mark Receiving and Deleting Methods

- (void)receiveFacebookFriend:(NLFacebookFriend *)facebookFriend
{
    [[NLYoutubeLinksFromFBLikesFactory sharedInstance] createYoutubeLinksForFriendID:facebookFriend.ID andDelegate:self];
    //Need to get the shared videos here too
}

- (void)receiveYoutubeVideo:(NLYoutubeVideo *)video
{
    if (![_playlistItems containsObject:video]) {
        [_playlistItems addObject:video];
        [self updateICarousel];
    } else {
        int index = [_playlistItems indexOfObject:video];
        [_iCarousel scrollToItemAtIndex:index animated:YES];
    }
}

- (void)deletePlaylistItem:(UISwipeGestureRecognizer *)swipeRecognizer
{
    [self.view setUserInteractionEnabled:NO];
    UIView *playlistItemView = swipeRecognizer.view;
    [UIView animateWithDuration:0.3 animations:^{
        [playlistItemView setCenter:CGPointMake(playlistItemView.center.x, playlistItemView.center.y - playlistItemView.frame.size.height - 30)];
    } completion:^(BOOL finished) {
        [self.view setUserInteractionEnabled:YES];
        int index = [_iCarousel indexOfItemView:playlistItemView];
        [_playlistItems removeObjectAtIndex:index];
        [_iCarousel removeItemAtIndex:index animated:YES];
    }];
}

@end
