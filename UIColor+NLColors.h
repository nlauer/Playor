//
//  UIColor+NLColors.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (NLColors)

+ (UIColor *)solidColorWithRed:(float)red green:(float)green blue:(float)blue;

+ (UIColor *)navBarTint;
+ (UIColor *)baseViewBackgroundColor;
+ (UIColor *)playlistBarBackgroundColor;

@end
