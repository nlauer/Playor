//
//  NLYoutubeSearchViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeSearchViewController.h"

#import "NLAppDelegate.h"
#import "NLContainerViewController.h"
#import "NLYoutubeLinksFromFBLikesFactory.h"
#import "NLUtils.h"
#import <QuartzCore/QuartzCore.h>

#define BATCH_SIZE 25

@interface NLYoutubeSearchViewController ()
@end

@implementation NLYoutubeSearchViewController {
    UIBarButtonItem *switchToChooserButtonItem_;
    NSString *currentSearchText_;
    int currentBatchStartIndex_;
    BOOL shouldRequestMoreVideos_;
    UISearchBar *searchBar_;
}

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
    currentBatchStartIndex_ = 0;
    shouldRequestMoreVideos_ = YES;
    [self.view setFrame:[NLUtils getContainerTopInnerFrame]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Getting Search Results

- (void)clearCurrentResults
{
    self.youtubeLinksArray = nil;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)getSearchResultsBatch
{
    if (currentBatchStartIndex_ == 0) {
        [self clearCurrentResults];
    }
    
    [self startLoading];
    [[NLYoutubeLinksFromFBLikesFactory sharedInstance] createYoutubeLinksForSearchQuery:currentSearchText_ batchSize:BATCH_SIZE startIndex:currentBatchStartIndex_ andDelegate:self];
}

- (void)didRequestMoreData
{
    if (shouldRequestMoreVideos_) {
        [self getSearchResultsBatch];
    }
}

- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links
{
    if ([links count] > 0 ) {
        // Content was found
        if (currentBatchStartIndex_ == 0) {
            // The first request was found
            self.youtubeLinksArray = [NSMutableArray arrayWithArray:links];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            // The next batch request was found
            self.youtubeLinksArray = [NSMutableArray arrayWithArray:[self.youtubeLinksArray arrayByAddingObjectsFromArray:links]];
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (NLYoutubeVideo *video in links) {
                int index = [self.youtubeLinksArray indexOfObject:video];
                [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            }
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        currentBatchStartIndex_ += BATCH_SIZE;
    } else if ([links count] == 0 && currentBatchStartIndex_ == 0) {
        // the first batch result did not have any results, meaning no content found
        shouldRequestMoreVideos_ = NO;
        UILabel *noContentLabel = [[UILabel alloc] init];
        [noContentLabel setTextColor:[UIColor whiteColor]];
        [noContentLabel setText:@"Content not found"];
        [noContentLabel setFont:[UIFont boldSystemFontOfSize:24]];
        [noContentLabel sizeToFit];
        [noContentLabel setTag:919191];
        [noContentLabel setBackgroundColor:[UIColor clearColor]];
        
        [noContentLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 30)];
        [self.view addSubview:noContentLabel];
    } else {
        // the next batch request did not have any results, meaning there are no more results
        shouldRequestMoreVideos_ = NO;
    }
    [self finishLoading];
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
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    // remove the no content label
    [[self.view viewWithTag:919191] removeFromSuperview];
    
    // Some Easter Eggs
    if ([[searchBar text] isEqualToString:@"KhallilMangalji"]) {
        [searchBar setText:@"One Direction"];
    }
    
    currentSearchText_ = [searchBar text];
    currentBatchStartIndex_ = 0;
    shouldRequestMoreVideos_ = YES;
    [self getSearchResultsBatch];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:NO];
}

#pragma mark -
#pragma mark ChooserViewController Methods

- (UIImage *)getPlaceholderImage
{
    return [UIImage imageNamed:@"search_music"];
}

- (UIView *)getTitleView
{
    if (!searchBar_) {
        searchBar_ = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width- 110, 44.0)];
        [searchBar_ setBarStyle:UIBarStyleBlack];
        [searchBar_ setPlaceholder:@"Search Music"];
        [searchBar_ setDelegate:self];
    }
    return searchBar_;
}

- (NSString *)getNavigationTitle
{
    return @"Search Music";
}

- (void)removedFromMainView
{
    [self finishLoading];
}

- (void)movedToMainView
{
    shouldRequestMoreVideos_ = YES;
}

@end
