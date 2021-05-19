//
//  VideoZoomControl.h
//  react-native-video-zoom-sdk
//
//  Created by Phu on 5/10/21.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SendEventBlock)(NSDictionary *payload);

@interface VideoZoomControl : NSObject

+ (instancetype)shared;
@property (nonatomic, copy) SendEventBlock sendEventBlock;

- (void) initSDK:(RCTResponseSenderBlock)callback;
- (void) joinMeeting:(NSDictionary *) meetingInfo;
- (void) leaveSession;
- (void) onOffMyAudio;
- (void) onMyAudio;
- (void) offMyAudio;
- (void) onOffMyVideo;
- (void) switchMyCamera;
- (void) getParticipants:(RCTResponseSenderBlock)callback;
- (void) getUserInfo:(NSString *) userID callBack:(RCTResponseSenderBlock)callback;
- (void) sendEvent:(NSDictionary *)payload;
@end

NS_ASSUME_NONNULL_END
