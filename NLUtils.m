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

+ (CGRect)getContainerTopInnerFrame
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return CGRectMake(0, 0, screenRect.size.width, screenRect.size.height- 128 - 20 - 44);
}

+ (void)showInstructionWithMessage:(NSString *)message andKey:(NSString *)key
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:key]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        UIAlertView *instructionAlert = [[UIAlertView alloc] initWithTitle:@"Tip" message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [instructionAlert show];
    }
}

@end
