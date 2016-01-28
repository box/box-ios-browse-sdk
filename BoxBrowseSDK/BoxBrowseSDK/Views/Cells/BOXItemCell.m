//
//  BOXItemCell.m
//  BoxBrowseSDK
//
//  Created by Rico Yao on 3/30/15.
//  Copyright (c) 2015 BOX. All rights reserved.
//

#import "BOXItemCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "BOXThumbnailCache.h"
#import "UIImage+BOXBrowseSDKAdditions.h"
#import "NSString+BOXBrowseSDKAdditions.h"
#import "BOXItem+BOXBrowseSDKAdditions.h"

long long const BOX_BROWSE_SDK_KILOBYTE = 1024;
long long const BOX_BROWSE_SDK_MEGABYTE = BOX_BROWSE_SDK_KILOBYTE * 1024;
long long const BOX_BROWSE_SDK_GIGABYTE = BOX_BROWSE_SDK_MEGABYTE * 1024;
long long const BOX_BROWSE_SDK_TERABYTE = BOX_BROWSE_SDK_GIGABYTE * 1024;

CGFloat const BOXItemCellHeight = 60.0f;

#define kImageViewWidth 40.0
#define kImageHorizontalPadding 12.0
#define kDisabledAlphaValue 0.3f

#define kTextLabelColorEnabled [UIColor colorWithWhite:86.0f/255.0f alpha:1.0]
#define kTextLabelColorDisabled [UIColor colorWithWhite:86.0f/255.0f alpha:0.3]

#define kDetailTextLabelColorEnabled [UIColor colorWithWhite:174.0f/255.0f alpha:1.0]
#define kDetailTextLabelColorDisabled [UIColor colorWithWhite:174.0f/255.0f alpha:0.3]

@interface BOXItemCell ()

@property (nonatomic, readonly, strong) BOXContentClient *contentClient;
@property (nonatomic) BOXFileThumbnailRequest *thumbnailRequest;

@property (nonatomic, readwrite, strong) UIImageView *thumbnailImageView;

@end

@implementation BOXItemCell

- (id)initWithContentClient:(BOXContentClient *)contentClient
                      style:(UITableViewCellStyle)style
            reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _contentClient = contentClient;
        
        self.textLabel.font = [UIFont systemFontOfSize:17.0f];
        self.textLabel.textColor = kTextLabelColorEnabled;
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
        self.detailTextLabel.textColor = kDetailTextLabelColorEnabled;

        _thumbnailImageView = [[UIImageView alloc] init];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [self.thumbnailRequest cancel];
    self.thumbnailRequest = nil;
    _item = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.thumbnailImageView.frame = CGRectMake(0, (self.frame.size.height - kImageViewWidth) * 0.5f, kImageViewWidth + kImageHorizontalPadding * 2, kImageViewWidth);
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
    if (self.thumbnailImageView.superview == nil) {
        [self.contentView addSubview:self.thumbnailImageView];
    }
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = CGRectGetMaxX(self.thumbnailImageView.frame);
    textLabelFrame.size.width = CGRectGetMaxX(self.frame) - textLabelFrame.origin.x - kImageHorizontalPadding;
    self.textLabel.frame = textLabelFrame;
    
    CGRect detailTextLabelFrame = self.detailTextLabel.frame;
    detailTextLabelFrame.origin.x = CGRectGetMaxX(self.thumbnailImageView.frame);
    detailTextLabelFrame.size.width = CGRectGetMaxX(self.frame) - detailTextLabelFrame.origin.x - kImageHorizontalPadding;
    self.detailTextLabel.frame = detailTextLabelFrame;
}

// Cell separators get inset without this.
- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

