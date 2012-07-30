//
//  NLFriendsDetailViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFriendsDetailViewController.h"

#import "NLYoutubeVideo.h"
#import "FXImageView.h"
#import "NLPlaylistBarViewController.h"

#define timeBetweenVideos 3.0

@interface NLFriendsDetailViewController ()
@property (strong, nonatomic) NLFacebookFriend *facebookFriend;
@property (strong, nonatomic) iCarousel *iCarousel;
@property (strong, nonatomic) NSArray *youtubeLinksArray;
@property (strong, nonatomic) UIWebView *videoWebView;
@end

@implementation NLFriendsDetailViewController {
    UIActivityIndicatorView *activityIndicator_;
    int numberOfActiveFactories;
}
@synthesize facebookFriend = _facebookFriend;
@synthesize iCarousel = _iCarousel, youtubeLinksArray = _youtubeLinksArray, videoWebView = _videoWebView;

- (id)initWithFacebookFriend:(NLFacebookFriend *)facebookFriend
{
    self = [super init];
    if (self) {
        self.facebookFriend = facebookFriend;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = [_facebookFriend name];
    
    UIView *carouselView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 150 - 44 - 80, self.view.frame.size.width, 150)];
    [carouselView setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
    [carouselView setTag:1337];
    [self.view addSubview:carouselView];
    
    numberOfActiveFactories = 0;
    
    [[NLYoutubeLinksFactory sharedInstance] createYoutubeLinksForFriendID:_facebookFriend.ID andDelegate:self];
    numberOfActiveFactories ++;
    
    [[NLYoutubeLinksFromFBLikesFactory sharedInstance] createYoutubeLinksForFriendID:_facebookFriend.ID andDelegate:self];
    numberOfActiveFactories++;
    
    activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator_ setCenter:CGPointMake(carouselView.frame.size.width/2, carouselView.frame.size.height/2)];
    [carouselView addSubview:activityIndicator_];
    [activityIndicator_ startAnimating];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [_videoWebView setDelegate:nil];
    _videoWebView = nil;
    activityIndicator_ = nil;
    _iCarousel = nil;
}

- (void)setupICarousel
{
    if (!_iCarousel) {
        UIView *carouselView = [self.view viewWithTag:1337];
        
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 130)];
        [carousel setType:iCarouselTypeLinear];
        [carousel setDataSource:self];
        [carousel setDelegate:self];
        [self setICarousel:carousel];
        [carouselView addSubview:carousel];
    } else {
        [_iCarousel reloadData];
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
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, [[_youtubeLinksArray objectAtIndex:index] videoURL], _videoWebView.frame.size.width, _videoWebView.frame.size.height];
    
    // Load the html into the webview
    [_videoWebView loadHTMLString:html baseURL:nil];
    [_videoWebView setDelegate:self];
}

#pragma mark -
#pragma mark YoutubeLinksDelegate
- (void)receiveYoutubeLinks:(NSArray *)links
{
    numberOfActiveFactories--;
    
    if ([links count] == 0 && !_youtubeLinksArray && numberOfActiveFactories == 0) {
        //both returns were empty, no content
        UILabel *noContentLabel = [[UILabel alloc] init];
        [noContentLabel setTextColor:[UIColor whiteColor]];
        [noContentLabel setText:@"No content available"];
        [noContentLabel sizeToFit];
        [noContentLabel setBackgroundColor:[UIColor clearColor]];
        
        UIView *carouselView = [self.view viewWithTag:1337];
        [noContentLabel setCenter:CGPointMake(carouselView.frame.size.width/2, carouselView.frame.size.height/2)];
        [carouselView addSubview:noContentLabel];
        
        [activityIndicator_ stopAnimating];
        [activityIndicator_ setHidden:YES];
        return;
    }
    if (!_youtubeLinksArray && [links count] > 0) {
        //one return was filled
        self.youtubeLinksArray = links;
        [self setupICarousel];
        
        [activityIndicator_ stopAnimating];
        [activityIndicator_ setHidden:YES];
    } else {
        //both returns were filled, append content
        _youtubeLinksArray = [_youtubeLinksArray arrayByAddingObjectsFromArray:links];
        [_iCarousel reloadData];
    }
}

#pragma mark -
#pragma mark YoutubeLinksFromFBLikesDelegate
- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links
{
    [self receiveYoutubeLinks:links];
}

#pragma mark -
#pragma mark ICarousel Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_youtubeLinksArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *titleLabel = nil;
    FXImageView *thumbnailImageView = nil;
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 130)];
        [view setBackgroundColor:[UIColor blackColor]];
        
        thumbnailImageView = [[FXImageView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height - 30)];
        [thumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
        [thumbnailImageView setTag:2];
        [thumbnailImageView setAsynchronous:YES];
        [thumbnailImageView setReflectionAlpha:0.6];
        [thumbnailImageView setReflectionGap:0];
        [thumbnailImageView setReflectionScale:0.4];
        [view addSubview:thumbnailImageView];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [titleLabel setTag:1];
        [titleLabel setNumberOfLines:3];
        [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [titleLabel setTextAlignment:UITextAlignmentCenter];
        [view addSubview:titleLabel];
    } else {
        titleLabel = (UILabel *)[view viewWithTag:1];
        thumbnailImageView = (FXImageView *)[view viewWithTag:2];
    }
    
    [thumbnailImageView setImage:nil];
    [thumbnailImageView setImageWithContentsOfURL:[[_youtubeLinksArray objectAtIndex:index] thumbnailURL]];
    
    [titleLabel setText:[[_youtubeLinksArray objectAtIndex:index] title]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(10, 100, view.frame.size.width - 20, view.frame.size.height - 100)];
    
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
            return value * 1.05f;
        }
        default:
        {
            return value;
        }
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [self loadNewVideoWithIndex:index];
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    for (UIGestureRecognizer *recognizer in [[carousel currentItemView] gestureRecognizers]) {
        [[carousel currentItemView] removeGestureRecognizer:recognizer];
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeVideoView:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [[carousel currentItemView] addGestureRecognizer:swipeRecognizer];
}

#pragma mark -
#pragma mark Panning and Playlist Methods
- (void)swipeVideoView:(UISwipeGestureRecognizer *)swipeRecognizer
{
    [self.view setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        [swipeRecognizer.view setCenter:CGPointMake(swipeRecognizer.view.center.x, swipeRecognizer.view.center.y + 120)];
        [swipeRecognizer.view setTransform:CGAffineTransformMakeScale(0.3, 0.3)];
        [[swipeRecognizer.view viewWithTag:1] setHidden:YES];
    } completion:^(BOOL finished) {
        [self performSelectorInBackground:@selector(addVideoToPlaylistFromCarousel) withObject:nil];
        [UIView animateWithDuration:0.2 animations:^{
            [swipeRecognizer.view setCenter:CGPointMake(swipeRecognizer.view.center.x, swipeRecognizer.view.center.y - 120)];
            [swipeRecognizer.view setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [[swipeRecognizer.view viewWithTag:1] setHidden:NO];
            [self.view setUserInteractionEnabled:YES];
        }];
    }];
}

- (void)addVideoToPlaylistFromCarousel
{
    int index = [_iCarousel currentItemIndex];
    NLYoutubeVideo *youtubeVideo = [_youtubeLinksArray objectAtIndex:index];
    [[NLPlaylistBarViewController sharedInstance] receiveYoutubeVideo:youtubeVideo];
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
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

@end
