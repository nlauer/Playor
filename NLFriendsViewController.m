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
    UIBarButtonItem *switchToChooserButtonItem_;
    UISearchBar *searchBar_;
    UILabel *nameLabel_;
}
@synthesize iCarousel = _iCarousel, facebookFriends = _facebookFriends, carouselArray = _carouselArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    shouldBeginEditing_ = YES;
    [self.view setFrame:[NLUtils getContainerTopInnerFrame]];
    [self.view setClipsToBounds:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 170)];
    [carousel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 20)];
    [carousel setType:iCarouselTypeLinear];
    [carousel setDataSource:self];
    [carousel setDelegate:self];
    [carousel setHidden:YES];
    [self setICarousel:carousel];
    [self.view addSubview:carousel];
    
    nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, carousel.frame.origin.y + carousel.frame.size.height + 5, self.view.frame.size.width - 20, 30)];
    [nameLabel_ setTextAlignment:UITextAlignmentCenter];
    [nameLabel_ setBackgroundColor:[UIColor clearColor]];
    [nameLabel_ setTextColor:[UIColor whiteColor]];
    [nameLabel_ setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview:nameLabel_];
    [self.view bringSubviewToFront:nameLabel_];
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
    [_iCarousel reloadData];
    [_iCarousel setCurrentItemIndex:0];
}

- (NSString *)friendNameForIndex:(NSUInteger)index
{
    @synchronized(_carouselArray) {
        if (index < [_carouselArray count]) {
            return [((NLFacebookFriend *)[_carouselArray objectAtIndex:index]) name];
        } else {
            return nil;
        }
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_carouselArray count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    FXImageView *profileImageView = nil;
    
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.height, carousel.frame.size.height)];
        [view setBackgroundColor:[UIColor blackColor]];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, view.frame.size.height, view.frame.size.height*0.7f)];
        [backgroundView setBackgroundColor:[UIColor blackColor]];
        [view addSubview:backgroundView];
        
        profileImageView = [[FXImageView alloc] initWithFrame:view.frame];
        [profileImageView setContentMode:UIViewContentModeScaleAspectFill];
        [profileImageView setTag:2];
        [profileImageView setAsynchronous:YES];
        [profileImageView setReflectionAlpha:0.5];
        [profileImageView setReflectionGap:0];
        [profileImageView setReflectionScale:0.7];
        [view addSubview:profileImageView];
    } else {
        profileImageView = (FXImageView *)[view viewWithTag:2];
    }
    
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
            if ([_carouselArray count] > 3) {
                return YES;
            } else {
                return NO;
            }
        }
        case iCarouselOptionSpacing:
        {
            return value * 1.1f;
        }
        default:
        {
            return value;
        }
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    [nameLabel_ setText:[self friendNameForIndex:[carousel currentItemIndex]]];
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
    } else {
        if ([searchBar.text isEqualToString:@""]) {
            _carouselArray = _facebookFriends;
        } else {
            _carouselArray = [_facebookFriends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[cd] %@", @"name", searchBar.text]];
        }
    }
    [self setupICarousel];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    if (_carouselArray != _facebookFriends) {
        _carouselArray = _facebookFriends;
        
        [searchBar setText:@""];
        
        [self setupICarousel];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
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

- (UIImage *)getPlaceholderImage
{
    return [UIImage imageNamed:@"my_friends"];
}

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

- (NSString *)getNavigationTitle
{
    return @"My Friends";
}

- (void)movedToMainView
{
    if (!isPastFirstRun_ || ![[NLFacebookManager sharedInstance] isSignedInWithFacebook]) {
        [[NLFacebookManager sharedInstance] performBlockAfterFBLogin:^{
            [[NLFacebookFriendFactory sharedInstance] createFacebookFriendsWithDelegate:self];
        }];
        isPastFirstRun_ = YES;
    }
}

@end
