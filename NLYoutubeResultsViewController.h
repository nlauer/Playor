//
//  NLYoutubeResultsViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"

@interface NLYoutubeResultsViewController : NLViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *youtubeLinksArray;

- (void)didRequestMoreData;
- (void)startLoading;
- (void)finishLoading;

@end
