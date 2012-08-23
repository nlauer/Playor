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

@interface NLYoutubeSearchViewController ()
@end

@implementation NLYoutubeSearchViewController {
    UIBarButtonItem *switchToFriendsButtonItem_;
    NSString *currentSearchText_;
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
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width- 110, 44.0)];
    [searchBar setBarStyle:UIBarStyleBlack];
    [searchBar setPlaceholder:@"Search Youtube"];
    [searchBar setDelegate:self];
    [self.navigationItem setTitleView:searchBar];
    
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    [searchBar setTintColor:[UIColor redColor]];
	
    switchToFriendsButtonItem_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(switchToFriends)];
    [self.navigationItem setLeftBarButtonItem:switchToFriendsButtonItem_];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Getting Search Results

- (void)getSearchResultsBatch
{
    self.youtubeLinksArray = nil;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [[NLYoutubeLinksFromFBLikesFactory sharedInstance] createYoutubeLinksForSearchQuery:currentSearchText_ batchSize:50 andDelegate:self];
}

- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links
{
    self.youtubeLinksArray = [NSMutableArray arrayWithArray:links];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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


@end
