//
//  NLYoutubeSearchViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeSearchViewController.h"

#import "NLAppDelegate.h"
#import "NLUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "FXImageView.h"
#import "NLYoutubeVideo.h"
#import "NLContainerViewController.h"
#import "NLYoutubeLinksFromFBLikesFactory.h"

@interface NLYoutubeSearchViewController ()
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *youtubeLinksArray;
@end

@implementation NLYoutubeSearchViewController {
    UIBarButtonItem *switchToFriendsButtonItem_;
    NSString *currentSearchText_;
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
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width- 110, 44.0)];
    [searchBar setBarStyle:UIBarStyleBlack];
    [searchBar setPlaceholder:@"Search Youtube"];
    [searchBar setDelegate:self];
    [self.navigationItem setTitleView:searchBar];
    
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    [searchBar setTintColor:[UIColor redColor]];
	
    switchToFriendsButtonItem_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(switchToFriends)];
    [self.navigationItem setLeftBarButtonItem:switchToFriendsButtonItem_];
    
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
    
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    _tableView = nil;
}

- (void)loadNewVideoWithIndex:(int)index
{
    [[NLAppDelegate appDelegate] playYoutubeVideo:[_youtubeLinksArray objectAtIndex:index] withDelegate:nil];
}

#pragma mark -
#pragma mark Getting Search Results

- (void)getSearchResultsBatch
{
    [[NLYoutubeLinksFromFBLikesFactory sharedInstance] createYoutubeLinksForSearchQuery:currentSearchText_ batchSize:50 andDelegate:self];
}

- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links
{
    _youtubeLinksArray = [NSMutableArray arrayWithArray:links];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark Switch To Friends

- (void)switchToFriends
{
    [[[NLAppDelegate appDelegate] containerController] switchToFriends];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setText:@""];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:NO];
    [self.navigationItem setLeftBarButtonItem:nil];
    [UIView animateWithDuration:0.3 animations:^{
        [searchBar setFrame:CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, self.view.frame.size.width, searchBar.frame.size.height)];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    currentSearchText_ = [searchBar text];
    [self getSearchResultsBatch];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:NO];
    [UIView animateWithDuration:0.3 animations:^{
        [searchBar setFrame:CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, self.view.frame.size.width - 110, searchBar.frame.size.height)];
    } completion:^(BOOL finished) {
        [self.navigationItem setLeftBarButtonItem:switchToFriendsButtonItem_ animated:NO];
    }];
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
        
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeVideoView:)];
        [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:swipeRecognizer];
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
- (void)swipeVideoView:(UISwipeGestureRecognizer *)swipeRecognizer
{
    [self.view setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        [swipeRecognizer.view setCenter:CGPointMake(self.view.frame.size.width/2 + 100, swipeRecognizer.view.center.y)];
    } completion:^(BOOL finished) {
        [self addVideoToPlaylistFromCell:(UITableViewCell *)swipeRecognizer.view];
        [UIView animateWithDuration:0.2 animations:^{
            [swipeRecognizer.view setCenter:CGPointMake(self.view.frame.size.width/2, swipeRecognizer.view.center.y)];
            [self.view setUserInteractionEnabled:YES];
        }];
    }];
}

- (void)addVideoToPlaylistFromCell:(UITableViewCell *)cell
{
    int index = [_tableView indexPathForCell:cell].row;
    NLYoutubeVideo *youtubeVideo = [_youtubeLinksArray objectAtIndex:index];
    [[NLPlaylistBarViewController sharedInstance] receiveYoutubeVideo:youtubeVideo];
}

@end
