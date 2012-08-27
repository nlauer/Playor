//
//  NLPopularResultsViewController.h
//  Noctis
//
//  Created by Nick Lauer on 12-08-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLYoutubeResultsViewController.h"
#import "NLYoutubeLinksFromFBLikesFactory.h"
#import "NLControllerChooserViewController.h"

@interface NLPopularResultsViewController : NLYoutubeResultsViewController <YoutubeLinksFromFBLikesDelegate, ChooserViewController>

@end
