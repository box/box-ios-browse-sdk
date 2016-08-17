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
    UIImage *icon = nil;

    if (item.isFolder) {
        BOXFolder *folder = (BOXFolder *)item;
        if (folder.isExternallyOwned == BOXAPIBooleanYES) {
            icon = [UIImage box_iconWithName:@"icon-folder-external"];
        } else if (folder.hasCollaborations == BOXAPIBooleanYES) {
            icon = [UIImage box_iconWithName:@"icon-folder-shared"];
        } else {
            icon = [UIImage box_iconWithName:@"icon-folder"];
        }
    } else if (item.isFile) {
        icon = [UIImage box_iconForFileName:item.name];

        if (icon == nil) {
            icon = [UIImage box_genericFileIcon];
        }
    } else if (item.isBookmark) {
        icon = [UIImage box_iconWithName:@"icon-file-weblink"];
    }

    return icon;
}

+ (UIImage *)box_iconForFileName:(NSString *)fileName
{
    NSString *fileExtension = [fileName pathExtensionAccountingForZippedPackages].lowercaseString;
    NSString *imageName = [NSString stringWithFormat:@"icon-file-%@", fileExtension];

    return [UIImage box_iconWithName:imageName];
}

+ (UIImage *)box_genericFileIcon
{
    return [UIImage box_iconWithName:@"icon-file-generic"];
}

+ (UIImage *)box_iconWithName:(NSString *)name
{
    UIImage *icon = nil;
    NSBundle *browseSDKResourceBundle = [NSBundle boxBrowseSDKResourcesBundle];

    @synchronized (browseSDKResourceBundle) {
        icon = [UIImage imageNamed:name
                          inBundle:browseSDKResourceBundle
     compatibleWithTraitCollection:nil];
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
