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
#import "NLPlaylistEditorViewController.h"
#import "NLAppDelegate.h"
#import "NLPlaylist.h"
#import "NLPlaylistManager.h"
#import "NSArray+Videos.h"
#import "NLAppDelegate.h"
#import "NLContainerViewController.h"
#import "NLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+NLColors.h"
#import "UIView+Shadow.h"

@interface NLPlaylistBarViewController ()
@property (strong, nonatomic) iCarousel *iCarousel;
@property (strong, nonatomic) NLPlaylist *playlist;
@end

@implementation NLPlaylistBarViewController {
    BOOL isShowingEditor_;
    UILabel *playlistTitleLabel_;
    UIButton *shuffleButton_;
    UIButton *continuousButton_;
    int playingItemIndex_;
}
@synthesize iCarousel = _iCarousel, playlist = _playlist;

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
        _playlist = [[NLPlaylistManager sharedInstance] getCurrentPlaylist];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isShowingEditor_ = NO;
	[self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 128)];
    
    UIImageView *shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playlist_bar_top_shadow"]];
    [shadowView setFrame:CGRectMake(0, -shadowView.frame.size.height, shadowView.frame.size.width, shadowView.frame.size.height)];
    [self.view addSubview:shadowView];
    
    // Top view containing all the buttons and the title
    UIView *playlistTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    [playlistTitleView setBackgroundColor:[UIColor playlistBarColor]];
    [self.view addSubview:playlistTitleView];
    
    //The Playlist options buttons
    UIButton *playlistEditorButton = [[UIButton alloc] initWithFrame:CGRectMake(playlistTitleView.frame.size.width - 45, 0, 45, 45)];
    [playlistEditorButton setBackgroundImage:[UIImage imageNamed:@"arrow_background"] forState:UIControlStateNormal];
    [playlistEditorButton setBackgroundImage:[UIImage imageNamed:@"arrow_background_highlighted"] forState:UIControlStateHighlighted];
    [playlistEditorButton setBackgroundImage:[UIImage imageNamed:@"arrow_background_selected"] forState:UIControlStateSelected];
    [playlistEditorButton setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [playlistEditorButton setImage:[UIImage imageNamed:@"arrow_highlighted"] forState:UIControlStateHighlighted];
    [playlistEditorButton setImage:[UIImage imageNamed:@"arrow_pressed"] forState:UIControlStateSelected];
    [playlistEditorButton addTarget:self action:@selector(togglePlaylistEditor:) forControlEvents:UIControlEventTouchUpInside];
    [playlistTitleView addSubview:playlistEditorButton];
    
    UIImage *shuffleImage = [UIImage imageNamed:@"shuffle"];
    shuffleButton_ = [[UIButton alloc] initWithFrame:CGRectMake(playlistEditorButton.frame.origin.x - 3 - shuffleImage.size.width, 0, shuffleImage.size.width, shuffleImage.size.height)];
    [shuffleButton_ addTarget:self action:@selector(shuffleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [shuffleButton_ setBackgroundImage:shuffleImage forState:UIControlStateNormal];
    [shuffleButton_ setBackgroundImage:[UIImage imageNamed:@"shuffle_pressed"] forState:UIControlStateSelected];
        [continuousButton_ setSelected:_playlist.isShuffle];
    [playlistTitleView addSubview:shuffleButton_];
    
    UIImage *continuousImage = [UIImage imageNamed:@"continuous"];
    continuousButton_ = [[UIButton alloc] initWithFrame:CGRectMake(shuffleButton_.frame.origin.x - continuousImage.size.width, 0, continuousImage.size.width, continuousImage.size.height)];
    [continuousButton_ addTarget:self action:@selector(continuousButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [continuousButton_ setBackgroundImage:continuousImage forState:UIControlStateNormal];
    [continuousButton_ setBackgroundImage:[UIImage imageNamed:@"continuous_pressed"] forState:UIControlStateSelected];
    [continuousButton_ setSelected:_playlist.isContinuous];
    [playlistTitleView addSubview:continuousButton_];
    
    // The title label of the playlist
    playlistTitleLabel_ = [[UILabel alloc] init];
    [playlistTitleLabel_ setBackgroundColor:[UIColor clearColor]];
    [playlistTitleLabel_ setText:_playlist.name];
    [playlistTitleLabel_ setFont:[UIFont boldSystemFontOfSize:17]];
    [playlistTitleLabel_ setTextColor:[UIColor solidColorWithRed:47 green:47 blue:47]];
    [playlistTitleLabel_ sizeToFit];
    [playlistTitleLabel_ setFrame:CGRectMake(10, playlistTitleView.frame.size.height/2 - playlistTitleLabel_.frame.size.height/2, playlistTitleView.frame.size.width - continuousButton_.frame.origin.x, playlistTitleLabel_.frame.size.height)];
    [playlistTitleView addSubview:playlistTitleLabel_];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, playlistTitleView.frame.size.height, playlistTitleView.frame.size.width, self.view.frame.size.height - playlistTitleView.frame.size.height)];
    [contentView setBackgroundColor:[UIColor playlistBarBackgroundColor]];
    [self.view addSubview:contentView];
    
    iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 55)];
    [carousel setCenter:CGPointMake(self.view.frame.size.width/2, contentView.frame.size.height/2)];
    [carousel setType:iCarouselTypeLinear];
    [carousel setDataSource:self];
    [carousel setDelegate:self];
    [carousel setContentOffset:CGSizeMake(0, 0)];
    [self setICarousel:carousel];
    [contentView addSubview:carousel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_iCarousel setDelegate:nil];
    [_iCarousel setDataSource:nil];
    _iCarousel = nil;
}

