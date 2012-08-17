//
//  NLUtils.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLUtils.h"

@implementation NLUtils

+ (CGRect)getContainerTopControllerFrame
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return CGRectMake(0, 0, screenRect.size.width, screenRect.size.height- 128 - 20);
}

@end
