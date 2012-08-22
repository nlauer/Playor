//
//  NLVideoLoadingView.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingViewDelegate <NSObject>
- (void)stopLoadingVideo;
@end

@class NLYoutubeVideo;

@interface NLVideoLoadingView : UIView

@property (weak, nonatomic) id <LoadingViewDelegate> loadingViewDelegate;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)loadingViewDelegate;
- (void)showInView:(UIView *)view withVideo:(NLYoutubeVideo *)video;
- (void)hideDismissButton;

@end
