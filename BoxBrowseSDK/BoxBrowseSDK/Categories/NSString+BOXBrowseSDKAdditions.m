//
//  NSString+BOXBrowseSDKAdditions.m
//  Pods
//
//  Created by Andrew Dempsey on 12/2/15.
//
//

#import "NSString+BOXBrowseSDKAdditions.h"

@implementation NSString (BOXBrowseSDKAdditions)

- (NSString *)pathExtensionAccountingForZippedPackages
{
    NSString *extension = nil;

    if ([self fileNameHasTwoFileExtensions]) {
        extension = [[self stringByDeletingPathExtension] pathExtension];
    } else {
        extension = [self pathExtension];
    }

    return extension;
}

- (BOOL)fileNameHasTwoFileExtensions
{
    // 5 cases : .pages.zip, .key.zip, .keynote.zip, .numbers.zip, .rtfd.zip.
    if ([[self pathExtension] isEqualToString:@"zip"]) {
        NSString *truncatedName = [self stringByDeletingPathExtension];

        if ([[truncatedName pathExtension] isEqualToString:@"pages"] ||
            [[truncatedName pathExtension] isEqualToString:@"key"] ||
            [[truncatedName pathExtension] isEqualToString:@"keynote"] ||
            [[truncatedName pathExtension] isEqualToString:@"numbers"] ||
            [[truncatedName pathExtension] isEqualToString:@"rtfd"]) {
            return YES;
        }
    }

    return NO;
}

@end
