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

+ (UIImage *)box_imageFromBrowseSDKResourceBundleNamed:(NSString *)name
{
    UIImage *imageFromBundle = nil;
    NSBundle *bundle = [self resourcesBundle];

    if ([self respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        imageFromBundle = [self imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        NSString *path = [[bundle resourcePath] stringByAppendingPathComponent:[bundle pathForResource:name ofType:nil]];

        NSString *fileName = nil;
        if ([UIScreen mainScreen].scale == 2.0) {
            fileName = [NSString stringWithFormat:@"%@@2x.png", name];
        } else {
            fileName = [NSString stringWithFormat:@"%@.png", name];
        }
        path = [path stringByAppendingPathComponent:fileName];
        imageFromBundle = [UIImage imageWithContentsOfFile:path];
    }

    return imageFromBundle;
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

+ (NSBundle *)resourcesBundle
{
    static NSBundle *frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        frameworkBundle = [NSBundle bundleForClass:[BOXBrowseSDKBundleHelper class]];
    });
    
    return frameworkBundle;
}

@end
