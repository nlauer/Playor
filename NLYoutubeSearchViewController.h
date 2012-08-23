//
//  NLYoutubeSearchViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLViewController.h"
#import "NLYoutubeLinksFromFBLikesFactory.h"

@interface NLYoutubeSearchViewController : NLViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, YoutubeLinksFromFBLikesDelegate>

@end
