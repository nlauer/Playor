//
//  NLPlaylist.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLPlaylist : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *videos;
@property BOOL isContinuous;
@property BOOL isShuffle;

@end
