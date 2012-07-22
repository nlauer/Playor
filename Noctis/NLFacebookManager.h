//
//  NLFacebookManager.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLFacebookManager : NSObject

+ (NLFacebookManager *)sharedInstance;

- (void)signInWithFacebook;

@end
