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
    self.title = @"Editor";
    
    UIBarButtonItem *addPlaylistButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPlaylist)];
    [self.navigationItem setRightBarButtonItem:addPlaylistButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorColor:[UIColor blackColor]];
    [self.view addSubview:_tableView];
}

- (void)addNewPlaylist
{
    NLPlaylist *playlist = [[NLPlaylist alloc] init];
    [playlist setName:@"NEW PLAYLIST"];
    [[NLPlaylistManager sharedInstance] addPlaylist:playlist];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[[[NLPlaylistManager sharedInstance] playlists] count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (int)selectedPlaylistIndex
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentIndex"] integerValue];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    cell.textLabel.text = [[[[NLPlaylistManager sharedInstance] playlists] objectAtIndex:indexPath.row] name];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
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
