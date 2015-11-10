//
//  BOXBrowseSDKBundleHelper.h
//  Pods
//
//  Created by Andrew Dempsey on 11/10/15.
//
//

#import <Foundation/Foundation.h>

/*
 The purpose of this class is to help fetch the framework bundle
 to which this class belongs to. This class must not be moved out
 of BoxBrowseSDK otherwise it will cause failure to fetch resources
 from framework bundle
 */
@interface BOXBrowseSDKBundleHelper : NSObject

@end
