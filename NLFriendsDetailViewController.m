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
    
    numberOfActiveFactories = 0;
    
    [[NLYoutubeLinksFactory sharedInstance] createYoutubeLinksForFriendID:_facebookFriend.ID andDelegate:self];
    numberOfActiveFactories ++;
    
    [[NLYoutubeLinksFromFBLikesFactory sharedInstance] createYoutubeLinksForFriendID:_facebookFriend.ID andDelegate:self];
    numberOfActiveFactories++;
    
    activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator_ setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 50)];
    [self.view addSubview:activityIndicator_];
    [activityIndicator_ startAnimating];
    
    _videoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(-1, -1, 1, 1)];
    [_videoWebView setDelegate:self];
    [self.view addSubview:_videoWebView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    activityIndicator_ = nil;
    _videoWebView = nil;
}

- (void)setupICarousel
{
    if (!_iCarousel) {
        UIView *carouselView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, self.view.frame.size.height - [NLPlaylistBarViewController sharedInstance].view.frame.size.height)];
        [carouselView setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
        [carouselView setTag:1337];
        [carouselView setClipsToBounds:YES];
        [self.view addSubview:carouselView];
        
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:carouselView.frame];
        [carousel setType:iCarouselTypeLinear];
        [carousel setVertical:YES];
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
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.width, 90)];
        [view setBackgroundColor:[UIColor darkGrayColor]];
        [view setUserInteractionEnabled:YES];
        
        thumbnailImageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, view.frame.origin.y, view.frame.size.width - 160, view.frame.size.height)];
        [thumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
        [thumbnailImageView setTag:2];
        [thumbnailImageView setAsynchronous:YES];
        [view addSubview:thumbnailImageView];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [titleLabel setTag:1];
        [titleLabel setNumberOfLines:3];
        [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [view addSubview:titleLabel];
        
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeVideoView:)];
        [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
        [view addGestureRecognizer:swipeRecognizer];
    } else {
        titleLabel = (UILabel *)[view viewWithTag:1];
        thumbnailImageView = (FXImageView *)[view viewWithTag:2];
    }
    
    [thumbnailImageView setImage:nil];
    [thumbnailImageView setImageWithContentsOfURL:[[_youtubeLinksArray objectAtIndex:index] thumbnailURL]];
    
    [titleLabel setText:[[_youtubeLinksArray objectAtIndex:index] title]];
    [titleLabel setFrame:CGRectMake(thumbnailImageView.frame.origin.x + thumbnailImageView.frame.size.width + 10, 10, view.frame.size.width - thumbnailImageView.frame.origin.x - thumbnailImageView.frame.size.width - 20, view.frame.size.height - 20)];
    
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
    //Make all views swipable
    for (UIView *view in [carousel visibleItemViews]) {
        [view setUserInteractionEnabled:YES];
    }
}

#pragma mark -
#pragma mark Panning and Playlist Methods
- (void)swipeVideoView:(UISwipeGestureRecognizer *)swipeRecognizer
{
    [self.view setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        [swipeRecognizer.view setCenter:CGPointMake(self.view.frame.size.width/2 + 100, swipeRecognizer.view.center.y)];
    } completion:^(BOOL finished) {
        [self addVideoToPlaylistFromCarouselForView:swipeRecognizer.view];
        [UIView animateWithDuration:0.2 animations:^{
            [swipeRecognizer.view setCenter:CGPointMake(self.view.frame.size.width/2, swipeRecognizer.view.center.y)];
            [self.view setUserInteractionEnabled:YES];
        }];
    }];
}

- (void)addVideoToPlaylistFromCarouselForView:(UIView *)view
{
    int index = [_iCarousel indexOfItemView:view];
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
