#import "VideoZoomSdk.h"
#import "VideoZoomControl.h"

@implementation VideoZoomSdk

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initSDK:(RCTResponseSenderBlock)callback)
{
    [[VideoZoomControl shared] initSDK:callback];
    __weak VideoZoomSdk *weakSelf = self;
    [VideoZoomControl shared].sendEventBlock = ^(NSDictionary * _Nonnull payload) {
        [weakSelf sendEventWithName:@"onVideoZoomMeetingEvent" body: payload];
    };
}

RCT_EXPORT_METHOD(appStateChange:(NSString*)newState)
{
    [[VideoZoomControl shared] appStateChange:newState];
}

RCT_EXPORT_METHOD(joinMeeting:(NSDictionary *) meetingInfo)
{
    [[VideoZoomControl shared] joinMeeting:meetingInfo];
}

RCT_EXPORT_METHOD(leaveCurrentMeeting)
{
    [[VideoZoomControl shared] leaveSession];
}

RCT_EXPORT_METHOD(onOffMyAudio)
{
    [[VideoZoomControl shared] onOffMyAudio];
}

RCT_EXPORT_METHOD(onMyAudio)
{
    [[VideoZoomControl shared] onMyAudio];
}

RCT_EXPORT_METHOD(offMyAudio)
{
    [[VideoZoomControl shared] offMyAudio];
}

RCT_EXPORT_METHOD(onOffMyVideo)
{
    [[VideoZoomControl shared] onOffMyVideo];
}

RCT_EXPORT_METHOD(switchMyCamera)
{
    [[VideoZoomControl shared] switchMyCamera];
}

RCT_EXPORT_METHOD(getParticipants:(RCTResponseSenderBlock)callback)
{
    [[VideoZoomControl shared] getParticipants:callback];
}
RCT_EXPORT_METHOD(getUserInfo:(NSString *)userIdStr callback:(RCTResponseSenderBlock)callback)
{
    [[VideoZoomControl shared] getUserInfo:userIdStr callBack:callback];
}

RCT_EXPORT_METHOD(startObserverEvent)
{
}
RCT_EXPORT_METHOD(stopObserverEvent)
{
}
RCT_EXPORT_METHOD(setHostUser:(NSString *)userID)
{
}
RCT_EXPORT_METHOD(raiseMyHand)
{
}
RCT_EXPORT_METHOD(lowerHand)
{
}
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
- (NSArray<NSString *> *)supportedEvents {
    return @[@"onVideoZoomMeetingEvent"];
}

- (NSNumber *) getVideoRatio: (NSUInteger) userID {
    return @0;
}

@end
