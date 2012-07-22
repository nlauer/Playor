//
//  NLFBLoginViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFBLoginViewController.h"
#import "NLFacebookManager.h"

@implementation NLFBLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Log In";
    
    UIView *loginExplanationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80.0f)];
    [loginExplanationView setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
    [self.view addSubview:loginExplanationView];
    
    UILabel *loginExplanationLabel = [[UILabel alloc] init];
    [loginExplanationLabel setBackgroundColor:[UIColor clearColor]];
    [loginExplanationLabel setTextAlignment:UITextAlignmentCenter];
    [loginExplanationLabel setTextColor:[UIColor whiteColor]];
    [loginExplanationLabel setNumberOfLines:2];
    [loginExplanationLabel setLineBreakMode:UILineBreakModeWordWrap];
    [loginExplanationLabel setText:@"Connect with Facebook to find new music from your friends"];
    CGSize size = [loginExplanationLabel.text sizeWithFont:loginExplanationLabel.font constrainedToSize:CGSizeMake(280, loginExplanationView.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
    [loginExplanationLabel setBounds:CGRectMake(0, 0, size.width, size.height)];
    [loginExplanationLabel setCenter:CGPointMake(loginExplanationView.frame.size.width/2, loginExplanationView.frame.size.height/2)];
    [loginExplanationView addSubview:loginExplanationLabel];
    
    UIButton *signInWithFacebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [signInWithFacebookButton setFrame:CGRectMake(20, self.view.frame.size.height - 100 - 44, 280, 44.0)];
    [signInWithFacebookButton setTitle:@"Sign In With Facebook" forState:UIControlStateNormal];
     [signInWithFacebookButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signInWithFacebookButton addTarget:self action:@selector(signInWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signInWithFacebookButton];
}

- (void)signInWithFacebook
{
    [[NLFacebookManager sharedInstance] performBlockAfterFBLogin:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
