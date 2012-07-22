//
//  NLFacebookManager.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

typedef void (^FacebookBlockAfterLogin)();
@interface NLFacebookManager : NSObject <FBSessionDelegate>

@property (nonatomic, retain) Facebook *facebook;

+ (NLFacebookManager *)sharedInstance;

- (void)performBlockAfterFBLogin:(FacebookBlockAfterLogin)block;


@end
