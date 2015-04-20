//
//  BOXSearchResultsViewController.m
//  BoxBrowseSDK
//
//  Created by Rico Yao on 4/3/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import "BOXSearchResultsViewController.h"
#import "BOXFolderViewController.h"

@interface BOXSearchResultsViewController ()

@property (nonatomic, readwrite, strong) NSString *searchString;
@property (nonatomic, readwrite, strong) NSString *folderID;
@property (nonatomic, readwrite, strong) BOXSearchRequest *searchRequest;

@end

@implementation BOXSearchResultsViewController


- (void)performSearchForSearchString:(NSString *)searchString inFolderID:(NSString *)folderID
{
    self.searchString = searchString;
    self.folderID = folderID;
    [self refresh];
}

- (void)dealloc
{
    [self.searchRequest cancel];
    self.searchRequest = nil;
}

- (void)fetchItemsWithCompletion:(void (^)(NSArray *))completion
{
    [self.searchRequest cancel];
    
    self.searchRequest = [self.contentClient searchRequestWithQuery:self.searchString inRange:NSMakeRange(0, 1000)];
    self.searchRequest.ancestorFolderIDs = @[self.folderID];
    [self.searchRequest performRequestWithCompletion:^(NSArray *items, NSUInteger totalCount, NSRange range, NSError *error) {
        if (error) {
            // TODO
        } else {
            completion(items);
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    // Folder
    BOXItem *item = [self itemForRowAtIndexPath:indexPath];
    if (item.isFolder) {
        BOXFolder *folder = (BOXFolder *)item;
        BOOL shouldNavigateToFolder = YES;
        if ([self.folderBrowserDelegate respondsToSelector:@selector(itemsViewController:willNavigateToFolder:)]) {
            shouldNavigateToFolder = [self.folderBrowserDelegate itemsViewController:self willNavigateToFolder:folder];
        }
        if (shouldNavigateToFolder) {
            BOXFolderViewController *viewController = [[BOXFolderViewController alloc] initWithContentClient:self.contentClient folder:folder];
            viewController.showsCloseButton = self.showsCloseButton;
            viewController.delegate = self.folderBrowserDelegate;
            if ([[self class] isKindOfClass:[BOXFolderViewController class]]) {
                viewController.showsChooseFolderButton = ((BOXFolderViewController *)self).showsChooseFolderButton;
                viewController.showsCreateFolderButton = ((BOXFolderViewController *)self).showsCreateFolderButton;
                viewController.showsSearchBar = ((BOXFolderViewController *)self).showsSearchBar;
                viewController.showsDeleteButtons = ((BOXFolderViewController *)self).showsDeleteButtons;
            }
            
            
            self.navigationItem.backBarButtonItem.title = folder.parentFolder.name;
            [self.presentingViewController.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (id<BOXFolderViewControllerDelegate>)folderBrowserDelegate
{
    if ([self.delegate conformsToProtocol:@protocol(BOXFolderViewControllerDelegate)]) {
        return (id<BOXFolderViewControllerDelegate>)self.delegate;
    } else {
        return nil;
    }
}

@end
