//
//  RNVideoZoomViewManager.m
//  react-native-video-zoom-sdk
//
//  Created by Phu on 5/12/21.
//

#import "RNVideoZoomViewManager.h"
#import "CaptureVideoManager.h"

@interface RNVideoZoomView: UIView {
    NSTimer *timerHideLastFrame;
    NSString *currentUserID;
}

@property (nonatomic, strong) UIImageView *lastFrameImg;
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

- (void)commonInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(handleVideoStatusChange:)
            name:@"onUserVideoStatusChanged"
            object:nil];
    
    self.videoView = [UIView new];
    self.videoView.frame = CGRectMake(0, 0, 10, 10);
    [self addSubview:self.videoView];
    self.lastFrameImg = [UIImageView new];
    [self addSubview:self.lastFrameImg];
    [self.lastFrameImg setHidden:YES];
    currentUserID = @"";
}
- (UIImage *)captureVideo:(UIView *)view
{
    if (@available(iOS 10.0, *)) {
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:view.bounds.size];
        return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
        }];
    } else {
        // Fallback on earlier versions
        return nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.videoView.frame = self.bounds;
    self.lastFrameImg.frame = self.bounds;
}
- (void) setUserID: (NSString *) userID {
    if (userID) {
        if (![currentUserID isEqualToString:userID]) {
            [self unSubcribeCurrentUser];
            if (userID.length > 0) {
                if (timerHideLastFrame) {
                    [timerHideLastFrame invalidate];
                    timerHideLastFrame = nil;
                }
                UIImage *capture = [[CaptureVideoManager sharedManager] getLastFrame:userID withSize:self.bounds.size];
                if (capture) {
                    self.lastFrameImg.image = capture;
                    [self.lastFrameImg setHidden:NO];
                    timerHideLastFrame = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                          target:self
                                                                        selector:@selector(hideLastFrame)
                                                                        userInfo:nil
                                                                         repeats:NO];
                }
                else {
                    [self.lastFrameImg setHidden:YES];
                }
                ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:userID];
                if (user) {
                    if (user.videoStatus.on) {
                        [[user getVideoCanvas] subscribeWithView:self.videoView andAspectMode:ZoomInstantSDKVideoAspect_Original];
                    }
                    currentUserID = userID;
                }
            }
        }
        else {
            if (userID.length > 0) {
                ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:userID];
                if (user) {
                    [[user getVideoCanvas] unSubscribeWithView:self.videoView];
                    if (user.videoStatus.on) {
                        [[user getVideoCanvas] subscribeWithView:self.videoView andAspectMode:ZoomInstantSDKVideoAspect_Original];
                    }
                }
            }
        }
    }
}
- (void) hideLastFrame {
    if (timerHideLastFrame) {
        [timerHideLastFrame invalidate];
        timerHideLastFrame = nil;
    }
    [self.lastFrameImg setHidden:YES];
}
- (void) unSubcribeCurrentUser {
    if (currentUserID.length > 0) {
        ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:currentUserID];
        if (user && user.videoStatus.on) {
            UIImage *capture = [self captureVideo:self.videoView];
            if (capture) {
                [[CaptureVideoManager sharedManager] setLastFrame:capture size:self.bounds.size forKey:currentUserID];
            }
            [[user getVideoCanvas] unSubscribeWithView:self.videoView];
        }
        currentUserID = @"";
    }
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unSubcribeCurrentUser];
    if (timerHideLastFrame) {
        [timerHideLastFrame invalidate];
        timerHideLastFrame = nil;
    }
    [_videoView removeFromSuperview];
    _videoView = nil;
    
    [_lastFrameImg setImage: nil];
    [_lastFrameImg removeFromSuperview];
    _lastFrameImg = nil;
}
- (void) handleVideoStatusChange:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"onUserVideoStatusChanged"] && notification.userInfo)
    {
        NSString *userID = notification.userInfo[@"userID"];
        if (currentUserID && currentUserID.length > 0 && [currentUserID isEqualToString:userID]) {
            ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:userID];
            if (user) {
                [[user getVideoCanvas] unSubscribeWithView:self.videoView];
                if (user.videoStatus.on) {
                    [[user getVideoCanvas] subscribeWithView:self.videoView andAspectMode:ZoomInstantSDKVideoAspect_Original];
                }
            }
        }
    }
}

@end

@implementation RNVideoZoomViewManager

RCT_EXPORT_VIEW_PROPERTY(userID, NSString);

RCT_EXPORT_MODULE(RNVideoZoomView)

- (UIView *)view
{
    RNVideoZoomView *view = [[RNVideoZoomView alloc] init];
    return view;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end
