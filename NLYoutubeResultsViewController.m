//
//  NLYoutubeResultsViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeResultsViewController.h"

#import "NLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "FXImageView.h"
#import "NLYoutubeVideo.h"
#import "NLUtils.h"

@interface NLYoutubeResultsViewController ()
@end

@implementation NLYoutubeResultsViewController {
    UILabel *addToPlaylistLabel_;
}
@synthesize tableView = _tableView, youtubeLinksArray = _youtubeLinksArray;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:[NLUtils getContainerTopControllerFrame]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setRowHeight:140];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    _youtubeLinksArray = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    _tableView = nil;
}

- (void)loadNewVideoWithIndex:(int)index
{
    [[NLAppDelegate appDelegate] playYoutubeVideo:[_youtubeLinksArray objectAtIndex:index] withDelegate:nil];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_youtubeLinksArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"friendDetailReuseId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    UILabel *titleLabel = nil;
    FXImageView *thumbnailImageView = nil;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        thumbnailImageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width, tableView.rowHeight-10)];
        [thumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
        [thumbnailImageView setTag:2];
        [thumbnailImageView setAsynchronous:YES];
        [cell addSubview:thumbnailImageView];
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.rowHeight - 30 - 5, cell.frame.size.width, 30)];
        [titleView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
        [cell addSubview:titleView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, tableView.rowHeight - 20 - 10, cell.frame.size.width - 20, 20)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [titleLabel setTag:1];
        [cell addSubview:titleLabel];
        
        CAGradientLayer *topShadow = [CAGradientLayer layer];
        topShadow.frame = CGRectMake(0, 0, cell.frame.size.width, 5);
        topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.3 alpha:0.5] CGColor], (id)[[UIColor colorWithWhite:0.0 alpha:0.5f] CGColor], nil];
        [cell.layer insertSublayer:topShadow atIndex:0];
        
        CAGradientLayer *bottomShadow = [CAGradientLayer layer];
        bottomShadow.frame = CGRectMake(0, tableView.rowHeight-5, cell.frame.size.width, 5);
        bottomShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.5f] CGColor], (id)[[UIColor colorWithWhite:0.3 alpha:0.5] CGColor], nil];
        [cell.layer insertSublayer:bottomShadow atIndex:0];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panVideoView:)];
        [panRecognizer setDelegate:self];
        [cell addGestureRecognizer:panRecognizer];
    } else {
        titleLabel = (UILabel *)[cell viewWithTag:1];
        thumbnailImageView = (FXImageView *)[cell viewWithTag:2];
    }
    
    [thumbnailImageView setImageWithContentsOfURL:[[_youtubeLinksArray objectAtIndex:indexPath.row] thumbnailURL]];
    [titleLabel setText:[[_youtubeLinksArray objectAtIndex:indexPath.row] title]];
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self loadNewVideoWithIndex:indexPath.row];
}

#pragma mark -
#pragma mark Swiping and Playlist Methods
- (void)panVideoView:(UIPanGestureRecognizer *)panGesture
{
	CGPoint delta = [panGesture translationInView: panGesture.view.superview];
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (!addToPlaylistLabel_) {
            addToPlaylistLabel_ = [[UILabel alloc] init];
            [addToPlaylistLabel_ setNumberOfLines:2];
            [addToPlaylistLabel_ setTextAlignment:UITextAlignmentCenter];
            [addToPlaylistLabel_ setFont:[UIFont boldSystemFontOfSize:18]];
            [addToPlaylistLabel_ setBackgroundColor:[UIColor clearColor]];
            [addToPlaylistLabel_ setLineBreakMode:UILineBreakModeWordWrap];
            [addToPlaylistLabel_ setText:@"Add to playlist"];
        }
        [addToPlaylistLabel_ setFrame:CGRectMake(10, panGesture.view.center.y - 25, self.view.frame.size.width/2-50, 50)];
        [_tableView addSubview:addToPlaylistLabel_];
        [_tableView sendSubviewToBack:addToPlaylistLabel_];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint center = panGesture.view.center;
        center.x += delta.x;
        
        // Move the view
        if (center.x <= self.view.frame.size.width-30 && center.x >= self.view.frame.size.width/2) {
            panGesture.view.center = center;
            [panGesture setTranslation: CGPointZero inView: panGesture.view.superview];
        } else if (center.x > self.view.frame.size.width-30) {
            panGesture.view.center = CGPointMake(self.view.frame.size.width-30, panGesture.view.center.y);
            [panGesture setTranslation: CGPointZero inView: panGesture.view.superview];
        } else if (center.x < self.view.frame.size.width/2) {
            panGesture.view.center = CGPointMake(self.view.frame.size.width/2, panGesture.view.center.y);
            [panGesture setTranslation: CGPointZero inView: panGesture.view.superview];
        }
        
        // Change the text colour
        if (center.x > self.view.frame.size.width-60) {
            [addToPlaylistLabel_ setTextColor:[UIColor greenColor]];
        } else if (center.x <= self.view.frame.size.width-60) {
            [addToPlaylistLabel_ setTextColor:[UIColor blackColor]];
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        BOOL shouldAddVideo = panGesture.view.center.x >= self.view.frame.size.width-60 ? YES : NO;
        [UIView animateWithDuration:0.3 animations:^{
            panGesture.view.center = CGPointMake(self.view.frame.size.width/2, panGesture.view.center.y);
            [panGesture setTranslation: CGPointZero inView: panGesture.view.superview];
        } completion:^(BOOL finished) {
            if (shouldAddVideo) {
                [self addVideoToPlaylistFromCell:(UITableViewCell *)panGesture.view];
            }
            [addToPlaylistLabel_ removeFromSuperview];
        }];
    }
}

- (void)addVideoToPlaylistFromCell:(UITableViewCell *)cell
{
    int index = [_tableView indexPathForCell:cell].row;
    NLYoutubeVideo *youtubeVideo = [_youtubeLinksArray objectAtIndex:index];
    [[NLPlaylistBarViewController sharedInstance] receiveYoutubeVideo:youtubeVideo];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    return fabs(translation.x) > fabs(translation.y);
}


@end
