//
//  NLControllerChooserViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLControllerChooserViewController.h"

#import "NLUtils.h"
#import "NLAppDelegate.h"
#import "NLYoutubeSearchViewController.h"
#import "NLFriendsViewController.h"
#import "iCarousel.h"

@interface NLControllerChooserViewController ()
@property (strong, nonatomic) NLFriendsViewController *friendsViewController;
@property (strong, nonatomic) NLYoutubeSearchViewController *searchViewController;
@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) iCarousel *iCarousel;
@end

@implementation NLControllerChooserViewController {
    UIView *currentShowingView_;
}
@synthesize friendsViewController = _friendsViewController, searchViewController = _searchViewController, viewControllers = _viewControllers, iCarousel = _iCarousel;

- (id)init
{
    self = [super init];
    if (self) {
        // Init the search view controller
        NLYoutubeSearchViewController *searchViewController = [[NLYoutubeSearchViewController alloc] init];
        self.searchViewController = searchViewController;
        
        // Init the friends view controller
        NLFriendsViewController *friendsViewController = [[NLFriendsViewController alloc] init];
        self.friendsViewController = friendsViewController;
        
        _viewControllers = [[NSMutableArray alloc] initWithObjects:searchViewController, friendsViewController, nil];
        
        [self addChildViewController:_searchViewController];
        [self addChildViewController:_friendsViewController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Noctis";
    [self.view setFrame:[NLUtils getContainerTopInnerFrame]];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];

    iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [carousel setType:iCarouselTypeLinear];
    [carousel setDataSource:self];
    [carousel setDelegate:self];
    [self setICarousel:carousel];
    [self.view addSubview:carousel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_iCarousel setDelegate:nil];
    [_iCarousel setDataSource:nil];
    _iCarousel = nil;
}

- (void)removeCurrentShowingView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform tr2 = CGAffineTransformMakeScale(0.7, 0.7);
        [currentShowingView_ setTransform:tr2];
    } completion:^(BOOL finished) {
        [currentShowingView_ removeFromSuperview];
        [_iCarousel reloadData];
        [self.navigationItem setTitleView:nil];
        [self.navigationItem setLeftBarButtonItem:nil];
    }];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_viewControllers count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.width*0.7, carousel.frame.size.height*0.7)];
        UIViewController *vc = [_viewControllers objectAtIndex:index];
        CGAffineTransform tr2 = CGAffineTransformMakeScale(0.7, 0.7);
        [vc.view setTransform:tr2];
        [vc.view setCenter:CGPointMake(view.frame.size.width/2, view.frame.size.height/2)];
        [vc.view setUserInteractionEnabled:NO];
        [view addSubview:vc.view];
    } else {
    
    }
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
            return value * 1.1f;
        }
        default:
        {
            return value;
        }
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    currentShowingView_ = ((UIViewController *)[_viewControllers objectAtIndex:index]).view;
    [currentShowingView_ setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:currentShowingView_];
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform tr2 = CGAffineTransformMakeScale(1, 1);
        [currentShowingView_ setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
        [currentShowingView_ setTransform:tr2];
    } completion:^(BOOL finished) {
        [currentShowingView_ setUserInteractionEnabled:YES];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(removeCurrentShowingView)];
        [self.navigationItem setLeftBarButtonItem:buttonItem];
        
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width- 110, 44.0)];
        [searchBar setBarStyle:UIBarStyleBlack];
        [searchBar setPlaceholder:@"Search for friends"];
        [searchBar setDelegate:[_viewControllers objectAtIndex:index]];
        [self.navigationItem setTitleView:searchBar];
    }];
}

@end
