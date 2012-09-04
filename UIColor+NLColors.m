//
//  UIColor+NLColors.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+NLColors.h"

@implementation UIColor (NLColors)

+ (UIColor *)solidColorWithRed:(float)red green:(float)green blue:(float)blue
{
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
}

+ (UIColor *)colorWithPatternImageForName:(NSString *)name
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:name]];
}

+ (UIColor *)navBarTint
{
    return [UIColor blackColor];
}

+ (UIColor *)baseViewBackgroundColor
{
    return [self colorWithPatternImageForName:@"background"];
}

+ (UIColor *)playlistBarBackgroundColor
{
    return [self colorWithPatternImageForName:@"playlist_bar_background"];
}

+ (UIColor *)playlistBarColor
{
    return [self colorWithPatternImageForName:@"playlist_bar"];
}

@end
