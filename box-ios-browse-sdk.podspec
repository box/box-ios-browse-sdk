Pod::Spec.new do |s|

# Root specification

s.name                  = "box-ios-browse-sdk"
s.version               = "1.0.7"
s.summary               = "iOS Browse SDK."
s.homepage              = "https://github.com/box/box-ios-browse-sdk"
s.license               = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
s.author                = "Box"
s.source                = { :git => "https://github.com/box/box-ios-browse-sdk.git", :tag => "v#{s.version}" }

# Platform

s.ios.deployment_target = "8.0"

# File patterns

s.ios.source_files        = "BoxBrowseSDK/BoxBrowseSDK/*.{h,m}", "BoxBrowseSDK/BoxBrowseSDK/**/*.{h,m}"
s.ios.public_header_files = "BoxBrowseSDK/BoxBrowseSDK/*.h", "BoxBrowseSDK/BoxBrowseSDK/**/*.h"
s.resource_bundle = {
   'BoxBrowseSDKResources' => [
     'BoxBrowseSDK/BoxBrowseSDKResources/Assets/*.*',
     'BoxBrowseSDK/BoxBrowseSDKResources/Icons/*.*',
   ]
}
# Build settings
s.requires_arc          = true
s.xcconfig              = { "OTHER_LDFLAGS" => "-ObjC -all_load" }
s.ios.header_dir        = "BoxBrowseSDK"
s.module_name           = "BoxBrowseSDK"
s.dependency              "box-ios-sdk"
s.dependency		  'MBProgressHUD', '~> 1.0.0'

end
