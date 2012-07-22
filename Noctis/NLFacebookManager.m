//
//  NLFacebookManager.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFacebookManager.h"

@implementation NLFacebookManager

static NLFacebookManager *sharedInstance = NULL;

+ (NLFacebookManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == NULL) {
            sharedInstance = [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

- (void)signInWithFacebook
{
    
}

@end
