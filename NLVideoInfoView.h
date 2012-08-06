//
//  NLVideoInfoView.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NLYoutubeVideo;

@interface NLVideoInfoView : UIView

- (void)updateViewWithVideo:(NLYoutubeVideo *)video;

@end
