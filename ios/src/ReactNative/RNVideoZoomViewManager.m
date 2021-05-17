//
//  RNVideoZoomViewManager.m
//  react-native-video-zoom-sdk
//
//  Created by Phu on 5/12/21.
//

#import "RNVideoZoomViewManager.h"

@interface RNVideoZoomView: UIView {
    NSString *currentUserID;
}

@property (nonatomic, strong) UIView *videoView;

- (void) setUserID: (NSString *) userID;

@end

@implementation RNVideoZoomView

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

- (void)commonInit;
{
    self.videoView = [UIView new];
    self.videoView.frame = CGRectMake(0, 0, 10, 10);
    [self addSubview:self.videoView];
    currentUserID = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.videoView.frame = self.bounds;
}
- (void) setUserID: (NSString *) userID {
    if (userID && ![currentUserID isEqualToString:userID]) {
        [self unSubcribeCurrentUser];
        if (userID.length > 0) {
            ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:userID];
            if (user) {
                [[user getVideoCanvas] subscribeWithView:self.videoView andAspectMode:ZoomInstantSDKVideoAspect_PanAndScan];
            }
        }
        currentUserID = userID;
    }
}
- (void) unSubcribeCurrentUser {
    if (currentUserID.length > 0) {
        ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:currentUserID];
        if (user) {
            [[user getVideoCanvas] unSubscribeWithView:self.videoView];
        }
        currentUserID = @"";
    }
}
- (void) dealloc {
    [self unSubcribeCurrentUser];
}
@end

@implementation RNVideoZoomViewManager

RCT_EXPORT_VIEW_PROPERTY(userID, NSString);

RCT_EXPORT_MODULE(RNVideoZoomView)

- (UIView *)view
{
    ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    RNVideoZoomView *view = [[RNVideoZoomView alloc] init];
    [view setUserID:[myUser getUserId]];
    return view;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
