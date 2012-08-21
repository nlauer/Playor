//
//  NLPlaylistEditorViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPlaylistEditorViewController.h"

#import "NLPlaylistBarViewController.h"
#import "NLPlaylistManager.h"
#import "NLPlaylist.h"
#import "NLUtils.h"
#import "NLPlaylistEditorPictureView.h"

@interface NLPlaylistEditorViewController ()
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation NLPlaylistEditorViewController
@synthesize tableView = _tableView;

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
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.title = @"My Playlists";
    
    UIBarButtonItem *addPlaylistButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(getTitleForNewPlaylist)];
    [self.navigationItem setRightBarButtonItem:addPlaylistButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setRowHeight:60];
    [self.view addSubview:_tableView];
}

- (void)getTitleForNewPlaylist
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Playlist" message:@"Please enter a name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Enter a name";
    [alert show];
}

- (void)addNewPlaylistWithName:(NSString *)name
{
    NLPlaylist *playlist = [[NLPlaylist alloc] init];
    [playlist setName:name];
    [[NLPlaylistManager sharedInstance] addPlaylist:playlist];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[[[NLPlaylistManager sharedInstance] playlists] count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (int)selectedPlaylistIndex
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentIndex"] integerValue];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{ 
    if (buttonIndex == 1) {
        [self addNewPlaylistWithName:[[alertView textFieldAtIndex:0] text]];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[NLPlaylistManager sharedInstance] playlists] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"playlistCell";
    NLPlaylistEditorPictureView *pictureView = nil;
    UILabel *titleLabel = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        pictureView = [[NLPlaylistEditorPictureView alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width, tableView.rowHeight-10)];
        [pictureView setTag:1337];
        [cell addSubview:pictureView];
        
        UIView *titleView = [[UIView alloc] initWithFrame:pictureView.frame];
        [titleView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
        [cell addSubview:titleView];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [titleLabel setTag:13371337];
        [cell addSubview:titleLabel];
        
        CAGradientLayer *topShadow = [CAGradientLayer layer];
        topShadow.frame = CGRectMake(0, 0, cell.frame.size.width, 5);
        topShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.3 alpha:0.5] CGColor], (id)[[UIColor colorWithWhite:0.0 alpha:0.5f] CGColor], nil];
        [cell.layer insertSublayer:topShadow atIndex:0];
        
        CAGradientLayer *bottomShadow = [CAGradientLayer layer];
        bottomShadow.frame = CGRectMake(0, tableView.rowHeight-5, cell.frame.size.width, 5);
        bottomShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.5f] CGColor], (id)[[UIColor colorWithWhite:0.3 alpha:0.5] CGColor], nil];
        [cell.layer insertSublayer:bottomShadow atIndex:0];
    } else {
        pictureView = (NLPlaylistEditorPictureView *)[cell viewWithTag:1337];
        titleLabel = (UILabel *)[cell viewWithTag:13371337];
    }
    NLPlaylist *playlist = [[[NLPlaylistManager sharedInstance] playlists] objectAtIndex:indexPath.row];
    [pictureView updatePlaylistVideos:playlist.videos];
    
    [titleLabel setText:[playlist name]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(10, tableView.rowHeight/2 - titleLabel.frame.size.height/2, cell.frame.size.width - 20, titleLabel.frame.size.height)];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = (indexPath.row == 0) ? NO : YES;
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [[NLPlaylistManager sharedInstance] removePlaylist:[[[NLPlaylistManager sharedInstance] playlists] objectAtIndex:indexPath.row]];
            if ([self selectedPlaylistIndex] == indexPath.row) {
                [[NLPlaylistManager sharedInstance] setCurrentPlaylist:0];
            }
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case UITableViewCellEditingStyleInsert:
            break;
        case UITableViewCellEditingStyleNone:
            break;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NLPlaylistManager sharedInstance] setCurrentPlaylist:indexPath.row];
}

@end
