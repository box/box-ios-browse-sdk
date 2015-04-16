//
//  UIImage+BOXBrowseSDKAdditions.m
//  BoxBrowseSDK
//
//  Created by Rico Yao on 3/30/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import "UIImage+BOXBrowseSDKAdditions.h"

@implementation UIImage (BOXBrowseSDKAdditions)

+ (UIImage *)imageFromBrowseSDKResourceBundleNamed:(NSString *)string
{
    NSString *str = [[[self resourcesBundle] resourcePath] stringByAppendingPathComponent:[[self resourcesBundle] pathForResource:string ofType:nil]];
    return [UIImage imageWithContentsOfFile:[str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", string]]];
}

- (UIImage *)imageWith2XScaleIfRetina;
{
    UIImage *image = self;
    if ([UIScreen mainScreen].scale == 2.0)
    {
        image = [UIImage imageWithCGImage:image.CGImage scale:2.0f orientation:image.imageOrientation];
    }
    
    return image;
}

+ (NSBundle *)resourcesBundle
{
    static NSBundle *frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSURL *ressourcesBundleURL = [[NSBundle mainBundle] URLForResource:@"BoxBrowseSDKResources" withExtension:@"bundle"];
        frameworkBundle = [NSBundle bundleWithURL:ressourcesBundleURL];
    });
    
    return frameworkBundle;
}

@end
