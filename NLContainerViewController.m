//
//  NLContainerViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLContainerViewController.h"

@interface NLContainerViewController ()

@end

@implementation NLContainerViewController
@synthesize topController = _topController, bottomController = _bottomController;

- (id)initWithTopViewController:(UIViewController *)topController andBottomViewController:(UIViewController *)bottomController
{
    self = [super init];
    if (self) {
        self.topController = topController;
        self.bottomController = bottomController;
        [self addChildViewController:_topController];
        [self addChildViewController:_bottomController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view addSubview:_topController.view];
    [self.view addSubview:_bottomController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
