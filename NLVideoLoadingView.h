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

- (id)initWithFrame:(CGRect)frame andDelegate:(id)loadingViewDelegate;
- (void)updateLoadingViewForVideo:(NLYoutubeVideo *)video;

@end
