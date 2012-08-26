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
    [_tableView setRowHeight:60];
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
    NSIndexPath *oldIndexPath = selectedIndexPath_;
    selectedIndexPath_ = indexPath;
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:oldIndexPath, selectedIndexPath_, nil] withRowAnimation:UITableViewRowAnimationNone];
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
    NLPlaylistEditorPictureView *pictureView = nil;
    UILabel *titleLabel = nil;
    UIView *titleView = nil;
    UIImageView *checkmarkImageView = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        
        pictureView = [[NLPlaylistEditorPictureView alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width, tableView.rowHeight-10)];
        [pictureView setTag:1337];
        [cell addSubview:pictureView];
        
        titleView = [[UIView alloc] initWithFrame:pictureView.frame];
        [titleView setTag:999];
        [titleView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
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
        bottomShadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.5f] CGColor], (id)[[UIColor colorWithWhite:0.3 alpha:0.7] CGColor], nil];
        [cell.layer insertSublayer:bottomShadow atIndex:0];
        
        checkmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]];
        [checkmarkImageView setCenter:CGPointMake(cell.frame.size.width - 30, tableView.rowHeight/2)];
        [checkmarkImageView setTag:99999];
        [cell addSubview:checkmarkImageView];
    } else {
        pictureView = (NLPlaylistEditorPictureView *)[cell viewWithTag:1337];
        titleLabel = (UILabel *)[cell viewWithTag:13371337];
        titleView = [cell viewWithTag:999];
        checkmarkImageView = (UIImageView *)[cell viewWithTag:99999];
    }
    NLPlaylist *playlist = [[[NLPlaylistManager sharedInstance] playlists] objectAtIndex:indexPath.row];
    [pictureView updatePlaylistVideos:playlist.videos];
    
    [titleLabel setText:[playlist name]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(10, tableView.rowHeight/2 - titleLabel.frame.size.height/2, cell.frame.size.width - 20, titleLabel.frame.size.height)];
    
    if (indexPath.row == selectedIndexPath_.row) {
        [checkmarkImageView setHidden:NO];
    } else {
        [checkmarkImageView setHidden:YES];
    }
    
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
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != selectedIndexPath_.row) {
        [self selectIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
