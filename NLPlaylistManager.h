//
//  NLPlaylistManager.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLPlaylistManager : NSObject

@property (strong, nonatomic) NSMutableArray *playlists;

+ (NLPlaylistManager *)sharedInstance;

@end
