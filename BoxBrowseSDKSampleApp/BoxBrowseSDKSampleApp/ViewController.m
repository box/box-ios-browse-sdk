//
//  ViewController.m
//  BoxBrowseSDKSampleApp
//
//  Created by Rico Yao on 3/24/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <BOXFolderViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Show a UIViewController that
    BOXFolderViewController *folderViewController = [[BOXFolderViewController alloc] initWithContentClient:[BOXContentClient defaultClient]];
    folderViewController.delegate = self;
    folderViewController.showsCreateFolderButton = YES;
    folderViewController.showsChooseFolderButton = YES;
    folderViewController.showsSearchBar = YES;
    
    // You must load it in a UINavigationController.
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:folderViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - BOXFolderViewControllerDelegate

- (void)didTapFolder:(BOXFolder *)folder inItems:(NSArray *)items
{
    NSLog(@"Did tap folder: %@", folder.name);
    return;
}

- (void)didTapFile:(BOXFile *)file inItems:(NSArray *)items
{
    NSLog(@"Did tap file: %@", file.name);
    return;
}

- (void)didTapChooseFolderButton:(BOXFolder *)folder
{
    NSLog(@"Did choose folder: %@", folder.name);
    return;
}

- (void)didCreateNewFolder:(BOXFolder *)folder
{
    NSLog(@"Did create new folder: %@", folder.name);
    return;
}

@end
