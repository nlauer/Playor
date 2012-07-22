//
//  NLFriendsViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFriendsViewController.h"
#import "NLFacebookManager.h"
#import "NLFBLoginViewController.h"
#import "NLFacebookFriend.h"

@interface NLFriendsViewController ()
@property (strong, nonatomic) iCarousel *iCarousel;
@property (strong, nonatomic) NSArray *facebookFriends;
@end

@implementation NLFriendsViewController
@synthesize iCarousel = _iCarousel, facebookFriends = _facebookFriends;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Friends";
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    [searchBar setBarStyle:UIBarStyleBlack];
    [searchBar setPlaceholder:@"Search Friends"];
    [self.view addSubview:searchBar];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && 
        [defaults objectForKey:@"FBExpirationDateKey"]) {
        [[NLFacebookFriendFactory sharedInstance] createFacebookFriendsWithDelegate:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!([defaults objectForKey:@"FBAccessTokenKey"] && 
        [defaults objectForKey:@"FBExpirationDateKey"])) {
        NLFBLoginViewController *loginViewController = [[NLFBLoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [nav.navigationBar setBarStyle:UIBarStyleBlack];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (NSString *)friendNameForIndex:(NSUInteger)index
{
    return [((NLFacebookFriend *)[_facebookFriends objectAtIndex:index]) name];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    [_iCarousel scrollToItemAtIndex:slider.value animated:YES];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_facebookFriends count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *nameLabel = nil;
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        [view setBackgroundColor:[UIColor greenColor]];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, view.frame.size.width, 30)];
        [nameLabel setTextAlignment:UITextAlignmentCenter];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTag:1];
        [view addSubview:nameLabel];
        
    } else {
        nameLabel = (UILabel *)[view viewWithTag:1];
    }
    
    [nameLabel setText:[self friendNameForIndex:index]];
    [nameLabel setCenter:CGPointMake(floorf(view.frame.size.width/2), view.frame.size.height - 30)];
    
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

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
    UISlider *slider = (UISlider *)[self.view viewWithTag:1337];
    [slider setValue:carousel.currentItemIndex animated:YES];
}

#pragma mark -
#pragma mark FacebookFriendDelegate
- (void)receiveFacebookFriends:(NSArray *)friends
{
    self.facebookFriends = [friends sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 44.0f, self.view.frame.size.width, 200)];
    [carousel setType:iCarouselTypeCoverFlow];
    [carousel setDataSource:self];
    [carousel setDelegate:self];
    [self setICarousel:carousel];
    [self.view addSubview:carousel];
    
    UISlider *facebookFriendSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 40, self.view.frame.size.width - 20, 20)];
    [facebookFriendSlider setMinimumValue:0];
    [facebookFriendSlider setMaximumValue:[_facebookFriends count]];
    [facebookFriendSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [facebookFriendSlider setTag:1337];
    [self.view addSubview:facebookFriendSlider];
}

@end
