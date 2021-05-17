//
//  VideoZoomControl.m
//  react-native-video-zoom-sdk
//
//  Created by Phu on 5/10/21.
//

#import "VideoZoomControl.h"
#import "VideoZoomEventHandler.h"

@interface VideoZoomControl()<ZoomInstantSDKDelegate>

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
        self.eventHandler = [VideoZoomEventHandler new];
    }
    return self;
}
- (void) initSDK:(RCTResponseSenderBlock)callback
{
    ZoomInstantSDKInitParams *context = [[ZoomInstantSDKInitParams alloc] init];
    context.domain = @"https://zoom.us";
    context.appGroupId = @"group.us.zoom.instantsdk";
    context.enableLog = NO;
    
    ZoomInstantSDKERROR ret = [[ZoomInstantSDK shareInstance] initialize:context];
    NSLog(@"initializeWithAppKey=====>%@", @(ret));
    
    NSString *version = [[ZoomInstantSDK shareInstance] getSDKVersion];
    NSLog(@"Instant SDK version: %@", version);
    callback(@[@(ret == 0)]);
}
- (void) appStateChange:(NSString *) newState {
    if ([newState isEqualToString:@"inactive"]) {
        [[ZoomInstantSDK shareInstance] appWillResignActive];
    }
    else if ([newState isEqualToString:@"background"]) {
        [[ZoomInstantSDK shareInstance] appDidEnterBackgroud];
    }
    else if ([newState isEqualToString:@"active"]) {
        [[ZoomInstantSDK shareInstance] appDidBecomeActive];
    }
}
- (void) joinMeeting:(NSDictionary *) meetingInfo {
    NSLog(@"+++ ok meeting info %@", meetingInfo);
    NSString *topic = meetingInfo[@"topic"] ?: @"topic";
    NSString *userName = meetingInfo[@"userName"] ?: @"userName";
    NSString *sessionPassword = meetingInfo[@"sessionPassword"] ?: @"password";
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
    ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    if (myUser.videoStatus.on) {
        [[[ZoomInstantSDK shareInstance] getVideoHelper] stopVideo];
    } else {
        [[[ZoomInstantSDK shareInstance] getVideoHelper] startVideo];
    }
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
            @"userID": [user getUserId]
        }];
    }
    callback(@[listUser]);
}
- (void) sendEvent:(NSDictionary *)payload {
    if (self.sendEventBlock) {
        self.sendEventBlock(payload);
    }
}
@end
