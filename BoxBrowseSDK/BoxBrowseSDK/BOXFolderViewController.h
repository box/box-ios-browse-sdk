//
//  BOXBrowseTableViewController.h
//  BoxBrowseSDK
//
//  Created by Rico Yao on 3/25/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BOXItemsViewController.h"

@protocol BOXFolderViewControllerDelegate;

@interface BOXFolderViewController : BOXItemsViewController

- (instancetype)initWithContentClient:(BOXContentClient *)contentClient
                             folderID:(NSString *)folderID;

- (instancetype)initWithContentClient:(BOXContentClient *)contentClient
                               folder:(BOXFolder *)folder;

/**
 *  Defaults to YES. If YES, a search bar will be shown as a table header view to allow users to search for content within the 
 *  folder that is being viewed.
 */
@property (nonatomic, readwrite, assign) BOOL showsSearchBar;

/**
 *  Defaults to NO. If YES, a toolbar button item will be added that allows users to "Choose" the folder they are currently viewing.
 *  This could be useful if you are asking users to choose a folder from Box.
 *  The chosen folder will be returned through 'didTapChooseFolderButton:'.
 */
@property (nonatomic, readwrite, assign) BOOL showsChooseFolderButton;

/**
 *  Defaults to NO. If YES, a toolbar button item will be added that allows users to create a new folder in the folder they are currently viewing.
 *  By default, this button will not be shown.
 *  A newly created folder will be returned through 'didCreateNewFolder:'
 */
@property (nonatomic, readwrite, assign) BOOL showsCreateFolderButton;

/**
 *  The flag that sets whether deletion is allowed by user. Default to YES.
 *  If YES, a delete button is exposed when an item row is swiped.
 */
@property (nonatomic, readwrite, assign) BOOL showsDeleteButtons;

@end

@protocol BOXFolderViewControllerDelegate <BOXItemsViewControllerDelegate>

@optional

/**
 *  Implement to control whether the user should be navigated to a folder.
 *
 *  @param folder The folder that the user would be navigated to.
 *
 *  @return YES to allow the navigation to proceed, false otherwise.
 */
- (BOOL)willNavigateToFolder:(BOXFolder *)folder;

/**
 *  If the choose button is shown (see 'shouldShowChooseFolderButton'), this will be called when the user has tapped the button to
 *  select the folder currently displayed.
 *
 *  @param folder The Folder that the user was viewing when the Choose button was tapped.
 */
- (void)didTapChooseFolderButton:(BOXFolder *)folder;

/**
 *  A folder was created.
 *
 *  @param folder The created folder.
 */
- (void)didCreateNewFolder:(BOXFolder *)folder;

/**
 *  A Box item was deleted.
 *
 *  @param item The deleted item.
 */
- (void)didDeleteItem:(BOXItem *)item;

@end
