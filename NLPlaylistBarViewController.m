//
//  NLPlaylistBarViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPlaylistBarViewController.h"
#import "FXImageView.h"

@interface NLPlaylistBarViewController ()
@property (strong, nonatomic) iCarousel *iCarousel;
@property (strong, nonatomic) NSMutableArray *playlistItems;
@end

@implementation NLPlaylistBarViewController
@synthesize iCarousel = _iCarousel, playlistItems = _playlistItems;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view setFrame:CGRectMake(0, self.view.frame.size.height- 60, self.view.frame.size.width, 80)];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setText:@"Swipe items down to add to playlist"];
    [infoLabel setFont:[UIFont systemFontOfSize:14]];
    [infoLabel setTextColor:[UIColor whiteColor]];
    [infoLabel sizeToFit];
    [infoLabel setTag:69];
    [infoLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:infoLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)updateICarousel
{
    if (!_iCarousel) {
        [[self.view viewWithTag:69] removeFromSuperview];
        
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, self.view.frame.size.height - 20)];
        [carousel setType:iCarouselTypeLinear];
        [carousel setDataSource:self];
        [carousel setDelegate:self];
        [carousel setContentOffset:CGSizeMake(0, 0)];
        [self setICarousel:carousel];
        [self.view addSubview:carousel];
    } else {
        [_iCarousel insertItemAtIndex:[_playlistItems count]-1 animated:YES];
        if ([_iCarousel currentItemIndex] != [_playlistItems count]-1) {
            [_iCarousel scrollToItemAtIndex:[_playlistItems count]-1 animated:YES];
        }
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
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 60)];
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
            return value;
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

#pragma mark -
#pragma mark Receiving and Deleting Methods

- (void)receiveFacebookFriend:(NLFacebookFriend *)facebookFriend
{
    if (![_playlistItems containsObject:facebookFriend]) {
        [_playlistItems addObject:facebookFriend];
        [self updateICarousel];
    } else {
        int index = [_playlistItems indexOfObject:facebookFriend];
        [_iCarousel scrollToItemAtIndex:index animated:YES];
    }
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
    UIView *playlistItemView = swipeRecognizer.view;
    [UIView animateWithDuration:0.3 animations:^{
        [playlistItemView setCenter:CGPointMake(playlistItemView.center.x, playlistItemView.center.y - playlistItemView.frame.size.height - 30)];
    } completion:^(BOOL finished) {
        int index = [_iCarousel indexOfItemView:playlistItemView];
        [_playlistItems removeObjectAtIndex:index];
        [_iCarousel removeItemAtIndex:index animated:YES];
    }];
}

@end
