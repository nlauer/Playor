//
//  NLFriendsDetailViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFriendsDetailViewController.h"

#import "NLPlaylistBarViewController.h"
#import "NLAppDelegate.h"
#import "NLFacebookFriend.h"

#define timeBetweenVideos 3.0

@interface NLFriendsDetailViewController ()
@property (strong, nonatomic) NLFacebookFriend *facebookFriend;
@end

@implementation NLFriendsDetailViewController {
    UIActivityIndicatorView *activityIndicator_;
    int numberOfActiveFactories;
}
@synthesize facebookFriend = _facebookFriend;

- (id)initWithFacebookFriend:(NLFacebookFriend *)facebookFriend
{
    self = [super init];
    if (self) {
        self.facebookFriend = facebookFriend;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = [_facebookFriend name];
    
    numberOfActiveFactories = 0;
    
    [[NLYoutubeLinksFactory sharedInstance] createYoutubeLinksForFriendID:_facebookFriend.ID andDelegate:self];
    numberOfActiveFactories ++;
    
    [[NLYoutubeLinksFromFBLikesFactory sharedInstance] createYoutubeLinksForFriendID:_facebookFriend.ID andDelegate:self];
    numberOfActiveFactories++;
    
    activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator_ setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 50)];
    [self.view addSubview:activityIndicator_];
    [activityIndicator_ startAnimating];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    activityIndicator_ = nil;
}

#pragma mark -
#pragma mark YoutubeLinksDelegate
- (void)insertNewLinksIntoTableView:(NSArray *)links
{
    self.youtubeLinksArray = [NSMutableArray arrayWithArray:[self.youtubeLinksArray arrayByAddingObjectsFromArray:links]];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NLYoutubeVideo *video in links) {
        int index = [self.youtubeLinksArray indexOfObject:video];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)receiveYoutubeLinks:(NSArray *)links
{
    numberOfActiveFactories--;
    
    if ([links count] == 0 && [self.youtubeLinksArray count] == 0 && numberOfActiveFactories == 0) {
        //both returns were empty, no content
        UILabel *noContentLabel = [[UILabel alloc] init];
        [noContentLabel setTextColor:[UIColor whiteColor]];
        [noContentLabel setText:@"No content available"];
        [noContentLabel sizeToFit];
        [noContentLabel setBackgroundColor:[UIColor clearColor]];
        
        [noContentLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
        [self.view addSubview:noContentLabel];
        
        [activityIndicator_ stopAnimating];
        [activityIndicator_ setHidden:YES];
        return;
    }
    if ([links count] && !activityIndicator_.hidden> 0) {
        [activityIndicator_ stopAnimating];
        [activityIndicator_ setHidden:YES];
    }
    [self insertNewLinksIntoTableView:links];
}

#pragma mark -
#pragma mark YoutubeLinksFromFBLikesDelegate
- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links
{
    [self receiveYoutubeLinks:links];
}

@end
