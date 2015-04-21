///
//  BOXItemsViewControllerTableViewController.m
//  BoxBrowseSDK
//
//  Created by Rico Yao on 4/2/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import "BOXItemsViewController.h"
#import "BOXItemCell.h"
#import "BOXFolderViewController.h"

@interface BOXItemsViewController ()

@property (nonatomic, readwrite, strong) NSArray *items;

@end

@implementation BOXItemsViewController

- (instancetype)initWithContentClient:(BOXContentClient *)contentClient
{
    if (self = [super init]) {
        _contentClient = contentClient;
    }
    return self;
}

- (void)fetchItemsWithCompletion:(void (^)(NSArray *items))completion
{
    BOXAbstract();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // eliminate extra separators
    
    [self setupNavigationBar];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.contentClient.user == nil) {
        BOXAuthorizationViewController *authViewController = [[BOXAuthorizationViewController alloc] initWithSDKClient:self.contentClient completionBlock:^(BOXAuthorizationViewController *authorizationViewController, BOXUser *user, NSError *error) {
            [authorizationViewController dismissViewControllerAnimated:YES completion:^{
                [self refresh];
            }];
        } cancelBlock:^(BOXAuthorizationViewController *authorizationViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [self presentViewController:authViewController animated:YES completion:nil];
    } else {
        [self refresh];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BOXItemCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOXItem *item = [self.items objectAtIndex:indexPath.row];
    
    BOXItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"box-item-cell"];
    if (cell == nil) {
        cell = [[BOXItemCell alloc] initWithContentClient:self.contentClient style:UITableViewCellStyleSubtitle reuseIdentifier:@"box-item-cell"];
    }
    
    cell.item = item;
    
    if ([self.delegate respondsToSelector:@selector(itemsViewController:shouldEnableItem:)]) {
        cell.enabled = [self.delegate itemsViewController:self shouldEnableItem:item];
    } else {
        cell.enabled = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Folder
    BOXItem *item = [self itemForRowAtIndexPath:indexPath];
    if (item.isFolder) {
        BOXFolder *folder = (BOXFolder *)item;
        if ([self.delegate respondsToSelector:@selector(itemsViewController:didTapFolder:inItems:)]) {
            [self.delegate itemsViewController:self didTapFolder:folder inItems:self.items];
        }
    }
    
    // File
    else if (item.isFile) {
        BOXFile *file = (BOXFile *)item;
        if ([self.delegate respondsToSelector:@selector(itemsViewController:didTapFile:inItems:)]) {
            [self.delegate itemsViewController:self didTapFile:file inItems:self.items];
        }
    }
    
    // Bookmark
    else if (item.isBookmark) {
        BOXBookmark *bookmark = (BOXBookmark *)item;
        if ([self.delegate respondsToSelector:@selector(itemsViewController:didTapBookmark:inItems:)]) {
            [self.delegate itemsViewController:self didTapBookmark:bookmark inItems:self.items];
        }
    }
}

- (BOXItem *)itemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.items.count <= indexPath.row) {
        return nil;
    }

    return (BOXItem *)[self.items objectAtIndex:indexPath.row];
}

#pragma mark - Navbar

- (void)setupNavigationBar
{
    // Close Button
    BOOL shouldShowCloseButton = YES;
    if ([self.delegate respondsToSelector:@selector(itemsViewControllerShouldShowCloseButton:)]) {
        shouldShowCloseButton = [self.delegate itemsViewControllerShouldShowCloseButton:self];
    }
    
    if (shouldShowCloseButton) {
        UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Title : button closing the folder picker")
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(closeButtonAction:)];
        [closeBarButtonItem setTitlePositionAdjustment:UIOffsetMake(0.0, 1)
                                         forBarMetrics:UIBarMetricsDefault];
        self.navigationItem.rightBarButtonItem = closeBarButtonItem;
    }
}

- (void)closeButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(itemsViewControllerDidTapCloseButtton:)]) {
        [self.delegate itemsViewControllerDidTapCloseButtton:self];
    } else {
        [[self navigationController] dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - data

- (void)refresh
{
    [self fetchItemsWithCompletion:^(NSArray *items) {
        items = [self filterItems:items];
        items = [self sortItems:items];
        
        self.items = items;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (NSArray *)sortItems:(NSArray *)items
{
    NSArray *sortedItems = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                            {
                                NSComparisonResult order = NSOrderedSame;
                                BOXItem *itemA = (BOXItem*) obj1;
                                BOXItem *itemB = (BOXItem*) obj2;
                                
                                if ([self.delegate respondsToSelector:@selector(itemsViewController:compareForSortingItem:toItem:)]) {
                                    order = [self.delegate itemsViewController:self compareForSortingItem:itemA toItem:itemB];
                                } else {
                                    // Folders come first
                                    if (itemA.isFolder && !itemB.isFolder) {
                                        order = NSOrderedAscending;
                                    } else if (!itemA.isFolder && itemB.isFolder) {
                                        order = NSOrderedDescending;
                                        
                                        // Then we go by date descending
                                    } else {
                                        order = [itemB.contentModifiedDate compare:itemA.contentModifiedDate];
                                    }
                                }
                                
                                // If still no order defined, do alphabetical
                                if (order == NSOrderedSame) {
                                    order = [itemA.name compare:itemB.name options:NSCaseInsensitiveSearch];
                                }
                                
                                return order;
                            }];
    
    return sortedItems;
}

- (NSArray *)filterItems:(NSArray *)items
{
    if ([self.delegate respondsToSelector:@selector(itemsViewController:shouldShowItem:)]) {
        NSArray *filteredArray = [items objectsAtIndexes:[items indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            BOXItem *item = (BOXItem*) obj;
            return [self.delegate itemsViewController:self shouldShowItem:item];
        }]];
        return filteredArray;
    } else {
        return items;
    }
}

@end
