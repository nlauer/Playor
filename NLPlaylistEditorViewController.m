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
#import <QuartzCore/QuartzCore.h>

@interface NLPlaylistEditorViewController ()
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation NLPlaylistEditorViewController {
    NSIndexPath *selectedIndexPath_;
}
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
    
    selectedIndexPath_ = [NSIndexPath indexPathForRow:[self selectedPlaylistIndex] inSection:0];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setRowHeight:48];
    [self.view addSubview:_tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    _tableView = nil;
}

- (void)getTitleForNewPlaylist
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Playlist" message:@"Please enter a name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Enter a name";
    alertTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alert show];
}

- (void)addNewPlaylistWithName:(NSString *)name
{
    NLPlaylist *playlist = [[NLPlaylist alloc] init];
    [playlist setName:name];
    [[NLPlaylistManager sharedInstance] addPlaylist:playlist];
    int row = [[[NLPlaylistManager sharedInstance] playlists] count]-1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self selectIndexPath:indexPath];
}

- (int)selectedPlaylistIndex
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"currentIndex"] integerValue];
}

- (void)selectIndexPath:(NSIndexPath *)indexPath
{
    [[NLPlaylistManager sharedInstance] setCurrentPlaylist:indexPath.row];
    selectedIndexPath_ = indexPath;
    [_tableView reloadData];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    return [[[alertView textFieldAtIndex:0] text] length] > 0;
}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        [cell setIndentationLevel:2];
    }
    
    if (indexPath.row == selectedIndexPath_.row) {
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    } else {
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    
    NLPlaylist *playlist = [[[NLPlaylistManager sharedInstance] playlists] objectAtIndex:indexPath.row];
    [cell.textLabel setText:playlist.name];
    
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
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if ([self selectedPlaylistIndex] == indexPath.row) {
                [[NLPlaylistManager sharedInstance] setCurrentPlaylist:0];
                selectedIndexPath_ = [NSIndexPath indexPathForRow:0 inSection:0];
                [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            } else if (indexPath.row < selectedIndexPath_.row) {
                [[NLPlaylistManager sharedInstance] setCurrentPlaylist:selectedIndexPath_.row - 1];
                selectedIndexPath_ = [NSIndexPath indexPathForRow:selectedIndexPath_.row - 1 inSection:0];
            }
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
    if (indexPath.row == selectedIndexPath_.row) {
            [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"playlist_cell_selected"]]];
    } else {
        [cell setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"playlist_cell"]]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (selectedIndexPath_.row != indexPath.row) {
        [self selectIndexPath:indexPath];
    }
}

@end
