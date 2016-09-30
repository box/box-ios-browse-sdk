//
//  UIImage+BOXBrowseSDKAdditions.h
//  BoxBrowseSDK
//
//  Created by Rico Yao on 3/30/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BOXItem;

@interface UIImage (BOXBrowseSDKAdditions)

/**
 * Returns an item's corresponding default icon
 *
 * @return An icon corresponding to the item's file type
 */
+ (UIImage *)box_iconForItem:(BOXItem *)item;

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
 * Returns a default icon for a generic file
 *
 * @return A default file icon
 */
+ (UIImage *)box_genericFileIcon;

@end
