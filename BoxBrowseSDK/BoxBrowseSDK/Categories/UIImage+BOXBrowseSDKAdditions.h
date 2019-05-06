//
//  UIImage+BOXBrowseSDKAdditions.h
//  BoxBrowseSDK
//
//  Created by Rico Yao on 3/30/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class BOXItem;

@interface UIImage (BOXBrowseSDKAdditions)

/**
 * Returns an item's corresponding default icon
 *
 * @return An icon corresponding to the item's file type
 */
+ (UIImage *)box_iconForItem:(BOXItem *)item;

/**
 * Returns an item's corresponding default icon (smaller size)
 *
 * @return An icon corresponding to the item's file type
 */
+ (UIImage *)box_smallIconForItem:(BOXItem *)item;


/**
 * Returns an image with the appropriate scale factor given the device.
 *
 * @return An image with the appropriate scale.
 */
- (UIImage *)box_imageAtAppropriateScaleFactor;

/**
 * Returns a default icon for a given corresponding filename with extension
 *
 @param fileName Name of the file requiring an icon

 @return An icon corresponding to the item's file type
 */
+ (UIImage *)box_iconForFileName:(NSString *)fileName;

/**
 * Returns a default icon for a generic file. If you have a BoxItem
 * use box_iconForItem:item to get the correct icon for the item.
 *
 * @return A default file icon
 */
+ (UIImage *)box_genericFileIcon;

/**
 * Returns a default icon for a generic folder. If you have a BoxItem
 * use box_iconForItem:item to get the correct icon for the item.
 *
 * @return A default folder icon
 */
+ (UIImage *)box_genericFolderIcon;

/**
 * Returns a default icon for a shared (aka collaborated) folder. If you have a BoxItem
 * use box_iconForItem:item to get the correct icon for the item.
 *
 * @return A default folder icon
 */
+ (UIImage *)box_sharedFolderIcon;

/**
 * Returns a default icon for an external folder. If you have a BoxItem
 * use box_iconForItem:item to get the correct icon for the item.
 *
 * @return A default folder icon
 */
+ (UIImage *)box_externalFolderIcon;

/**
 * Returns a default icon for a generic file (smaller size). If you have a BoxItem
 * use box_iconForItem:item to get the correct icon for the item.
 *
 * @return A default file icon
 */
+ (UIImage *)box_smallGenericFileIcon;

/**
 * Returns a default icon for a generic folder (smaller size). If you have a BOXItem
 * use box_iconForItem:item to get the correct icon for the item.
 *
 * @return A default folder icon
 */
+ (UIImage *)box_smallGenericFolderIcon;

/**
 * Returns a default icon for a shared (aka collaborated) folder (smaller size). If you have a BoxItem
 * use box_iconForItem:item to get the correct icon for the item.
 *
 * @return A default folder icon
 */
+ (UIImage *)box_smallSharedFolderIcon;

/**
 * Returns a default icon for an external folder (smaller size). If you have a BoxItem
 * use box_iconForItem:item to get the correct icon for the item.
 *
 * @return A default folder icon
 */
+ (UIImage *)box_smallExternalFolderIcon;

@end

NS_ASSUME_NONNULL_END
