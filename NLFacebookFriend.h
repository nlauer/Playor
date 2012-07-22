//
//  NLFacebookFriend.h
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLFacebookFriend : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *ID;
@property (strong, nonatomic) NSURL *profilePictureURL;

- (id)initWithID:(NSNumber *)ID name:(NSString *)name andPicture:(NSURL *)picture;

@end
