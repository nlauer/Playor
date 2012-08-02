//
//  NLPlaylistPlayerViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"

@interface NLPlaylistPlayerViewController : NLViewController

@property (strong, nonatomic) NSArray *playlist;

- (id)initWithPlaylist:(NSArray *)playlist currentIndex:(int)index;

@end
