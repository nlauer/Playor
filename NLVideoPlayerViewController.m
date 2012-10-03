//
//  NLVideoPlayerViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-09-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLVideoPlayerViewController.h"

@interface NLVideoPlayerViewController ()

@end

@implementation NLVideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    //manually adjust the frame of the main view to prevent it from appearing under the status bar.
    [super viewDidAppear:animated];
    UIApplication *app = [UIApplication sharedApplication];
    if(!app.statusBarHidden) {
        [self.view setFrame:CGRectMake(0.0,app.statusBarFrame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - app.statusBarFrame.size.height)];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
