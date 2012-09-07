//
//  UIView+Shadow.m
//  Noctis
//
//  Created by Nick Lauer on 12-09-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+Shadow.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIView (Shadow)

- (void)addShadowOfWidth:(int)shadowWidth
{
    CGRect expandedFrame = CGRectMake(0, 0, self.frame.size.width + shadowWidth*2, self.frame.size.height + shadowWidth*2);
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(-shadowWidth, -shadowWidth);
    self.layer.shadowRadius = shadowWidth;
    self.layer.shadowOpacity = 0.7;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:expandedFrame].CGPath;
}

@end
