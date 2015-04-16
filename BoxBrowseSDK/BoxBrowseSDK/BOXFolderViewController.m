//
//  BOXBrowseTableViewController.m
//  BoxBrowseSDK
//
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import "BOXFolderViewController.h"
#import <BoxContentSDK/BoxContentSDK.h>
#import "UIImage+BOXBrowseSDKAdditions.h"
#import "BOXItemCell.h"
#import "BOXCreateFolderViewController.h"
#import "BOXSearchResultsViewController.h"
#import "MBProgressHUD.h"

@interface BOXFolderViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIAlertViewDelegate>

@property (nonatomic, readonly, strong) NSString *folderID;
@property (nonatomic, readwrite, strong) BOXFolder *folder;

@property (nonatomic, readwrite, strong) UISearchController *searchController;
@property (nonatomic, readwrite, strong) BOXSearchResultsViewController *searchResultsController;

@property (nonatomic, readwrite, strong) NSIndexPath *indexPathForDeleteCandidate;

@end

@implementation BOXFolderViewController

- (instancetype)initWithContentClient:(BOXContentClient *)contentClient
{
    if (self = [super initWithContentClient:contentClient]) {
        _folderID = BOXAPIFolderIDRoot;
        _showsChooseFolderButton = NO;
        _showsCreateFolderButton = NO;
        _showsDeleteButtons = YES;
    }
    return self;
}

- (instancetype)initWithContentClient:(BOXContentClient *)contentClient
                             folderID:(NSString *)folderID
{
    if (self = [self initWithContentClient:contentClient]) {
        _folderID = folderID;
    }
    return self;
}

