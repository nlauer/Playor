//
//  NLAppDelegate.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLAppDelegate.h"

#import "NLFriendsViewController.h"
#import "NLFacebookManager.h"
#import "NLPlaylistBarViewController.h"
#import "NLPlaylistManager.h"
#import "NLContainerViewController.h"
#import "UIColor+NLColors.h"

@implementation NLAppDelegate

@synthesize window = _window;
@synthesize containerController = _containerController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    NLFriendsViewController *friendsViewController = [[NLFriendsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:friendsViewController];
    
    [nav.navigationBar setBarStyle:UIBarStyleBlack];
    UIColor *barColor = [UIColor springGreen];
    [[UINavigationBar appearance] setTintColor:barColor];
    [[UISearchBar appearance] setTintColor:barColor];
    
    _containerController = [[NLContainerViewController alloc] initWithTopViewController:nav andBottomViewController:[NLPlaylistBarViewController sharedInstance]];
    self.window.rootViewController = _containerController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NLPlaylistManager sharedInstance] savePlaylistsToFile];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([[NLFacebookManager sharedInstance] isSignedInWithFacebook]) {
        [[[NLFacebookManager sharedInstance] facebook] extendAccessTokenIfNeeded];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[[NLFacebookManager sharedInstance] facebook] handleOpenURL:url]; 
}

@end
