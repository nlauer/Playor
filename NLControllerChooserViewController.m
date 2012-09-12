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
#import "UIView+Shadow.h"

#define VIEW_SCALE 0.625f

@interface NLControllerChooserViewController ()
@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) NSMutableArray *placholderViewControllers;
@property (strong, nonatomic) iCarousel *iCarousel;
@end

@implementation NLControllerChooserViewController {
    UIView *currentShowingView_;
    int currentSelectedIndex_;
    UILabel *titleLabel_;
}
@synthesize viewControllers = _viewControllers, iCarousel = _iCarousel, placholderViewControllers = _placholderViewControllers;

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
        
        _placholderViewControllers = [[NSMutableArray alloc] init];
        for (UIViewController <ChooserViewController> *chooserViewController in _viewControllers) {
            UIViewController *placeholderViewController = [self createPlaceholderViewControllerForChooserViewController:chooserViewController];
            [_placholderViewControllers addObject:placeholderViewController];
            
            [self addChildViewController:placeholderViewController];
            [self addChildViewController:chooserViewController];
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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"placeholder_background"]]];
    
    iCarousel *carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, -10, self.view.frame.size.width, self.view.frame.size.height)];
    [carousel setType:iCarouselTypeLinear];
    [carousel setDataSource:self];
    [carousel setDelegate:self];
    [carousel scrollToItemAtIndex:1 animated:NO];
    [self setICarousel:carousel];
    [self.view addSubview:carousel];
    
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_shadow"]];
    [shadowImageView setCenter:CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height - (self.view.frame.size.height - (self.view.frame.size.height*VIEW_SCALE))/2) - shadowImageView.frame.size.height/2 + 5)];
    [self.view addSubview:shadowImageView];
    [self.view sendSubviewToBack:shadowImageView];
    
    titleLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(10, shadowImageView.frame.origin.y + shadowImageView.frame.size.height, self.view.frame.size.width - 20, 30)];
    [titleLabel_ setTextAlignment:UITextAlignmentCenter];
    [titleLabel_ setBackgroundColor:[UIColor clearColor]];
    [titleLabel_ setTextColor:[UIColor whiteColor]];
    [titleLabel_ setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview:titleLabel_];
    [self.view bringSubviewToFront:titleLabel_];
    
    // Set up the navigation bar appropriately for the view
    UIImage *showChooserImage = [UIImage imageNamed:@"icon_button"];
    UIButton *showChooserButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, showChooserImage.size.width, showChooserImage.size.height)];
    [showChooserButton setImage:showChooserImage forState:UIControlStateNormal];
    [showChooserButton addTarget:self action:@selector(toggleShowingView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:showChooserButton];
    [self.navigationItem setLeftBarButtonItem:buttonItem];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_iCarousel setDelegate:nil];
    [_iCarousel setDataSource:nil];
    _iCarousel = nil;
}

- (UIViewController *)createPlaceholderViewControllerForChooserViewController:(UIViewController <ChooserViewController> *)chooserViewController
{
    UIImage *placeholderImage = [chooserViewController getPlaceholderImage];
    UIViewController *placeholderViewController = [[UIViewController alloc] init];
    [placeholderViewController.view setFrame:CGRectMake(0, 0, placeholderImage.size.width, placeholderImage.size.height)];
    [placeholderViewController.view setBackgroundColor:[UIColor colorWithPatternImage:placeholderImage]];
    return placeholderViewController;
}

- (void)toggleShowingView
{
    if (currentShowingView_) {
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform tr2 = CGAffineTransformMakeScale(VIEW_SCALE, VIEW_SCALE);
            [currentShowingView_ setTransform:tr2];
            [currentShowingView_ setFrame:[self.view convertRect:[[_iCarousel itemViewAtIndex:currentSelectedIndex_] frame] fromView:[_iCarousel itemViewAtIndex:currentSelectedIndex_]]];
        } completion:^(BOOL finished) {
            if ([[_viewControllers objectAtIndex:currentSelectedIndex_] respondsToSelector:@selector(removedFromMainView)]) {
                [[_viewControllers objectAtIndex:currentSelectedIndex_] removedFromMainView];
            }
            [[_iCarousel itemViewAtIndex:currentSelectedIndex_] addSubview:currentShowingView_];
            [self transitionFromViewController:[_viewControllers objectAtIndex:currentSelectedIndex_] toViewController:[_placholderViewControllers objectAtIndex:currentSelectedIndex_] duration:0.3 options:UIViewAnimationOptionTransitionFlipFromLeft animations:nil completion:^(BOOL finished) {
                currentShowingView_ = nil;
                currentSelectedIndex_ = -1;
                // Reset the navigation to originals
                [self.navigationItem setTitleView:nil];
                self.title = @"Noctis";
                
                [self.navigationController.navigationBar setUserInteractionEnabled:YES];
            }];
        }];
    } else {
        [self showViewAtIndex:[_iCarousel currentItemIndex]];
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_viewControllers count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIViewController *vc = [_placholderViewControllers objectAtIndex:index];
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, carousel.frame.size.width*VIEW_SCALE, carousel.frame.size.height*VIEW_SCALE)];
        NSLog(@"view frame width:%f height:%f", view.frame.size.width, view.frame.size.height);
        [view addShadowOfWidth:3];
        [view setClipsToBounds:YES];
    } else {
        [[view viewWithTag:777] removeFromSuperview];
    }
    UIView *placeholderViewControllerView = vc.view;
    [placeholderViewControllerView setTag:777];
    [view addSubview:placeholderViewControllerView];
    
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

- (void)carouselDidScroll:(iCarousel *)carousel
{
    UIViewController <ChooserViewController> *vc = [_viewControllers objectAtIndex:[carousel currentItemIndex]];
    [titleLabel_ setText:[vc getNavigationTitle]];
}

- (void)showViewAtIndex:(int)index
{
    [self.view setUserInteractionEnabled:NO];
    UIView *smallerView = ((UIViewController *)[_viewControllers objectAtIndex:index]).view;
    CGAffineTransform tr2 = CGAffineTransformMakeScale(VIEW_SCALE, VIEW_SCALE);
    [smallerView setTransform:tr2];
    [smallerView setFrame:CGRectMake(0, 0, smallerView.frame.size.width, smallerView.frame.size.height)];
    
    [self transitionFromViewController:[_placholderViewControllers objectAtIndex:index] toViewController:[_viewControllers objectAtIndex:index] duration:0.3 options:UIViewAnimationOptionTransitionFlipFromRight animations:nil completion:^(BOOL finished) {
        currentSelectedIndex_ = index;
        currentShowingView_ = ((UIViewController *)[_viewControllers objectAtIndex:index]).view;
        CGRect viewFrame = [NLUtils getContainerTopInnerFrame];
        
        // Set the frame to be the same as what was in the carousel
        [currentShowingView_ setFrame:[self.view convertRect:[[_iCarousel itemViewAtIndex:index] frame] fromView:[_iCarousel itemViewAtIndex:index]]];
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
    }];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [self showViewAtIndex:index];
}

@end
