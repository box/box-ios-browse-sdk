//
//  UIImage+BOXBrowseSDKAdditions.m
//  BoxBrowseSDK
//
//  Created by Rico Yao on 3/30/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import "UIImage+BOXBrowseSDKAdditions.h"
#import <BoxContentSDK/BoxContentSDK.h>
#import <BoxBrowseSDK/BoxBrowseSDK.h>
#import "NSString+BOXBrowseSDKAdditions.h"
#import "NSBundle+BOXBrowseSDKAdditions.h"

@implementation UIImage (BOXBrowseSDKAdditions)

+ (UIImage *)box_iconForItem:(BOXItem *)item
{
    NSBundle *browseResourceBundle = [NSBundle boxBrowseSDKResourcesBundle];

    UIImage *icon = nil;

    if (item.isFolder) {
        BOXFolder *folder = (BOXFolder *)item;
        if (folder.isExternallyOwned == BOXAPIBooleanYES) {
            icon = [UIImage imageNamed:@"icon-folder-external" inBundle:browseResourceBundle compatibleWithTraitCollection:nil];
        } else if (folder.hasCollaborations == BOXAPIBooleanYES) {
            icon = [UIImage imageNamed:@"icon-folder-shared" inBundle:browseResourceBundle compatibleWithTraitCollection:nil];
        } else {
            icon = [UIImage imageNamed:@"icon-folder" inBundle:browseResourceBundle compatibleWithTraitCollection:nil];
        }
    } else if (item.isFile) {
        NSString *extension = [item.name pathExtensionAccountingForZippedPackages].lowercaseString;
        NSString *imageName = [NSString stringWithFormat:@"icon-file-%@", extension];
        icon = [UIImage imageNamed:imageName inBundle:browseResourceBundle compatibleWithTraitCollection:nil];
        if (icon == nil) {
            icon = [UIImage imageNamed:@"icon-file-generic" inBundle:browseResourceBundle compatibleWithTraitCollection:nil];
        }
    } else if (item.isBookmark) {
        icon = [UIImage imageNamed:@"icon-file-weblink" inBundle:browseResourceBundle compatibleWithTraitCollection:nil];
    }

    return icon;
}

- (UIImage *)box_imageAtAppropriateScaleFactor
{
    UIImage *image = self;
    CGFloat scaleFactor = [UIScreen mainScreen].scale;
    if (scaleFactor != 1.0f) {
        image = [UIImage imageWithCGImage:image.CGImage scale:scaleFactor orientation:image.imageOrientation];
    }

    return image;
}

@end