- (instancetype)initWithContentClient:(BOXContentClient *)contentClient
                               folder:(BOXFolder *)folder
{
    if (self = [self initWithContentClient:contentClient]) {
        _folderID = folder.modelID;
        _folder = folder;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOXAssert(self.navigationController, @"BOXFolderViewController must be placed in a UINavigationController");

    [self setupForSearch];
    
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    emptyLabel.textColor = [UIColor colorWithRed:180.0f/255.0f green:179.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
    emptyLabel.backgroundColor = [UIColor clearColor];
    emptyLabel.contentMode = UIViewContentModeCenter;
    emptyLabel.numberOfLines = 0;
    emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    emptyLabel.text = NSLocalizedString(@"Loading…", @"Loading message shown while content is being fetched.");
    self.tableView.backgroundView = emptyLabel;
}

#pragma mark - Search

- (void)setupForSearch
{
    // UISearchController was introduced in iOS8, so we don't have search on iOS 7.
    if ([UISearchController class] && self.showsSearchBar) {
        self.definesPresentationContext = YES;
        
        self.searchResultsController = [[BOXSearchResultsViewController alloc] initWithContentClient:self.contentClient];
        self.searchResultsController.delegate = self.delegate;
        
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
        self.searchController.hidesNavigationBarDuringPresentation = YES;
        self.searchController.dimsBackgroundDuringPresentation = YES;
        self.searchController.delegate = self;
        self.searchController.searchResultsUpdater = self;
        
        [self.searchController.searchBar sizeToFit];
        self.searchController.searchBar.delegate = self;
        self.searchController.searchBar.showsCancelButton = NO;
        self.searchController.searchBar.hidden = YES; // Starts of hidden, and only when we've fetched items do we bring it in.
        if (self.folder.name.length > 0 && ![self.folder.modelID isEqualToString:BOXAPIFolderIDRoot]) {
            self.searchController.searchBar.placeholder =
                [NSString stringWithFormat:NSLocalizedString(@"Search “%@”", @"Label: Files Search Bar Placeholder"), self.folder.name];
        }
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController
{
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    [self.navigationController setToolbarHidden:NO animated:YES];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    [self.searchResultsController performSearchForSearchString:searchText inFolderID:self.folderID];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchController.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchController.searchBar resignFirstResponder];
    [self.searchController.searchBar setShowsCancelButton:NO animated:YES];
}

- (id<BOXFolderViewControllerDelegate>)folderBrowserDelegate
{
    if ([self.delegate conformsToProtocol:@protocol(BOXFolderViewControllerDelegate)]) {
        return (id<BOXFolderViewControllerDelegate>)self.delegate;
    } else {
        return nil;
    }
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.showsDeleteButtons) {
        return NO;
    }

    BOXItem *item = [self itemForRowAtIndexPath:indexPath];
    
    if (item.isFile) {
        return ((BOXFile *)item).canDelete == BOXAPIBooleanYES;
    } else if (item.isFolder) {
        return ((BOXFolder *)item).canDelete == BOXAPIBooleanYES;
    } else if (item.isBookmark) {
        return ((BOXBookmark *)item).canDelete == BOXAPIBooleanYES;
    }
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{


    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Item", @"Label: title for item deletion confirmation alert")
                                                        message:NSLocalizedString(@"Are you sure you want to delete this item?", @"Label: confirmation message for item deletion")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Label: Cancel action ")
                                              otherButtonTitles:NSLocalizedString(@"Delete", @"Label: Delete action "), nil];
    [alertView show];

    self.indexPathForDeleteCandidate = indexPath;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        BOXItem *item = [self itemForRowAtIndexPath:self.indexPathForDeleteCandidate];


        BOXErrorBlock errorBlock = ^(NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Deletion Failed", @"Label: title for item deletion failure alert")
                                                                        message:NSLocalizedString(@"There was a problem with deleting this item.", @"Label: alert message for item deletion failure")
                                                                       delegate:self
                                                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Label: Ok action ")
                                                              otherButtonTitles:nil];
                    [alertView show];
                } else {
                    [self refresh];
                    if ([self.folderBrowserDelegate respondsToSelector:@selector(didDeleteItem:)]) {
                        [self.folderBrowserDelegate didDeleteItem:item];
                    }
                }
            });
        };

        if (item.isFile) {
            BOXFileDeleteRequest *deleteRequest = [[BOXContentClient defaultClient] fileDeleteRequestWithID:item.modelID];
            [deleteRequest performRequestWithCompletion:errorBlock];
        } else if (item.isFolder) {
            BOXFolderDeleteRequest *deleteRequest = [[BOXContentClient defaultClient] folderDeleteRequestWithID:item.modelID];
            [deleteRequest performRequestWithCompletion:errorBlock];
        } else if (item.isBookmark) {
            BOXBookmarkDeleteRequest *deleteRequest = [[BOXContentClient defaultClient] bookmarkDeleteRequestWithID:item.modelID];
            [deleteRequest performRequestWithCompletion:errorBlock];
        }
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Deleting item...", @"HUD message for when item is being deleted");
    hud.mode = MBProgressHUDModeCustomView;
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    // Folder
    BOXItem *item = [self itemForRowAtIndexPath:indexPath];
    if (item.isFolder) {
        BOXFolder *folder = (BOXFolder *)item;
        BOOL shouldNavigateToFolder = YES;
        if ([self.folderBrowserDelegate respondsToSelector:@selector(willNavigateToFolder:)]) {
            shouldNavigateToFolder = [self.folderBrowserDelegate willNavigateToFolder:folder];
        }
        if (shouldNavigateToFolder) {
            BOXFolderViewController *viewController = [[BOXFolderViewController alloc] initWithContentClient:self.contentClient
                                                                                                      folder:folder];
            viewController.delegate = self.folderBrowserDelegate;
            viewController.showsChooseFolderButton = self.showsChooseFolderButton;
            viewController.showsCreateFolderButton = self.showsCreateFolderButton;
            viewController.showsDeleteButtons = self.showsDeleteButtons;
            viewController.showsSearchBar = self.showsSearchBar;
            self.navigationItem.backBarButtonItem.title = folder.parentFolder.name;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}


#pragma mark - Toolbar

- (void)setupToolbar
{
    NSMutableArray *toolbarItems = [NSMutableArray array];
    
    if (self.showsCreateFolderButton) {
        UIBarButtonItem *createFolderButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create New Folder", @"Button to create a new folder")
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(createFolderButtonAction:)];
        [toolbarItems addObject:createFolderButtonItem];
    }
    
    if (self.showsChooseFolderButton) {
        UIBarButtonItem *chooseFolderButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Choose", @"Button to indicate that the folder being displayed was chosen")
                                                                                   style:UIBarButtonItemStyleDone
                                                                                  target:self
                                                                                  action:@selector(chooseFolderButtonAction:)];
        [toolbarItems addObject:chooseFolderButtonItem];
    }
    
    // Re-adjust spacing through spacer button items.
    UIBarButtonItem *spacerButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
    NSMutableArray *spacedToolbarItems = [NSMutableArray array];
    if (toolbarItems.count > 1) {
        [toolbarItems enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            [spacedToolbarItems addObject:object];
            if (idx < toolbarItems.count - 1) {
                [spacedToolbarItems addObject:spacerButtonItem];
            }
        }];
    } else if (toolbarItems.count == 1) {
        spacedToolbarItems = [NSMutableArray arrayWithArray:@[spacerButtonItem, [toolbarItems firstObject], spacerButtonItem]];
    }
    
    self.navigationController.toolbarHidden = toolbarItems.count <= 0;
    self.toolbarItems = spacedToolbarItems;
}

