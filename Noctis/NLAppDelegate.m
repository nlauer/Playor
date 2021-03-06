//
//  NLAppDelegate.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLAppDelegate.h"

#import "NLFacebookManager.h"
#import "NLPlaylistBarViewController.h"
#import "NLPlaylistManager.h"
#import "NLContainerViewController.h"
#import "UIColor+NLColors.h"
#import "NLYoutubeVideo.h"
#import "NLVideoLoadingView.h"
#import "NLVideoPlayerViewController.h"
#import "NLUtils.h"
#import <AVFoundation/AVFoundation.h>

@implementation NLAppDelegate {
    UIBackgroundTaskIdentifier bgTask_;
    BOOL isPlayingVideo_;
    BOOL isBackgrounded_;
    BOOL shouldLoadWebview_;
    BOOL isVideoFullscreen_;
}

@synthesize window = _window;
@synthesize containerController = _containerController;
@synthesize videoWebView = _videoWebView, loadingView = _loadingView;
@synthesize videoPlayerDelegate = _videoPlayerDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL ok;
    NSError *setCategoryError = nil;
    ok = [audioSession setCategory:AVAudioSessionCategoryPlayback
                             error:&setCategoryError];
    
    isPlayingVideo_ = NO;
    
    _containerController = [[NLContainerViewController alloc] init];
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
    if (!isVideoFullscreen_) {
        [[self containerController] dismissViewControllerAnimated:!isBackgrounded_ completion:nil];
        [_loadingView dismissLoadingView];
        [self stopLoadingVideo];
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
                [self startPlayingNextVideo];
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
    isPlayingVideo_ = YES;
    _videoPlayerDelegate = videoPlayerDelegate;
    NSLog(@"PLAYING VIDEO");
    
    if (!isBackgrounded_) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(videoDidEnterFullscreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
        [notificationCenter addObserver:self selector:@selector(videoDidExitFullscreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
        
        [self setupLoadingView];
        [_loadingView showInView:self.containerController.view withVideo:video];
    }
    
    [self setupVideoWebView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@", [video youtubeID]]]];
    shouldLoadWebview_= YES;
    [_videoWebView loadRequest:request];
}

- (void)stopLoadingVideo
{
    [_videoWebView stopLoading];
    [_videoWebView loadRequest:nil];
    [_videoWebView removeFromSuperview];
    shouldLoadWebview_ = NO;
    isPlayingVideo_ = NO;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
}

- (void)loadTimedOut
{
    [self stopLoadingVideo];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Load Failed" message:@"Check your network connection" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alertView show];
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
    }
}

- (void)videoDidEnterFullscreen:(NSNotification *)note
{
    isVideoFullscreen_ = YES;
    [_loadingView dismissLoadingView];
    [NLUtils showInstructionWithMessage:@"Press the home button while a video is playing to listen to songs/playlists in the background" andKey:@"play_in_background"];
}

- (void)videoDidExitFullscreen:(NSNotification *)note
{
    isVideoFullscreen_ = NO;
    [self.containerController dismissModalViewControllerAnimated:!isBackgrounded_];
    isPlayingVideo_ = NO;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
    [notificationCenter removeObserver:self name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    [_videoWebView stopLoading];
    [_videoWebView loadRequest:nil];
    [_videoWebView removeFromSuperview];
    
    [_videoPlayerDelegate videoPlaybackDidEnd];
}

#pragma mark -
#pragma mark BackgroundPlayMethods

- (void)prepareForBackgroundPlay
{
    isBackgrounded_ = YES;
    
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
    });
    
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
    [notificationCenter addObserver:self selector:@selector(videoDidExitFullscreenInBackground) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    
    // The audio gets paused when entering background state, this restarts it
    if (isPlayingVideo_) {
        [self resumeAudio];
    }
}

- (void)endBackgroundPlay
{
    isBackgrounded_ = NO;
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
    
    [notificationCenter addObserver:self selector:@selector(videoDidExitFullscreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
    [notificationCenter addObserver:self selector:@selector(videoDidEnterFullscreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
}

- (void)videoDidEnterFullscreenInBackground
{
    isVideoFullscreen_ = YES;
    [_loadingView dismissLoadingView];
}

// Start playing next video with a background task
- (void)videoDidExitFullscreenInBackground
{
    isVideoFullscreen_ = NO;
    [self.containerController dismissModalViewControllerAnimated:!isBackgrounded_];
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
        [_videoWebView stopLoading];
        [_videoWebView loadRequest:nil];
        [_videoWebView removeFromSuperview];
        [_videoPlayerDelegate videoPlaybackDidEnd];
    });
}

- (void)startPlayingNextVideo
{
    // Closes the current video player, and the notifications handle the rest
    [_videoWebView loadRequest:nil];
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
    UIButton *b = [self findButtonInView:_videoWebView];
    if (b && shouldLoadWebview_) {
        NLVideoPlayerViewController *vc = [[NLVideoPlayerViewController alloc] init];
        [vc.view addSubview:_videoWebView];
        [self.containerController presentViewController:vc animated:!isBackgrounded_ completion:nil];
    }
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
