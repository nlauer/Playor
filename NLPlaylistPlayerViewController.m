//
//  NLPlaylistPlayerViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPlaylistPlayerViewController.h"

@implementation NLPlaylistPlayerViewController {
    int currentIndex_;
}
@synthesize playlist = _playlist;

- (id)initWithPlaylist:(NSArray *)playlist currentIndex:(int)index
{
    self = [super init];
    if (self) {
        self.playlist = playlist;
        currentIndex_ = index;
        [self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePlaylist)];
    [self.navigationItem setLeftBarButtonItem:doneButton];
}

- (void)donePlaylist
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
