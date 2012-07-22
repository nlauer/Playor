//
//  NLFriendsDetailViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFriendsDetailViewController.h"

@interface NLFriendsDetailViewController ()
@property (strong, nonatomic) NLFacebookFriend *facebookFriend;
@property (strong, nonatomic) iCarousel *iCarousel;
@property (strong, nonatomic) NSArray *youtubeLinksArray;
@end

@implementation NLFriendsDetailViewController {
    UIActivityIndicatorView *activityIndicator_;
}
@synthesize facebookFriend = _facebookFriend;
@synthesize iCarousel = _iCarousel, youtubeLinksArray = _youtubeLinksArray;

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
    
    UIView *carouselView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164, self.view.frame.size.width, 120)];
    [carouselView setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:1.0]];
    [carouselView setTag:1337];
    [self.view addSubview:carouselView];
    
    [[NLYoutubeLinksFactory sharedInstance] createYoutubeLinksForFriendID:_facebookFriend.ID andDelegate:self];
    activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator_ setCenter:CGPointMake(carouselView.frame.size.width/2, carouselView.frame.size.height/2)];
    [carouselView addSubview:activityIndicator_];
    [activityIndicator_ startAnimating];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)setupICarousel
{
    if (!_iCarousel) {
        UIView *carouselView = [self.view viewWithTag:1337];
        
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 100)];
        [carousel setType:iCarouselTypeLinear];
        [carousel setDataSource:self];
        [carousel setDelegate:self];
        [self setICarousel:carousel];
        [carouselView addSubview:carousel];
    } else {
        [_iCarousel reloadData];
    }
}

#pragma mark -
#pragma mark YoutubeLinksDelegate
- (void)receiveYoutubeLinks:(NSArray *)links
{
    if ([links count] == 0) {
        NSLog(@"%@ has no shared youtube music links", [_facebookFriend name]);
    }
    self.youtubeLinksArray = links;
    [self setupICarousel];
    
    [activityIndicator_ stopAnimating];
    [activityIndicator_ setHidden:YES];
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
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 100)];
        [view setBackgroundColor:[UIColor greenColor]];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [titleLabel setTag:1];
        [titleLabel setNumberOfLines:3];
        [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [titleLabel setTextAlignment:UITextAlignmentCenter];
        [view addSubview:titleLabel];
    } else {
        titleLabel = (UILabel *)[view viewWithTag:1];
    }
    
    [titleLabel setText:[[_youtubeLinksArray objectAtIndex:index] title]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(10, 10, view.frame.size.width - 20, view.frame.size.height)];
    
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

@end
