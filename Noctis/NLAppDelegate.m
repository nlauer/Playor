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
#import "NLYoutubeVideo.h"
#import "NLVideoLoadingView.h"

@implementation NLAppDelegate {
    UIBackgroundTaskIdentifier bgTask_;
    BOOL isPlayingVideo_;
}

@synthesize window = _window;
@synthesize containerController = _containerController;
@synthesize videoWebView = _videoWebView, loadingView = _loadingView;
@synthesize videoPlayerDelegate = _videoPlayerDelegate;

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
    
    isPlayingVideo_ = NO;
    
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
    if (isPlayingVideo_) {
        [self prepareForBackgroundPlay];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self endBackgroundPlay];
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
                [self playNextVideoInBackground];
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

+ (NLAppDelegate *)appDelegate
{
    return (NLAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma mark Playing Video Methods

- (void)playYoutubeVideo:(NLYoutubeVideo *)video withDelegate:(id)videoPlayerDelegate
{
    _videoPlayerDelegate = videoPlayerDelegate;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(videoDidEnterFullscreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [notificationCenter addObserver:self selector:@selector(videoDidExitFullscreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    [self setupLoadingView];
    [_loadingView showInView:self.containerController.view withVideo:video];
    
    [self setupVideoWebView];
    
    [_videoWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@", [video youtubeID]]]]];
}

- (void)stopLoadingVideo
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    [_videoWebView stopLoading];
    [_loadingView removeFromSuperview];
}

- (void)setupLoadingView
{
    if (!_loadingView) {
        _loadingView = [[NLVideoLoadingView alloc] initWithFrame:self.window.frame andDelegate:self];
    }
}

- (void)setupVideoWebView
{
    if (!_videoWebView) {
        _videoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(-1, -1, 1, 1)];
        [_videoWebView setDelegate:self];
        [self.containerController.view addSubview:_videoWebView];
    }
}

- (void)videoDidEnterFullscreen:(NSNotification *)note
{
    NSLog(@"Entered Fullscreen");
    isPlayingVideo_ = YES;
    [_loadingView removeFromSuperview];
}

- (void)videoDidExitFullscreen:(NSNotification *)note
{
    NSLog(@"Exited Fullscreen");
    isPlayingVideo_ = NO;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    [_videoPlayerDelegate videoPlaybackDidEnd];
}

#pragma mark -
#pragma mark BackgroundPlayMethods

- (void)prepareForBackgroundPlay
{
    // Watch for remote events to keep getting notifications
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)]){
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
    }
    
    // Remove other watchers, and only watch for the necessary background events
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    [notificationCenter addObserver:self selector:@selector(videoDidEnterFullscreenInBackground) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [notificationCenter addObserver:self selector:@selector(playNextVideoInBackground) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    // The audio gets paused when entering background state, this restarts it
    if (isPlayingVideo_) {
        [self resumeAudio];
    }
}

- (void)endBackgroundPlay
{
    // Kill the background task if it was still running
    UIApplication *app = [UIApplication sharedApplication];
    if (bgTask_ != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:bgTask_]; 
        bgTask_ = UIBackgroundTaskInvalid;
    }
    
    // Stop watching for remote events
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(endReceivingRemoteControlEvents)]){
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        [self resignFirstResponder];
    }
    
    // Remove the background observers and re-add the foreground playlist observer
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    if (isPlayingVideo_) {
        [notificationCenter addObserver:self selector:@selector(videoDidExitFullscreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
        [notificationCenter addObserver:self selector:@selector(videoDidEnterFullscreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    }
}

- (void)videoDidEnterFullscreenInBackground
{
    isPlayingVideo_ = YES;
    UIApplication *app = [UIApplication sharedApplication];
    if (bgTask_ != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:bgTask_]; 
        bgTask_ = UIBackgroundTaskInvalid;
    }
}

// Start playing next video with a background task
- (void)playNextVideoInBackground
{
    isPlayingVideo_ = NO;
    UIApplication *app = [UIApplication sharedApplication];
    if (bgTask_ != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:bgTask_]; 
        bgTask_ = UIBackgroundTaskInvalid;
    }
    bgTask_ = [app beginBackgroundTaskWithExpirationHandler:^{ 
        [app endBackgroundTask:bgTask_]; 
        bgTask_ = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_videoPlayerDelegate videoPlaybackDidEnd];
    });
}

// Resumes the audio when it got stopped
- (void)resumeAudio
{
    UIButton *b = [self findButtonInView:_videoWebView];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

// Necessary to receive remote events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_loadingView hideDismissButton];
    UIButton *b = [self findButtonInView:_videoWebView];
    [b sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"VIDEO WEBVIEW DID FAIL LOAD WITH ERROR:%@", error);
}

- (UIButton *)findButtonInView:(UIView *)view {
	UIButton *button = nil;
    
	if ([view isMemberOfClass:[UIButton class]]) {
		return (UIButton *)view;
	}
    
	if (view.subviews && [view.subviews count] > 0) {
		for (UIView *subview in view.subviews) {
			button = [self findButtonInView:subview];
			if (button) return button;
		}
	}
    
	return button;
}

@end
