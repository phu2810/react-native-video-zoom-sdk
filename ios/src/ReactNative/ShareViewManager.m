//
//  RNShareViewVideoSdkViewManager.m
//  react-native-video-zoom-sdk
//
//  Created by Phu on 6/4/21.
//

#import "ShareViewManager.h"

@interface RNShareViewVideoSdk: UIView {
    NSString *currentUserID;
}
- (void) setUserID: (NSString *) userID;
@end

@implementation RNShareViewVideoSdk

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (currentUserID.length > 0) {
        ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:currentUserID];
        if (user) {
            [[user getShareCanvas] unSubscribeWithView:self];
            [[user getShareCanvas] subscribeWithView:self andAspectMode:ZoomInstantSDKVideoAspect_Original];
        }
    }
}
- (void) setUserID: (NSString *) userID {
    if (userID) {
        if (![currentUserID isEqualToString:userID]) {
            [self unSubcribeCurrentUser];
            if (userID.length > 0) {
                ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:userID];
                if (user) {
                    [[user getShareCanvas] subscribeWithView:self andAspectMode:ZoomInstantSDKVideoAspect_Original];
                    currentUserID = userID;
                }
            }
        }
        else {
            if (userID.length > 0) {
                ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:userID];
                if (user) {
                    [[user getShareCanvas] unSubscribeWithView:self];
                    [[user getShareCanvas] subscribeWithView:self andAspectMode:ZoomInstantSDKVideoAspect_Original];
                }
            }
        }
    }
}
- (void) unSubcribeCurrentUser {
    if (currentUserID.length > 0) {
        ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:currentUserID];
        if (user) {
            [[user getShareCanvas] unSubscribeWithView:self];
        }
        currentUserID = @"";
    }
}
- (void) dealloc {
    [self unSubcribeCurrentUser];
}

@end


@implementation ShareViewManager

RCT_EXPORT_VIEW_PROPERTY(userID, NSString);

RCT_EXPORT_MODULE(RNShareViewVideoSdk)

- (UIView *)view
{
    RNShareViewVideoSdk *view = [[RNShareViewVideoSdk alloc] init];
    return view;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
