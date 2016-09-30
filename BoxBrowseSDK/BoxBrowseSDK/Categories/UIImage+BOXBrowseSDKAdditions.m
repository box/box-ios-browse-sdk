//
//  UIImage+BOXBrowseSDKAdditions.m
//  BoxBrowseSDK
//
//  Created by Rico Yao on 3/30/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

@import BoxContentSDK;

#import "UIImage+BOXBrowseSDKAdditions.h"
#import "NSBundle+BOXBrowseSDKAdditions.h"

@implementation UIImage (BOXBrowseSDKAdditions)

#pragma mark - Public Methods

+ (UIImage *)box_iconForItem:(BOXItem *)item
{
    NSBundle *browseResourceBundle = [NSBundle boxBrowseSDKResourcesBundle];

    UIImage *icon = nil;

    if (item.isFolder) {
        BOXFolder *folder = (BOXFolder *)item;
        if (folder.isExternallyOwned == BOXAPIBooleanYES) {
            icon = [UIImage box_iconWithName:@"External"];

        } else if (folder.hasCollaborations == BOXAPIBooleanYES) {
            icon = [UIImage box_iconWithName:@"shared_folder"];

        } else {
            icon = [UIImage box_iconWithName:@"Personal"];

        }
    } else if (item.isFile) {
        icon = [UIImage box_iconForFileName:item.name];

    } else if (item.isBookmark) {
        icon = [UIImage box_iconWithName:@"Linked"];

    }

    return icon;
}

+ (UIImage *)box_iconForFileName:(NSString *)fileName
{
    NSString *fileExtension = [fileName box_pathExtensionAccountingForZippedPackages].lowercaseString;
    NSString *iconName = [self iconNameForFileExtension:fileExtension];

    UIImage *image = [UIImage box_iconWithName:iconName];

    if (image == nil) {
        image = [UIImage box_genericFileIcon];
    }

    return image;
}

+ (UIImage *)box_genericFileIcon
{
    return [UIImage box_iconWithName:@"icon-file-generic"];
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

#pragma mark - Private Methods

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

+ (NSString *)iconNameForFileExtension:(NSString *)fileExtension
{
    NSString *iconName = nil;
    if ([[self audioFileExtensions] containsObject:fileExtension])  {
        iconName = @"Audio";
    }
    else if ([[self imageFileExtensions] containsObject:fileExtension]) {
        iconName = @"Image";
    }
    else if ([[self videoFileExtensions] containsObject:fileExtension]) {
        iconName = @"Movie";
    }
    else if ([[self docFileExtensions] containsObject:fileExtension]) {
        iconName = @"Word";
    }
    else if ([[self codeFileExtensions] containsObject:fileExtension]) {
        iconName = @"Code";
    }
    else if ([[self textFileExtensions] containsObject:fileExtension]) {
        iconName = @"Doc";
    }
    else if ([[self presentationFileExtensions] containsObject:fileExtension]) {
        iconName = @"Presentation";
    }
    else if ([[self sheetFileExtensions] containsObject:fileExtension]) {
        iconName = @"Spreadsheet";
    }
    else if ([[self compressedFileExtensions] containsObject:fileExtension]) {
        iconName = @"Compressed";
    }
    else if ([[self vectorImageFileExtensions] containsObject:fileExtension]) {
        iconName = @"Vector";
    }
    else if ([fileExtension isEqualToString:@"boxnote"]) {
        iconName = @"Box Note";
    }
    else if ([fileExtension isEqualToString:@"ai"]) {
        iconName = @"Illustrator";
    }
    else if ([fileExtension isEqualToString:@"indd"]) {
        iconName = @"InDesign";
    }
    else if ([fileExtension isEqualToString:@"pdf"]) {
        iconName = @"PDF";
    }
    else if ([fileExtension isEqualToString:@"psd"]) {
        iconName = @"Photoshop";
    }
    
    return iconName;
}

+ (NSSet *)audioFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"aac",@"aiff", @"m3u", @"m4a", @"mid", @"mp3", @"wav", @"wpl", @"wma", nil];
    }
    
    return extensions;
}

+ (NSSet *)imageFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"bmp",@"dcm", @"gdraw", @"gif", @"jpeg", @"jpg", @"tiff", nil];
    }
    
    return extensions;
}

+ (NSSet *)vectorImageFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"eps",@"svg", nil];
    }
    
    return extensions;
}

+ (NSSet *)videoFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"avi",@"flv", @"m4v", @"mov", @"mp4", @"mpeg", @"mpg", @"qt", @"wmv", nil];
    }
    
    return extensions;
}

+ (NSSet *)docFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"doc",@"docx", @"dot", @"dotx", @"gdoc", @"odt", @"ott", @"pages", @"rtf", nil];
    }
    
    return extensions;
}

+ (NSSet *)codeFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"aspx",@"c", @"c++", @"cpp", @"css", @"htm", @"html", @"java", @"js", @"php", @"scala", @"webba", @"xhtml", @"xml", nil];
    }
    
    return extensions;
}

+ (NSSet *)textFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"markdown",@"md", @"mdown", @"txt", nil];
    }
    
    return extensions;
}

+ (NSSet *)compressedFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"rar",@"zip", @"tgz", nil];
    }
    
    return extensions;
}

+ (NSSet *)presentationFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"gslide",@"key", @"opd", @"otp", @"pot", @"potx", @"ppt", @"pptx", nil];
    }
    
    return extensions;
}

+ (NSSet *)sheetFileExtensions
{
    static NSSet *extensions = nil;
    
    if (extensions == nil) {
        extensions = [NSSet setWithObjects:@"csv",@"gsheet", @"numbers", @"ods", @"ots", @"xls", @"xlsx", @"xlt", @"xltx", nil];
    }
    
    return extensions;
}

@end
