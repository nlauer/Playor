//
//  NLYoutubeResultsViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeResultsViewController.h"

#import "NLAppDelegate.h"
#import "FXImageView.h"
#import "NLYoutubeVideo.h"
#import "NLUtils.h"
#import "UIColor+NLColors.h"
#import "UIView+Shadow.h"

@interface NLYoutubeResultsViewController ()
- (UITableViewCell *)getLoadingCell;
- (UITableViewCell *)getVideoCellForIndexPath:(NSIndexPath *)indexPath;
@end

@implementation NLYoutubeResultsViewController {
    UILabel *addToPlaylistLabel_;
    UIImageView *addToPlaylistBackgroundImageView_;
    BOOL isLoadingVideos_;
    BOOL shouldAllowPan_;
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
    shouldAllowPan_ = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setRowHeight:132];
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
#pragma mark Loading Cell Methods

- (void)startLoading
{
    if (!isLoadingVideos_) {
        isLoadingVideos_ = YES;
        [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_youtubeLinksArray count] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)finishLoading
{
    if (isLoadingVideos_) {
        isLoadingVideos_ = NO;
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_youtubeLinksArray count] inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return isLoadingVideos_ ? [_youtubeLinksArray count] + 1 : [_youtubeLinksArray count];
}

- (UITableViewCell *)getLoadingCell
{
    UITableViewCell *cell = nil;
    NSString *loadingCellID = @"loadingCellReuseId";
    cell = [_tableView dequeueReusableCellWithIdentifier:loadingCellID];
    
    UILabel *loadingLabel = nil;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadingCellID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell bringSubviewToFront:cell.selectedBackgroundView];
        
        loadingLabel = [[UILabel alloc] init];
        [loadingLabel setTextColor:[UIColor whiteColor]];
        [loadingLabel setBackgroundColor:[UIColor clearColor]];
        [loadingLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [loadingLabel setText:@"Loading Videos..."];
        [loadingLabel sizeToFit];
        [loadingLabel setCenter:CGPointMake(cell.frame.size.width/2 - 30, _tableView.rowHeight/2)];
        [cell addSubview:loadingLabel];
        
        UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingIndicator setCenter:CGPointMake(loadingLabel.frame.origin.x + loadingLabel.frame.size.width + loadingIndicator.frame.size.width/2 + 20, loadingLabel.center.y)];
        [loadingIndicator startAnimating];
        [loadingIndicator setHidden:NO];
        [cell addSubview:loadingIndicator];
    }
    
    return cell;
}

- (UITableViewCell *)getVideoCellForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *cellID = @"friendDetailReuseId";
    cell = [_tableView dequeueReusableCellWithIdentifier:cellID];
    
    UILabel *titleLabel = nil;
    FXImageView *thumbnailImageView = nil;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, _tableView.rowHeight)];
        [selectedBackgroundView setBackgroundColor:[UIColor greenColor]];
        [cell setSelectedBackgroundView:selectedBackgroundView];
        [cell bringSubviewToFront:cell.selectedBackgroundView];
        
        thumbnailImageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, 10, cell.frame.size.width, _tableView.rowHeight-20)];
        [thumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
        [thumbnailImageView setTag:2];
        [thumbnailImageView setAsynchronous:YES];
        [thumbnailImageView addShadowOfWidth:5];
        [cell addSubview:thumbnailImageView];
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, thumbnailImageView.frame.origin.y + thumbnailImageView.frame.size.height - 30, cell.frame.size.width, 30)];
        [titleView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
        [cell addSubview:titleView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, titleView.frame.origin.y + 5, cell.frame.size.width - 20, 20)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [titleLabel setTag:1];
        [cell addSubview:titleLabel];
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_youtubeLinksArray count]) {
        return [self getLoadingCell];
    } else {
        return [self getVideoCellForIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [_youtubeLinksArray count]) {
        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self loadNewVideoWithIndex:indexPath.row];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentPage = ((scrollView.contentOffset.y + _tableView.frame.size.height) / _tableView.rowHeight);
    int cellsUntilEnd = ([_youtubeLinksArray count] - 1) - currentPage;
    
    if (cellsUntilEnd <= 9 && !isLoadingVideos_ && [_youtubeLinksArray count] > 0) {
        [self didRequestMoreData];
    }
}

