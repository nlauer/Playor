//
//  NLAppDelegate.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLVideoLoadingView.h"

@protocol VideoPlayerDelegate <NSObject>
- (void)videoPlaybackDidEnd;
@end

@class NLViewController, NLContainerViewController, NLYoutubeVideo;

@interface NLAppDelegate : UIResponder <UIApplicationDelegate, UIWebViewDelegate, LoadingViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NLContainerViewController *containerController;

@property (strong, nonatomic) NLVideoLoadingView *loadingView;
@property (strong, nonatomic) UIWebView *videoWebView;
@property (weak, nonatomic) id <VideoPlayerDelegate> videoPlayerDelegate;

+ (NLAppDelegate *)appDelegate;

- (void)playYoutubeVideo:(NLYoutubeVideo *)video withDelegate:(id)videoPlayerDelegate;

@end
