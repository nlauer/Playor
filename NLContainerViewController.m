//
//  NLContainerViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLContainerViewController.h"

#import "NLUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "NLYoutubeSearchViewController.h"
#import "NLFriendsViewController.h"
#import "NLControllerChooserViewController.h"
#import "NLPlaylistBarViewController.h"

@interface NLContainerViewController ()

@end

@implementation NLContainerViewController {
    UIViewController *previousViewController_;
    UIView *topViewContainer_;
    UIView *bottomViewContainer_;
}
@synthesize topController = _topController, bottomController = _bottomController;

- (id)init
{
    self = [super init];
    if (self) {
        // Init the chooser view controller
        NLControllerChooserViewController *chooserViewController = [[NLControllerChooserViewController alloc] init];
        UINavigationController *chooserNav = [[UINavigationController alloc] initWithRootViewController:chooserViewController];
        self.topController = chooserNav;
        
        self.bottomController = [NLPlaylistBarViewController sharedInstance];
        [self addChildViewController:_topController];
        [self addChildViewController:_bottomController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    topViewContainer_ = [[UIView alloc] initWithFrame:[NLUtils getContainerTopControllerFrame]];
    [topViewContainer_ setClipsToBounds:YES];
    [self.view addSubview:topViewContainer_];
    bottomViewContainer_ = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 128, self.view.frame.size.width, 128)];
    [bottomViewContainer_ setClipsToBounds:NO];
    [self.view addSubview:bottomViewContainer_];
    
	[topViewContainer_ addSubview:_topController.view];
    [bottomViewContainer_ addSubview:_bottomController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    bottomViewContainer_ = nil;
    topViewContainer_ = nil;
    previousViewController_ = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    //manually adjust the frame of the main view to prevent it from appearing under the status bar.
    [super viewDidAppear:animated];
    UIApplication *app = [UIApplication sharedApplication];
    if(!app.statusBarHidden) {
        [self.view setFrame:CGRectMake(0.0,app.statusBarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - app.statusBarFrame.size.height)];
    }
}

#pragma mark -
#pragma mark Presentation Methods

- (void)presentViewControllerBehindPlaylistBar:(UIViewController *)viewController
{
    [self.view setUserInteractionEnabled:NO];
    previousViewController_ = _topController;
    [self addChildViewController:viewController];
    _topController = viewController;
    [_topController.view setFrame:CGRectMake(0, _topController.view.frame.size.height, _topController.view.frame.size.width, _topController.view.frame.size.height)];
    
    [self transitionFromViewController:previousViewController_ toViewController:_topController duration:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [_topController.view setFrame:[NLUtils getContainerTopControllerFrame]];
    } completion:^(BOOL finished) {
        [self.view setUserInteractionEnabled:YES];
    }];
}

- (void)dismissPresentedViewControllerBehindPlaylistBar
{
    [self.view setUserInteractionEnabled:NO];
    if (previousViewController_) {
        float previousHeight = previousViewController_.view.frame.size.height;
        [previousViewController_.view setFrame:CGRectMake(0, previousViewController_.view.frame.origin.y, previousViewController_.view.frame.size.width, 44)];
        [self transitionFromViewController:_topController toViewController:previousViewController_ duration:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [previousViewController_.view setFrame:CGRectMake(0, previousViewController_.view.frame.origin.y, previousViewController_.view.frame.size.width, previousHeight)];
            [_topController.view setFrame:CGRectMake(0, _topController.view.frame.size.height, _topController.view.frame.size.width, 0)];
        } completion:^(BOOL finished) {
            _topController = previousViewController_;
            previousViewController_ = nil;
            [self.view setUserInteractionEnabled:YES];
        }];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
