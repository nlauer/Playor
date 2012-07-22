//
//  NLFriendsViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFriendsViewController.h"
#import "NLFacebookManager.h"
#import "NLFBLoginViewController.h"

@implementation NLFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Friends";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[NLFacebookManager sharedInstance] isSignedInWithFacebook]) {
        NLFBLoginViewController *loginViewController = [[NLFBLoginViewController alloc] init];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
}

@end
