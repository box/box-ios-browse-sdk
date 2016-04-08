//
//  NSBundle+BOXBrowseSDKAdditions.m
//  Pods
//
//  Created by Andrew Dempsey on 12/29/15.
//
//

#import "NSBundle+BOXBrowseSDKAdditions.h"
#import "BOXBrowseSDKResourceLocator.h"

@implementation NSBundle (BOXBrowseSDKAdditions)

+ (NSBundle *)boxBrowseSDKResourcesBundle
{
    NSBundle *browseSDKBundle = [NSBundle bundleForClass:[BOXBrowseSDKResourceLocator class]];
    NSString *browseSDKResourceBundlePath = [browseSDKBundle.bundlePath stringByAppendingPathComponent:@"BoxBrowseSDKResources.bundle"];
    NSBundle *browseSDKResourceBundle = [NSBundle bundleWithPath:browseSDKResourceBundlePath];
    return browseSDKResourceBundle;
}

@end
