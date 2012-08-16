//
//  NLFriendsDetailViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-22.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFriendsDetailViewController.h"

#import "NLYoutubeVideo.h"
#import "FXImageView.h"
#import "NLPlaylistBarViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NLAppDelegate.h"

#define timeBetweenVideos 3.0

@interface NLFriendsDetailViewController ()
@property (strong, nonatomic) NLFacebookFriend *facebookFriend;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *youtubeLinksArray;
@end

@implementation NLFriendsDetailViewController {
    UIActivityIndicatorView *activityIndicator_;
    int numberOfActiveFactories;
}
@synthesize facebookFriend = _facebookFriend;
@synthesize youtubeLinksArray = _youtubeLinksArray, tableView = _tableView;

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
    _youtubeLinksArray = [[NSMutableArray alloc] init];
    
    numberOfActiveFactories = 0;
    
    [[NLYoutubeLinksFactory sharedInstance] createYoutubeLinksForFriendID:_facebookFriend.ID andDelegate:self];
    numberOfActiveFactories ++;
    
    [[NLYoutubeLinksFromFBLikesFactory sharedInstance] createYoutubeLinksForFriendID:_facebookFriend.ID andDelegate:self];
    numberOfActiveFactories++;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - [NLPlaylistBarViewController sharedInstance].view.frame.size.height - 44) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setRowHeight:90];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorColor:[UIColor blackColor]];
    [self.view addSubview:_tableView];
    
    activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator_ setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 50)];
    [self.view addSubview:activityIndicator_];
    [activityIndicator_ startAnimating];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    activityIndicator_ = nil;
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    _tableView = nil;
}

- (void)loadNewVideoWithIndex:(int)index
{
    NLYoutubeVideo *playVideo = [_youtubeLinksArray objectAtIndex:index];
    NSURL *videoURL = [playVideo getVideoURL];
    if (videoURL) {
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [moviePlayer setWantsFullScreenLayout:YES];
        [[((NLAppDelegate *)[[UIApplication sharedApplication] delegate]) navigationController] presentViewController:moviePlayer animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark YoutubeLinksDelegate
- (void)insertNewLinksIntoTableView:(NSArray *)links
{
    _youtubeLinksArray = [_youtubeLinksArray arrayByAddingObjectsFromArray:links];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NLYoutubeVideo *video in links) {
        int index = [_youtubeLinksArray indexOfObject:video];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)receiveYoutubeLinks:(NSArray *)links
{
    numberOfActiveFactories--;
    
    if ([links count] == 0 && [_youtubeLinksArray count] == 0 && numberOfActiveFactories == 0) {
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark -
#pragma mark YoutubeLinksFromFBLikesDelegate
- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links
{
    [self receiveYoutubeLinks:links];
}

#pragma mark -
#pragma mark UITableViewDataSource

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
        
        thumbnailImageView = [[FXImageView alloc] initWithFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width - 160, tableView.rowHeight)];
        [thumbnailImageView setContentMode:UIViewContentModeScaleAspectFill];
        [thumbnailImageView setTag:2];
        [thumbnailImageView setAsynchronous:YES];
        [cell addSubview:thumbnailImageView];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [titleLabel setTag:1];
        [titleLabel setNumberOfLines:3];
        [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [cell addSubview:titleLabel];
        
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeVideoView:)];
        [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:swipeRecognizer];
    } else {
        titleLabel = (UILabel *)[cell viewWithTag:1];
        thumbnailImageView = (FXImageView *)[cell viewWithTag:2];
    }
    
    [thumbnailImageView setImageWithContentsOfURL:[[_youtubeLinksArray objectAtIndex:indexPath.row] thumbnailURL]];
    
    [titleLabel setText:[[_youtubeLinksArray objectAtIndex:indexPath.row] title]];
    [titleLabel setFrame:CGRectMake(thumbnailImageView.frame.origin.x + thumbnailImageView.frame.size.width + 10, 10, cell.frame.size.width - thumbnailImageView.frame.origin.x - thumbnailImageView.frame.size.width - 20, _tableView.rowHeight - 20)];
    
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
#pragma mark Panning and Playlist Methods
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