- (void)createFolderButtonAction:(id)sender
{
    BOXCreateFolderViewController *createFolderViewController = [[BOXCreateFolderViewController alloc] initWithContentClient:self.contentClient parentFolderID:self.folderID completion:^(BOXFolder *folder, NSError *error) {
        [self refresh];
        BOXFolderViewController *folderBrowserViewController = [[BOXFolderViewController alloc] initWithContentClient:self.contentClient folder:folder];
        folderBrowserViewController.showsChooseFolderButton = self.showsChooseFolderButton;
        folderBrowserViewController.showsCreateFolderButton = self.showsCreateFolderButton;
        folderBrowserViewController.showsSearchBar = self.showsSearchBar;
        [self.navigationController pushViewController:folderBrowserViewController animated:YES];

        if ([self.folderBrowserDelegate respondsToSelector:@selector(didCreateNewFolder:)]) {
            [self.folderBrowserDelegate didCreateNewFolder:folder];
        }
    }];
    [self.navigationController pushViewController:createFolderViewController animated:YES];
}

- (void)chooseFolderButtonAction:(id)sender
{
    if ([self.folderBrowserDelegate respondsToSelector:@selector(didTapChooseFolderButton:)]) {
        [self.folderBrowserDelegate didTapChooseFolderButton:self.folder];
    }
}

#pragma mark - data

- (void)fetchItemsWithCompletion:(void (^)(NSArray *items))completion
{
    [self setupToolbar];
    [[self.contentClient folderInfoRequestWithID:self.folderID] performRequestWithCompletion:^(BOXFolder *folder, NSError *error) {
        if (error) {
            [self didFailToLoadItemsWithError:error];
            self.navigationController.toolbarHidden = YES;
        } else {
            self.folder = folder;
            [self fetchItemsInFolder:self.folder withCompletion:^(NSArray *items, NSError *error) {
                if (error == nil) {
                    self.title = self.folder.name;
                    completion(items);
                } else {
                    self.navigationController.toolbarHidden = YES;
                    [self didFailToLoadItemsWithError:error];
                }
                
                if (self.tableView.visibleCells.count < 1) {
                    [self switchToEmptyStateWithError:error];
                    self.searchController.searchBar.hidden = YES;
                } else {
                    [self switchToNonEmptyView];
                    self.searchController.searchBar.hidden = NO;
                }
            }];
        }
    }];
}

- (void)fetchItemsInFolder:(BOXFolder *)folder withCompletion:(void (^)(NSArray *items, NSError *error))completion
{
    BOXFolderItemsRequest *request = [self.contentClient folderItemsRequestWithID:folder.modelID];
    [request setRequestAllItemFields:YES];
    [request performRequestWithCompletion:^(NSArray *items, NSError *error) {
        if (completion) {
            completion(items, error);
        }
    }];
}

- (void)switchToEmptyStateWithError:(NSError *)error
{
    // No error means it's just an empty folder.
    if (error == nil) {
        ((UILabel *)self.tableView.backgroundView).text = NSLocalizedString(@"This folder is empty", @"Label: Label displayed when the current folder is empty");
    } else {
        ((UILabel *)self.tableView.backgroundView).text = NSLocalizedString(@"Unable to load contents of folder.", @"Label: Label displayed when the current folder is empty");
    }
    self.tableView.backgroundView.hidden = NO;
}

- (void)switchToNonEmptyView
{
    self.tableView.backgroundView.hidden = YES;
}

- (void)didFailToLoadItemsWithError:(NSError *)error
{
    if (self.tableView.visibleCells.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = NSLocalizedString(@"Unable to load contents of folder.", @"Error message shown when a folder's contents could not be loaded.");
            hud.mode = MBProgressHUDModeCustomView;
            hud.removeFromSuperViewOnHide = YES;
            [hud show:YES];
            [hud hide:YES afterDelay:3.0];
        });
    }
}

@end