- (void)updateICarousel
{
    [_iCarousel insertItemAtIndex:[_playlist.videos count]-1 animated:YES];
}

- (void)updatePlaylist:(NLPlaylist *)playlist
{
    if (playlist != _playlist) {
        _playlist = playlist;
        [_iCarousel reloadData];
        [playlistTitleLabel_ setText:playlist.name];
        [continuousButton_ setSelected:_playlist.isContinuous];
        [shuffleButton_ setSelected:_playlist.isShuffle];
    }
    [_iCarousel scrollToItemAtIndex:0 animated:NO];
}

- (void)reloadCarouselWithAnimation
{
    [self.view setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0, 100);
        [_iCarousel setTransform:translate];
    } completion:^(BOOL finished) {
        [_iCarousel reloadData];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0, 0);
            [_iCarousel setTransform:translate];
        } completion:^(BOOL finished) {
            [self.view setUserInteractionEnabled:YES];
        }];
    }];
}

#pragma mark -
#pragma mark Playlist Button Methods

- (void)togglePlaylistEditor:(UIButton *)button
{
    [button setSelected:!button.selected];
    UIImageView *arrowImageView = button.imageView;
    arrowImageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    if (!isShowingEditor_) {
        [arrowImageView setImage:[UIImage imageNamed:@"arrow_pressed"]];
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform rotationTransform = CGAffineTransformIdentity;
            rotationTransform = CGAffineTransformRotate(rotationTransform, M_PI);
            arrowImageView.transform = rotationTransform;
        }];
        
        NLPlaylistEditorViewController *playlistEditor = [[NLPlaylistEditorViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:playlistEditor];
        [[((NLAppDelegate *)[[UIApplication sharedApplication] delegate]) containerController] presentViewControllerBehindPlaylistBar:nav];
    } else {
        [arrowImageView setImage:[UIImage imageNamed:@"arrow"]];
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform rotationTransform = CGAffineTransformIdentity;
            rotationTransform = CGAffineTransformRotate(rotationTransform, 0);
            arrowImageView.transform = rotationTransform;
        }];
        
        [[((NLAppDelegate *)[[UIApplication sharedApplication] delegate]) containerController] dismissPresentedViewControllerBehindPlaylistBar];
    }
    isShowingEditor_ = !isShowingEditor_;
}

- (void)shuffleButtonPressed:(UIButton *)shuffleButton
{
    BOOL isSelected = !shuffleButton.selected;
    [shuffleButton setSelected:isSelected];
    [_playlist setIsShuffle:isSelected];
    [self reloadCarouselWithAnimation];
}

- (void)continuousButtonPressed:(UIButton *)continuousButton
{
    BOOL isSelected = !continuousButton.selected;
    [continuousButton setSelected:isSelected];
    [_playlist setIsContinuous:isSelected];
}

#pragma mark -
#pragma mark VideoPlayerDelegate

- (void)videoPlaybackDidEnd
{
    playingItemIndex_ ++;
    
    // Mod the result so that it will scroll back to first position
    if (_playlist.isContinuous) {
        playingItemIndex_ = playingItemIndex_ % [_playlist.videos count];
    }
    
    if (playingItemIndex_ < [_playlist.videos count]) {
        [_iCarousel scrollToItemAtIndex:playingItemIndex_ animated:YES];
        [self loadNewVideoWithIndex:playingItemIndex_];
    } else {
        [_iCarousel scrollToItemAtIndex:[_playlist.videos count] - 1 animated:YES];
    }
}

- (void)loadNewVideoWithIndex:(int)index
{
    [[NLAppDelegate appDelegate] playYoutubeVideo:[_playlist.videos objectAtIndex:index] withDelegate:self];
}

#pragma mark -
#pragma mark iCarousel methods
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_playlist.videos count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    FXImageView *imageView = nil;
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 95, 55)];
        [view setBackgroundColor:[UIColor blackColor]];
        [view setUserInteractionEnabled:YES];
        
        imageView = [[FXImageView alloc] initWithFrame:view.bounds];
        [imageView setAsynchronous:YES];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setTag:2];
        [imageView addShadowOfWidth:2];
        [view addSubview:imageView];
        
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deletePlaylistItem:)];
        [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
        [view addGestureRecognizer:swipeRecognizer];
    } else {
        imageView = (FXImageView *)[view viewWithTag:2];
    }
    
    [imageView setImage:nil];
    [imageView setImageWithContentsOfURL:[[_playlist.videos objectAtIndex:index] getPictureURL]];
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
            return value*1.1;
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
    playingItemIndex_ = index;
    [self loadNewVideoWithIndex:index];
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
#pragma mark Receiving and Deleting Methods
- (void)receiveYoutubeVideo:(NLYoutubeVideo *)video
{
    if (![_playlist.videos containsVideo:video]) {
        [_playlist.videos addObject:video];
        [self updateICarousel];
        [_iCarousel scrollToItemAtIndex:[_playlist.videos count] - 1 animated:YES];
    } else {
        int index = [_playlist.videos indexOfVideo:video];
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
        [_playlist.videos removeObjectAtIndex:index];
        [_iCarousel removeItemAtIndex:index animated:YES];
    }];
}

@end
