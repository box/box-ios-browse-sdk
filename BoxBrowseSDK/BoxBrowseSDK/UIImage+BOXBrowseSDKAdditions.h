//
//  UIImage+BOXBrowseSDKAdditions.h
//  BoxBrowseSDK
//
//  Created by Rico Yao on 3/30/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BOXBrowseSDKAdditions)

/**
 * Returns an image with the appropriate scale factor given the device.
 *
 * @return An image with the appropriate scale.
 */
- (UIImage *)box_imageAtAppropriateScaleFactor;

@end
