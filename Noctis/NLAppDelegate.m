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
    UIColor *barColor = [UIColor navBarTint];
    [[UINavigationBar appearance] setTintColor:barColor];
    [[UISearchBar appearance] setTintColor:barColor];
    
    UIImage *minImage = [[UIImage imageNamed:@"slider_minimum"] 
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_maximum"] 
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [[UISlider appearance] setMaximumTrackImage:maxImage 
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage 
                                       forState:UIControlStateNormal];
    
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
    [[NLPlaylistBarViewController sharedInstance] prepareForBackgroundPlay];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NLPlaylistBarViewController sharedInstance] endBackgroundPlay];
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

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        NSLog(@"SUBTYPE:%d", receivedEvent.subtype);
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"PAUSE");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"PREVIOUS");
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"FAST FORWARD");
                break;
            case UIEventSubtypeRemoteControlStop:
                NSLog(@"STOP");
                break;
            default:
                break;
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[[NLFacebookManager sharedInstance] facebook] handleOpenURL:url]; 
}

@end
