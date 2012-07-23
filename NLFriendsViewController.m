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
#import "FXImageView.h"
#import "NLFriendsDetailViewController.h"

@interface NLFriendsViewController ()
@property (strong, nonatomic) iCarousel *iCarousel;
@property (strong, nonatomic) NSArray *facebookFriends;
@property (strong, nonatomic) NSArray *carouselArray;
@end

@implementation NLFriendsViewController {
    UISlider *slider_;
    UILabel *sliderLabel_;
    BOOL shouldBeginEditing_;
}
@synthesize iCarousel = _iCarousel, facebookFriends = _facebookFriends, carouselArray = _carouselArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Friends";
    shouldBeginEditing_ = YES;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0)];
    [searchBar setBarStyle:UIBarStyleBlack];
    [searchBar setPlaceholder:@"Search Friends"];
    [searchBar setDelegate:self];
    [self.view addSubview:searchBar];
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFriendsList)];
    [self.navigationItem setRightBarButtonItem:refresh];
    
    if ([[NLFacebookManager sharedInstance] isSignedInWithFacebook]) {
        [[NLFacebookManager sharedInstance] performBlockAfterFBLogin:^{
            [[NLFacebookFriendFactory sharedInstance] createFacebookFriendsWithDelegate:self];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[NLFacebookManager sharedInstance] isSignedInWithFacebook]) {
        NLFBLoginViewController *loginViewController = [[NLFBLoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [nav.navigationBar setBarStyle:UIBarStyleBlack];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)setupICarousel
{
    if (!_iCarousel) {
        iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 44.0f + 10.0, self.view.frame.size.width, 200)];
        [carousel setType:iCarouselTypeCoverFlow];
        [carousel setDataSource:self];
        [carousel setDelegate:self];
        [self setICarousel:carousel];
        [self.view addSubview:carousel];
    } else {
        [_iCarousel reloadData];
    }
    
    if (!slider_) {
        slider_ = [[UISlider alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 40, self.view.frame.size.width - 40, 20)];
        [slider_ setMinimumValue:0];
        [slider_ setMaximumValue:([_carouselArray count]-1)];
        [slider_ addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [slider_ addTarget:self action:@selector(sliderTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
        [slider_ addTarget:self action:@selector(sliderTouchedDown:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:slider_];
    } else {
        [slider_ setMaximumValue:([_carouselArray count]-1)];
    }
}

- (NSString *)friendNameForIndex:(NSUInteger)index
{
    return [((NLFacebookFriend *)[_carouselArray objectAtIndex:index]) name];
}

- (void)refreshFriendsList
{
    [[NLFacebookManager sharedInstance] performBlockAfterFBLogin:^{
        [[NLFacebookFriendFactory sharedInstance] createFacebookFriendsWithDelegate:self];
    }];
}

#pragma mark -
#pragma mark Slider Methods

- (void)updateSliderLabel
{
    [sliderLabel_ setText:[self friendNameForIndex:slider_.value]];;
    [sliderLabel_ sizeToFit];
    
    float sliderRange = slider_.frame.size.width - slider_.currentThumbImage.size.width;
    float sliderOrigin = slider_.frame.origin.x + (slider_.currentThumbImage.size.width / 2.0);
    float sliderValueToPixels = (slider_.value/slider_.maximumValue * sliderRange) + sliderOrigin;
    
    if ((sliderValueToPixels + sliderLabel_.frame.size.width/2) > self.view.frame.size.width) {
        sliderValueToPixels = floorf(self.view.frame.size.width - 10 - sliderLabel_.frame.size.width/2);
    } else if ((sliderValueToPixels - sliderLabel_.frame.size.width/2) < 0) {
        sliderValueToPixels = floorf(10 + sliderLabel_.frame.size.width/2);
    }
    
    [sliderLabel_ setCenter:CGPointMake(floorf(sliderValueToPixels), slider_.frame.origin.y - 30)];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    [self updateSliderLabel];
}

- (void)sliderTouchedDown:(UISlider *)slider
{
    if (!sliderLabel_) {
        sliderLabel_ = [[UILabel alloc] init];
        [sliderLabel_ setTextColor:[UIColor whiteColor]];
        [sliderLabel_ setTextAlignment:UITextAlignmentCenter];
        [sliderLabel_ setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:sliderLabel_];
    } else {
        [sliderLabel_ setHidden:NO];
    }
    [self updateSliderLabel];
}

- (void)sliderTouchedUp:(UISlider *)slider
{
    [_iCarousel scrollToItemAtIndex:slider.value animated:YES];
    [sliderLabel_ setHidden:YES];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_carouselArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *nameLabel = nil;
    FXImageView *profileImageView = nil;
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        profileImageView = [[FXImageView alloc] initWithFrame:view.frame];
        [profileImageView setContentMode:UIViewContentModeScaleAspectFill];
        [profileImageView setTag:2];
        [profileImageView setAsynchronous:YES];
        [profileImageView setReflectionAlpha:0.3];
        [profileImageView setReflectionGap:0];
        [profileImageView setReflectionScale:0.4];
        [view addSubview:profileImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, view.frame.size.width, 30)];
        [nameLabel setTextAlignment:UITextAlignmentCenter];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTag:1];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [view addSubview:nameLabel];
        
    } else {
        nameLabel = (UILabel *)[view viewWithTag:1];
        profileImageView = (FXImageView *)[view viewWithTag:2];
    }
    
    [nameLabel setText:[self friendNameForIndex:index]];
    [nameLabel setCenter:CGPointMake(floorf(view.frame.size.width/2), view.frame.size.height + 20)];
    
    [profileImageView setImage:nil];
    [profileImageView setImageWithContentsOfURL:[[_carouselArray objectAtIndex:index] profilePictureURL]];
    
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NLFriendsDetailViewController *friendsDetailViewController = [[NLFriendsDetailViewController alloc] initWithFacebookFriend:[_carouselArray objectAtIndex:index]];
    [self.navigationController pushViewController:friendsDetailViewController animated:YES];
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

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    [slider_ setValue:carousel.currentItemIndex animated:YES];
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    return nil;
}

#pragma mark -
#pragma mark FacebookFriendDelegate
- (void)receiveFacebookFriends:(NSArray *)friends
{
    self.facebookFriends = [friends sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    self.carouselArray = _facebookFriends;
    [self setupICarousel];
}

#pragma mark -
#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchBar isFirstResponder]) {
        shouldBeginEditing_ = NO;
        
        _carouselArray = _facebookFriends;
        
        [_iCarousel setCurrentItemIndex:0];
        [_iCarousel reloadData];
        
        [slider_ setValue:0];
        [slider_ setMaximumValue:([_carouselArray count]-1)];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    if (_carouselArray != _facebookFriends) {
        _carouselArray = _facebookFriends;
        
        [searchBar setText:@""];
        
        [_iCarousel setCurrentItemIndex:0];
        [_iCarousel reloadData];
        
        [slider_ setValue:0];
        [slider_ setMaximumValue:([_carouselArray count]-1)];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    if ([searchBar.text isEqualToString:@""]) {
        _carouselArray = _facebookFriends;
    } else {
        _carouselArray = [_facebookFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"name", searchBar.text]];
    }
    [_iCarousel reloadData];
    [_iCarousel setCurrentItemIndex:0];
    
    [slider_ setMaximumValue:([_carouselArray count]-1)];
    [slider_ setValue:0];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    BOOL boolToReturn = shouldBeginEditing_;
    shouldBeginEditing_ = YES;
    return boolToReturn;
}

@end
