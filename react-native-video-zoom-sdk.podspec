require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-video-zoom-sdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/phu2810/react-native-video-zoom-sdk/react-native-video-zoom-sdk.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}"

  s.dependency "React-Core"
  s.dependency "VideoZoom_SDK", '1.0.2'

s.prefix_header_contents = "

#import <ZoomInstantSDK/ZoomInstantSDK.h>
#import \"MBProgressHUD.h\"
#import \"VideoZoomAppDelegate.h\"
#import \"NSObject+ErrorMessage.h\"

typedef enum : NSUInteger {
    DisplayMode_LetterBox,
    DisplayMode_PanAndScan,
} DisplayMode;

#define kScreenShareBundleId @\"us.zoom.InstantSDKPlaygroud.ExtensionReplayKit\"

//for iOS version check
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IsIphoneX  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen] currentMode].size) : NO)

//for device check
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IPHONE_X \\
({BOOL isPhoneX = NO;\\
if (@available(iOS 11.0, *)) {\\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\\
}\\
(isPhoneX);})

#define SAFE_ZOOM_INSETS  34

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define Width(v)                CGRectGetWidth((v).frame)
#define Height(v)               CGRectGetHeight((v).frame)

#define MinX(v)            CGRectGetMinX((v).frame)
#define MinY(v)            CGRectGetMinY((v).frame)

#define MidX(v)            CGRectGetMidX((v).frame)
#define MidY(v)            CGRectGetMidY((v).frame)

#define MaxX(v)            CGRectGetMaxX((v).frame)
#define MaxY(v)            CGRectGetMaxY((v).frame)

#define RGBCOLOR(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
  "

end
