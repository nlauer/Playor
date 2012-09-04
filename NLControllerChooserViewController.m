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
#import "NLPopularResultsViewController.h"
#import "iCarousel.h"

@interface NLControllerChooserViewController ()
@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) iCarousel *iCarousel;
@end

@implementation NLControllerChooserViewController {
    UIView *currentShowingView_;
    int currentSelectedIndex_;
}
@synthesize viewControllers = _viewControllers, iCarousel = _iCarousel;

- (id)init
{
    self = [super init];
    if (self) {
        // Init the view controllers
        NLYoutubeSearchViewController *searchViewController = [[NLYoutubeSearchViewController alloc] init];
        NLFriendsViewController *friendsViewController = [[NLFriendsViewController alloc] init];
        NLPopularResultsViewController *popularViewController = [[NLPopularResultsViewController alloc] init];
        
        // Group the view controllers so they can be used by the data source, and add all as child view controllers
        _viewControllers = [[NSMutableArray alloc] initWithObjects:searchViewController, friendsViewController, popularViewController, nil];
        for (UIViewController *vc in _viewControllers) {
            [self addChildViewController:vc];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Noctis";
    [self.view setClipsToBounds:YES];
    [self.view setFrame:[NLUtils getContainerTopInnerFrame]];

    iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [carousel setType:iCarouselTypeLinear];
    [carousel setDataSource:self];
    [carousel setDelegate:self];
    [carousel scrollToItemAtIndex:1 animated:NO];
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
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform tr2 = CGAffineTransformMakeScale(0.7, 0.7);
        [currentShowingView_ setTransform:tr2];
        [currentShowingView_ setFrame:[self.view convertRect:[[_iCarousel itemViewAtIndex:currentSelectedIndex_] frame] fromView:[_iCarousel itemViewAtIndex:currentSelectedIndex_]]];
    } completion:^(BOOL finished) {
        if ([[_viewControllers objectAtIndex:currentSelectedIndex_] respondsToSelector:@selector(removedFromMainView)]) {
            [[_viewControllers objectAtIndex:currentSelectedIndex_] removedFromMainView];
        }
        [currentShowingView_ removeFromSuperview];
        currentShowingView_ = nil;
        currentSelectedIndex_ = -1;
        [_iCarousel reloadData];
        
        // Reset the navigation to originals
        [self.navigationItem setTitleView:nil];
        [self.navigationItem setLeftBarButtonItem:nil];
        self.title = @"Noctis";
        
        [self.navigationController.navigationBar setUserInteractionEnabled:YES];
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
        [view setClipsToBounds:YES];
    } else {
        [[view viewWithTag:777] removeFromSuperview];
    }
    
    UIViewController *vc = [_viewControllers objectAtIndex:index];
    CGAffineTransform tr2 = CGAffineTransformMakeScale(0.7, 0.7);
    [vc.view setTransform:tr2];
    [vc.view setTag:777];
    [vc.view setFrame:CGRectMake(0, 0, vc.view.frame.size.width, vc.view.frame.size.height)];
    [vc.view setUserInteractionEnabled:NO];
    [view addSubview:vc.view];
    
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
    [self.view setUserInteractionEnabled:NO];
    currentSelectedIndex_ = index;
    currentShowingView_ = ((UIViewController *)[_viewControllers objectAtIndex:index]).view;
    CGRect viewFrame = [NLUtils getContainerTopInnerFrame];
    
    // Set the frame to be the same as what was in the carousel
    [currentShowingView_ setFrame:[self.view convertRect:[[carousel itemViewAtIndex:index] frame] fromView:[carousel itemViewAtIndex:index]]];
    [self.view addSubview:currentShowingView_];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform tr2 = CGAffineTransformMakeScale(1, 1);
        [currentShowingView_ setCenter:CGPointMake(viewFrame.size.width/2, viewFrame.size.height/2)];
        [currentShowingView_ setTransform:tr2];
    } completion:^(BOOL finished) {
        if ([[_viewControllers objectAtIndex:currentSelectedIndex_] respondsToSelector:@selector(movedToMainView)]) {
            [[_viewControllers objectAtIndex:currentSelectedIndex_] movedToMainView];
        }
        [currentShowingView_ setUserInteractionEnabled:YES];
        
        // Set up the navigation bar appropriately for the view
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(removeCurrentShowingView)];
        [self.navigationItem setLeftBarButtonItem:buttonItem];
        
        if ([[_viewControllers objectAtIndex:index] respondsToSelector:@selector(getTitleView)]) {
            // Set the title as a custom view
            [self.navigationItem setTitleView:[[_viewControllers objectAtIndex:index] getTitleView]];
        } 
        if ([[_viewControllers objectAtIndex:index] respondsToSelector:@selector(getNavigationTitle)]) {
            // Set the nav bar's title
            self.title = [[_viewControllers objectAtIndex:index] getNavigationTitle];
        }
        [self.view setUserInteractionEnabled:YES];
    }];
}

@end
