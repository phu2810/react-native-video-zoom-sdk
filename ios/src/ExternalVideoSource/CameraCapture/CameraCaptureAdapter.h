
#import <ZoomInstantSDK/ZoomInstantSDK.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CameraCaptureAdapter : NSObject <ZoomInstantSDKVideoSource, AVCaptureVideoDataOutputSampleBufferDelegate>

@end

