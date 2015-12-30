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
    static NSBundle *browseSDKResourceBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSBundle *browseSDKBundle = [NSBundle bundleForClass:[BOXBrowseSDKResourceLocator class]];
        NSString *browseSDKResourceBundlePath = [browseSDKBundle.bundlePath stringByAppendingPathComponent:@"BoxBrowseSDKResources.bundle"];
        browseSDKResourceBundle = [NSBundle bundleWithPath:browseSDKResourceBundlePath];
    });

    return browseSDKResourceBundle;
}

@end
