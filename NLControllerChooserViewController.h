//
//  NLControllerChooserViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"
#import "iCarousel.h"

@protocol ChooserViewController <NSObject>
@optional
- (UIView *)getTitleView;
- (NSString *)getTitle;
@end

@interface NLControllerChooserViewController : NLViewController <iCarouselDelegate, iCarouselDataSource>

@end
