//
//  VideoZoomControl.m
//  react-native-video-zoom-sdk
//
//  Created by Phu on 5/10/21.
//

#import "VideoZoomControl.h"
#import "VideoZoomEventHandler.h"

@interface VideoZoomControl()<ZoomInstantSDKDelegate> {
    BOOL isInitSuccess;
    BOOL listenAppState;
}

@property (nonatomic, strong) VideoZoomEventHandler *eventHandler;

@end

@implementation VideoZoomControl

+ (instancetype)shared
{
    static VideoZoomControl *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VideoZoomControl alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        isInitSuccess = NO;
        listenAppState = NO;
        self.eventHandler = [VideoZoomEventHandler new];
        self.mapActiveAudio = [NSMutableDictionary new];
        self.mapActiveVideo = [NSMutableDictionary new];
    }
    return self;
}
- (void) initSDK:(RCTResponseSenderBlock)callback
{
    if (!listenAppState) {
        listenAppState = YES;
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(applicationWillResignActive)
         name:UIApplicationWillResignActiveNotification
         object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(applicationDidBecomeActive)
         name:UIApplicationDidBecomeActiveNotification
         object:nil];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(applicationDidEnterBackground)
         name:UIApplicationDidEnterBackgroundNotification
         object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    if (!isInitSuccess) {
        ZoomInstantSDKInitParams *context = [[ZoomInstantSDKInitParams alloc] init];
        context.domain = @"https://zoom.us";
        context.appGroupId = @"group.us.zoom.instantsdk";
        context.enableLog = NO;
        
        ZoomInstantSDKERROR ret = [[ZoomInstantSDK shareInstance] initialize:context];
        isInitSuccess = ret == 0;
        callback(@[@(ret == 0)]);
    }
    else {
        callback(@[@(1)]);
    }
}
- (void)deviceChangeOrientation:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [[[ZoomInstantSDK shareInstance] getVideoHelper] rotateMyVideo:orientation];
}
- (void) applicationWillResignActive {
    [[ZoomInstantSDK shareInstance] appWillResignActive];
}
- (void) applicationDidBecomeActive {
    [[ZoomInstantSDK shareInstance] appDidBecomeActive];
}
- (void) applicationDidEnterBackground {
    [[ZoomInstantSDK shareInstance] appDidEnterBackgroud];
}

- (void) joinMeeting:(NSDictionary *) meetingInfo {
    [self.mapActiveVideo removeAllObjects];
    [self.mapActiveAudio removeAllObjects];
    
    NSString *topic = meetingInfo[@"tpc"] ?: @"topic";
    NSString *userName = meetingInfo[@"userName"] ?: @"userName";
    NSString *sessionPassword = meetingInfo[@"pwd"] ?: @"password";
    NSString *token = meetingInfo[@"token"] ?: @"token";
    
    ZoomInstantSDKAudioOptions *audioOption = [ZoomInstantSDKAudioOptions new];
    audioOption.connect     = YES;
    audioOption.mute        = NO;
    
    ZoomInstantSDKVideoOptions *videoOption = [ZoomInstantSDKVideoOptions new];
    videoOption.localVideoOn = YES;
    
    ZoomInstantSDKSessionContext *sessionContext = [ZoomInstantSDKSessionContext new];
    sessionContext.sessionName        = topic;
    sessionContext.userName        = userName;
    sessionContext.sessionPassword    = sessionPassword;
    sessionContext.audioOption     = audioOption;
    sessionContext.videoOption     = videoOption;
    sessionContext.token = token;
    
    [ZoomInstantSDK shareInstance].delegate = self.eventHandler;
    ZoomInstantSDKSession *session = [[ZoomInstantSDK shareInstance] joinSession:sessionContext];
    if (!session) {
        return;
    }
}
- (void) leaveSession {
    [[ZoomInstantSDK shareInstance] leaveSession:YES];
}
- (void) onOffMyAudio {
    ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    if (myUser.audioStatus.audioType == ZoomInstantSDKAudioType_None) {
        [[[ZoomInstantSDK shareInstance] getAudioHelper] startAudio];
    } else {
        if (!myUser.audioStatus.isMuted) {
            [[[ZoomInstantSDK shareInstance] getAudioHelper] muteAudio:myUser];
        } else {
            [[[ZoomInstantSDK shareInstance] getAudioHelper] unmuteAudio:myUser];
        }
    }
}
- (void) onMyAudio {
    ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    if (myUser.audioStatus.audioType == ZoomInstantSDKAudioType_None) {
        [[[ZoomInstantSDK shareInstance] getAudioHelper] startAudio];
    } else {
        if (myUser.audioStatus.isMuted) {
            [[[ZoomInstantSDK shareInstance] getAudioHelper] unmuteAudio:myUser];
        }
    }
}
- (void) offMyAudio {
    ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    if (myUser.audioStatus.audioType == ZoomInstantSDKAudioType_None) {
    } else {
        if (!myUser.audioStatus.isMuted) {
            [[[ZoomInstantSDK shareInstance] getAudioHelper] muteAudio:myUser];
        }
    }
}
- (void) onOffMyVideo {
//    ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
//    if (myUser.videoStatus.on) {
//        [[[ZoomInstantSDK shareInstance] getVideoHelper] stopVideo];
//    } else {
//        [[[ZoomInstantSDK shareInstance] getVideoHelper] startVideo];
//    }
}
- (void) switchMyCamera {
    [[[ZoomInstantSDK shareInstance] getVideoHelper] switchCamera];
}
- (void) getParticipants:(RCTResponseSenderBlock)callback {
    NSArray *userArr = [[[ZoomInstantSDK shareInstance] getSession] getAllUsers];
    NSMutableArray *listUser = [NSMutableArray new];
    for (ZoomInstantSDKUser *user in userArr) {
        [listUser addObject:@{
            @"userName": [user getUserName],
            @"userID": [user getUserId],
            @"audioStatus": @(!user.audioStatus.isMuted),
            @"videoStatus": @(user.videoStatus.on),
        }];
    }
    callback(@[listUser]);
}
- (void) getUserInfo:(NSString *) userID callBack:(RCTResponseSenderBlock)callback {
    ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:userID];
    callback(@[@{
                   @"userName": [user getUserName],
                   @"userID": [user getUserId],
                   @"audioStatus": @(!user.audioStatus.isMuted),
                   @"videoStatus": @(user.videoStatus.on),
    }]);
}
- (void) sendEvent:(NSDictionary *)payload {
    if (self.sendEventBlock) {
        self.sendEventBlock(payload);
    }
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) checkSetHostToUser: (NSString *) userName {
    ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    if (myUser && [myUser isHost]) {
        NSArray *userArr = [[[ZoomInstantSDK shareInstance] getSession] getAllUsers];
        for (ZoomInstantSDKUser *user in userArr) {
            if ([[user getUserName] isEqualToString:userName]) {
                BOOL success = [[[ZoomInstantSDK shareInstance] getUserHelper] makeHost:user];
                break;
            }
        }
    }
}
@end
