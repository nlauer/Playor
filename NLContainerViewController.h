//
//  NLContainerViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLContainerViewController : UIViewController

@property (strong, nonatomic) UIViewController *topController;
@property (strong, nonatomic) UIViewController *bottomController;
@property (strong, nonatomic) UINavigationController *friendsViewController;
@property (strong, nonatomic) UINavigationController *searchViewController;

- (id)initWithTopViewController:(UIViewController *)topController andBottomViewController:(UIViewController *)bottomController;
- (void)presentViewControllerBehindPlaylistBar:(UIViewController *)viewController;
- (void)dismissPresentedViewControllerBehindPlaylistBar;

- (void)switchToYoutubeSearch;
- (void)switchToFriends;

@end
