//
//  NLFriendsViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFriendsViewController.h"

#import "NLFacebookManager.h"
#import "NLFacebookFriend.h"
#import "FXImageView.h"
#import "NLFriendsDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NLPlaylistBarViewController.h"
#import "NLUtils.h"
#import "UIColor+NLColors.h"
#import "NLContainerViewController.h"

@interface NLFriendsViewController ()
@property (strong, nonatomic) iCarousel *iCarousel;
@property (strong, nonatomic) NSArray *facebookFriends;
@property (strong, nonatomic) NSArray *carouselArray;
@end

@implementation NLFriendsViewController {
    BOOL isPastFirstRun_;
    BOOL shouldBeginEditing_;
    UISlider *slider_;
    UIBarButtonItem *switchToChooserButtonItem_;
    UISearchBar *searchBar_;
}
@synthesize iCarousel = _iCarousel, facebookFriends = _facebookFriends, carouselArray = _carouselArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    shouldBeginEditing_ = YES;
    [self.view setFrame:[NLUtils getContainerTopInnerFrame]];
    [self.view setClipsToBounds:YES];
    
    iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 170)];
    [carousel setType:iCarouselTypeLinear];
    [carousel setDataSource:self];
    [carousel setDelegate:self];
    [carousel setHidden:YES];
    [self setICarousel:carousel];
    [self.view addSubview:carousel];
    
    slider_ = [[UISlider alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 40, self.view.frame.size.width - 40, 20)];
    [slider_ setMinimumValue:0];
    [slider_ setMaximumValue:[_carouselArray count]];
    [slider_ addTarget:self action:@selector(sliderTouchedUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [slider_ setHidden:YES];
    [self.view addSubview:slider_];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_iCarousel setDelegate:nil];
    [_iCarousel setDataSource:nil];
    _iCarousel = nil;
}

- (void)setupICarousel
{
    [_iCarousel setHidden:NO];
    [_iCarousel setCurrentItemIndex:0];
    [_iCarousel reloadData];
}

- (void)setupSlider
{
    [slider_ setHidden:NO];
    [slider_ setValue:0];
    [slider_ setMaximumValue:[_carouselArray count]];
}

- (NSString *)friendNameForIndex:(NSUInteger)index
{
    return [((NLFacebookFriend *)[_carouselArray objectAtIndex:index]) name];
}

#pragma mark -
#pragma mark UISlider Methods
- (void)sliderTouchedUp:(UISlider *)slider
{
    [_iCarousel scrollToItemAtIndex:slider.value animated:YES];
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
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 170.0f, 170.0f)];
        [view setBackgroundColor:[UIColor blackColor]];
        
        profileImageView = [[FXImageView alloc] initWithFrame:view.frame];
        [profileImageView setContentMode:UIViewContentModeScaleAspectFill];
        [profileImageView setTag:2];
        [profileImageView setAsynchronous:YES];
        [profileImageView setReflectionAlpha:0.4];
        [profileImageView setReflectionGap:0];
        [profileImageView setReflectionScale:0.5];
        [view addSubview:profileImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 160, view.frame.size.width, 30)];
        [nameLabel setTextAlignment:UITextAlignmentCenter];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTag:1];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [view addSubview:nameLabel];
    } else {
        nameLabel = (UILabel *)[view viewWithTag:1];
        profileImageView = (FXImageView *)[view viewWithTag:2];
    }
    
    [nameLabel setText:[self friendNameForIndex:index]];
    [nameLabel setCenter:CGPointMake(floorf(view.frame.size.width/2), view.frame.size.height + 15)];
    
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
            return value * 1.1f;
        }
        default:
        {
            return value;
        }
    }
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
    [slider_ setValue:carousel.currentItemIndex animated:YES];
}

#pragma mark -
#pragma mark FacebookFriendDelegate
- (void)receiveFacebookFriends:(NSArray *)friends
{
    self.facebookFriends = [friends sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    self.carouselArray = _facebookFriends;
    [self setupICarousel];
    [self setupSlider];
}

#pragma mark -
#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchBar isFirstResponder]) {
        shouldBeginEditing_ = NO;
        
        _carouselArray = _facebookFriends;
    } else {
        if ([searchBar.text isEqualToString:@""]) {
            _carouselArray = _facebookFriends;
        } else {
            _carouselArray = [_facebookFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"name", searchBar.text]];
        }
    }
    [self setupICarousel];
    [self setupSlider];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    if (_carouselArray != _facebookFriends) {
        _carouselArray = _facebookFriends;
        
        [searchBar setText:@""];
        
        [self setupICarousel];
        [self setupSlider];
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
    [self setupICarousel];
    [self setupSlider];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:NO];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:NO];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    BOOL boolToReturn = shouldBeginEditing_;
    shouldBeginEditing_ = YES;
    return boolToReturn;
}

#pragma mark -
#pragma mark ChooserViewController Methods
- (UIView *)getTitleView
{
    if (!searchBar_) {
        searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width- 110, 44.0)];
        [searchBar_ setBarStyle:UIBarStyleBlack];
        [searchBar_ setPlaceholder:@"Search for friends"];
        [searchBar_ setDelegate:self];
    }

    return searchBar_;
}

- (void)movedToMainView
{
    if (!isPastFirstRun_) {
        [[NLFacebookManager sharedInstance] performBlockAfterFBLogin:^{
            [[NLFacebookFriendFactory sharedInstance] createFacebookFriendsWithDelegate:self];
        }];
        isPastFirstRun_ = YES;
    }
}

@end