- (void)setItem:(BOXItem *)item
{
    _item = item;
    
    // Name
    self.textLabel.text = item.name;
    
    // Description
    NSString *description = nil;
    if (item.isBookmark) {
        description = ((BOXBookmark *) item).URL.absoluteString;
    } else {
        description = [NSString stringWithFormat:@"%@, %@", [self displaySizeForItem:item], [self displayDateForItem:item]];
    }
    self.detailTextLabel.text = description;
    
    // Icon / thumbnail
    if ([self shouldShowThumbnailForItem:self.item] && item.isFile) {
        __block BOXFile *file = (BOXFile *)item;
        __weak BOXItemCell *me = self;
        BOXThumbnailCache *thumbnailCache = [BOXThumbnailCache sharedInstanceForContentClient:self.contentClient];
        BOXThumbnailSize thumbnailSize = BOXThumbnailSize128;
        
        if ([thumbnailCache hasThumbnailInCacheForFile:file size:thumbnailSize]) {
            self.thumbnailRequest = [thumbnailCache fetchThumbnailForFile:file size:BOXThumbnailSize128 completion:^(UIImage *image, NSError *error) {
                if ([me.item.modelID isEqualToString:file.modelID]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        me.thumbnailImageView.image = image;
                    });
                }
            }];
        } else {
            UIImageView *imageView = self.thumbnailImageView;
            imageView.image = [UIImage box_iconForItem:item];
            self.thumbnailRequest = [thumbnailCache fetchThumbnailForFile:file size:BOXThumbnailSize128 completion:^(UIImage *image, NSError *error) {
                if (error == nil) {
                    if ([me.item.modelID isEqualToString:file.modelID]) {
                        imageView.image = image;
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionFade;
                        [imageView.layer addAnimation:transition forKey:nil];
                    }
                }
            }];
        }
    } else {
        self.thumbnailImageView.image = [UIImage box_iconForItem:item];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    if (enabled) {
        self.userInteractionEnabled = YES;
        self.thumbnailImageView.alpha = 1.0f;
        self.textLabel.textColor = kTextLabelColorEnabled;
        self.detailTextLabel.textColor = kDetailTextLabelColorEnabled;
    } else {
        self.userInteractionEnabled = NO;
        self.thumbnailImageView.alpha = kDisabledAlphaValue;
        self.textLabel.textColor = kTextLabelColorDisabled;
        self.detailTextLabel.textColor = kDetailTextLabelColorDisabled;
    }
}

- (NSString *)displaySizeForItem:(BOXItem *)item
{
    NSString * result_str = nil;
    long long fileSize = [item.size longLongValue];
    
    if (fileSize >= BOX_BROWSE_SDK_TERABYTE)
    {
        double dSize = fileSize / (double)BOX_BROWSE_SDK_TERABYTE;
        result_str = [NSString stringWithFormat:NSLocalizedString(@"%1.1f TB", @"File size in terabytes (example: 1 TB)"), dSize];
    }
    else if (fileSize >= BOX_BROWSE_SDK_GIGABYTE)
    {
        double dSize = fileSize / (double)BOX_BROWSE_SDK_GIGABYTE;
        result_str = [NSString stringWithFormat:NSLocalizedString(@"%1.1f GB", @"File size in gigabytes (example: 1 GB)"), dSize];
    }
    else if (fileSize >= BOX_BROWSE_SDK_MEGABYTE)
    {
        double dSize = fileSize / (double)BOX_BROWSE_SDK_MEGABYTE;
        result_str = [NSString stringWithFormat:NSLocalizedString(@"%1.1f MB", @"File size in megabytes (example: 1 MB)"), dSize];
    }
    else if (fileSize >= BOX_BROWSE_SDK_KILOBYTE)
    {
        double dSize = fileSize / (double)BOX_BROWSE_SDK_KILOBYTE;
        result_str = [NSString stringWithFormat:NSLocalizedString(@"%1.1f KB", @"File size in kilobytes (example: 1 KB)"), dSize];
    }
    else if(fileSize > 0)
    {
        result_str = [NSString stringWithFormat:NSLocalizedString(@"%1.1f B", @"File size in bytes (example: 1 B)"), fileSize];
    }
    else
    {
        result_str = NSLocalizedString(@"Empty", @"File size 0 bytes");
    }
    
    return result_str;
}

- (NSString *)displayDateForItem:(BOXItem *)item
{
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[item effectiveUpdateDate]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    return dateString;
}

- (NSString *)UTIFromFilePath:(NSString *)filePath
{
    CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtensionAccountingForZippedPackages];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    NSString *strUTI = (__bridge_transfer NSString *)UTI;
    
    if(!strUTI) {
        return @"public.item";
    }
    
    return strUTI;
}

- (BOOL)UTI:(NSString *)UTI ConformsToUTI:(NSString *)anotherUTI
{
    CFStringRef UTIself = (__bridge CFStringRef) UTI;
    CFStringRef UTIother = (__bridge CFStringRef) anotherUTI;
    
    return UTTypeConformsTo(UTIself, UTIother);
}

- (BOOL)shouldShowThumbnailForItem:(BOXItem *)item
{
    if (!item.isFile) {
        return NO;
    } else {
        return ([self UTI:[self UTIFromFilePath:item.name] ConformsToUTI:@"public.image"] ||
                [[item.name pathExtension] caseInsensitiveCompare:@"dcm"] == NSOrderedSame);
    }
}

@end
