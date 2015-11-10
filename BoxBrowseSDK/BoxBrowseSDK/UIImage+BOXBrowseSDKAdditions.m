//
//  UIImage+BOXBrowseSDKAdditions.m
//  BoxBrowseSDK
//
//  Created by Rico Yao on 3/30/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import "UIImage+BOXBrowseSDKAdditions.h"
#import "BOXBrowseSDKBundleHelper.h"

@implementation UIImage (BOXBrowseSDKAdditions)

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