- (void)didRequestMoreData
{
    // Implemented by the subclass to reuqest more data to implement infinite scrolling
}

#pragma mark -
#pragma mark Swiping and Playlist Methods
- (void)panVideoView:(UIPanGestureRecognizer *)panGesture
{
	CGPoint delta = [panGesture translationInView: panGesture.view.superview];
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        // Add the text and background
        if (!addToPlaylistLabel_) {
            addToPlaylistLabel_ = [[UILabel alloc] init];
            [addToPlaylistLabel_ setNumberOfLines:2];
            [addToPlaylistLabel_ setTextAlignment:UITextAlignmentCenter];
            [addToPlaylistLabel_ setFont:[UIFont boldSystemFontOfSize:18]];
            [addToPlaylistLabel_ setBackgroundColor:[UIColor clearColor]];
            [addToPlaylistLabel_ setLineBreakMode:UILineBreakModeWordWrap];
            [addToPlaylistLabel_ setText:@"Add to playlist"];
        }
        if (!addToPlaylistBackgroundImageView_) {
            addToPlaylistBackgroundImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_to_playlist_background"]];
        }
        [addToPlaylistLabel_ setFrame:CGRectMake(10, panGesture.view.center.y - 25, self.view.frame.size.width/2-50, 50)];
        [_tableView addSubview:addToPlaylistLabel_];
        [_tableView sendSubviewToBack:addToPlaylistLabel_];
        
        [addToPlaylistBackgroundImageView_ setCenter:CGPointMake(addToPlaylistBackgroundImageView_.frame.size.width/2, panGesture.view.center.y)];
        [_tableView addSubview:addToPlaylistBackgroundImageView_];
        [_tableView sendSubviewToBack:addToPlaylistBackgroundImageView_];
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
            [addToPlaylistLabel_ setTextColor:[UIColor whiteColor]];
        } else if (center.x <= self.view.frame.size.width-60) {
            [addToPlaylistLabel_ setTextColor:[UIColor blackColor]];
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        shouldAllowPan_ = YES;
        BOOL shouldAddVideo = panGesture.view.center.x >= self.view.frame.size.width-60 ? YES : NO;
        [UIView animateWithDuration:0.3 animations:^{
            panGesture.view.center = CGPointMake(self.view.frame.size.width/2, panGesture.view.center.y);
            [panGesture setTranslation: CGPointZero inView: panGesture.view.superview];
        } completion:^(BOOL finished) {
            if (shouldAddVideo) {
                [self addVideoToPlaylistFromCell:(UITableViewCell *)panGesture.view];
            }
            [addToPlaylistBackgroundImageView_ removeFromSuperview];
            [addToPlaylistLabel_ removeFromSuperview];
        }];
    }
}

- (void)addVideoToPlaylistFromCell:(UITableViewCell *)cell
{
    int index = [_tableView indexPathForCell:cell].row;
    NLYoutubeVideo *youtubeVideo = [_youtubeLinksArray objectAtIndex:index];
    [youtubeVideo setAddedDate:[NSDate date]];
    [[NLPlaylistBarViewController sharedInstance] receiveYoutubeVideo:youtubeVideo];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (shouldAllowPan_) {
        CGPoint translation = [panGestureRecognizer translationInView:self.view];
        BOOL shouldBegin = fabs(translation.x) > fabs(translation.y);
        if (shouldBegin) {
            shouldAllowPan_ = NO;
        }
        return shouldBegin;
    } else {
        return NO;
    }
}


@end
