//
//  BOXItemsViewControllerTableViewController.h
//  BoxBrowseSDK
//
//  Created by Rico Yao on 4/2/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxContentSDK/BOXContentSDK.h>

@protocol BOXItemsViewControllerDelegate;

@interface BOXItemsViewController : UITableViewController

@property (nonatomic, readwrite, weak) id<BOXItemsViewControllerDelegate> delegate;

@property (nonatomic, readonly, strong) BOXContentClient *contentClient;

- (instancetype)initWithContentClient:(BOXContentClient *)contentClient;

- (void)fetchItemsWithCompletion:(void (^)(NSArray *items))completion;

- (void)refresh;

- (BOXItem *)itemForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol BOXItemsViewControllerDelegate <NSObject>

@optional

/**
 *  By default, all items will be shown. Implement this to hide certain items.
 *  For example, if you only want to show folders, than return false for any item where
 *  item.isFolder is false.
 *
 *  @param item The item to show or not show.
 *
 *  @return YES to show the item, NO to exclude it.
 */
- (BOOL)shouldShowItem:(BOXItem *)item;

/**
 *  By default, all items will be enabled to be selected by the user.
 *  Implement to disable some items from being shown.
 *
 *  @param item The item to enable or disable.
 *
 *  @return YES to allow the item to be selected. NO otherwise.
 */
- (BOOL)shouldEnableItem:(BOXItem *)item;

/**
 *  Implement this if you want to customize the sort order of items. By default items will be sorted with the following ordered rules:
 *  - Folders come before files and weblinks.
 *  - Most recently modified items come first.
 *  - Alphabetical.
 *
 *  @param itemA Item to compare.
 *  @param itemB Item to compare.
 *
 *  @return Return NSOrderedAscending to have itemA displayed before itemB. Return NSOrderedDescending to have itemB displayed before itemA.
 */
- (NSComparisonResult)compareForSortingItem:(BOXItem *)itemA toItem:(BOXItem *)itemB;

/**
 *  The user tapped on a Folder from the list.
 *
 *  @param folder The folder the user selected.
 *  @param items The list of items that the tap occured from. The array will include the tapped item itself.
 *
 *  @return Whether or not to navigate to the folder. If YES, the user will be taken into the folder.
 */
- (void)didTapFolder:(BOXFolder *)folder inItems:(NSArray *)items;

/**
 *  The user tapped on a File from the list.
 *
 *  @param file The file the user selected.
 *  @param items The list of items that the tap occured from. The array will include the tapped item itself.
 */
- (void)didTapFile:(BOXFile *)file inItems:(NSArray *)items;

/**
 *  The user tapped on a Bookmark from the list.
 *
 *  @param file The bookmark the user selected.
 *  @param items The list of items that the tap occured from. The array will include the tapped item itself.
 */
- (void)didTapBookmark:(BOXBookmark *)bookmark inItems:(NSArray *)items;

/**
 *  Close button was tapped. If not implemented, the navigation controller will be dismissed.
 */
- (void)didTapCloseButton;

@end
