//
//  VideoZoomDelegate.m
//  react-native-video-zoom-sdk
//
//  Created by Phu on 5/11/21.
//

#import "VideoZoomEventHandler.h"
#import "LogUtils.h"
#import "VideoZoomControl.h"

@implementation VideoZoomEventHandler

/*!
 @brief The callback of session join.
 */
- (void)onSessionJoin
{
    OWSLogVerbose(@"");
//    NSArray *userArr = [[[ZoomInstantSDK shareInstance] getSession] getAllUsers];
//    for (int i = 0; i < userArr.count; i++) {
//        ZoomInstantSDKUser *user = userArr[i];
//        NSLog(@"+++ onSessionJoin: %@ - %@", [user getUserName], [user getUserId]);
//    }
    [[VideoZoomControl shared] sendEvent:@{@"des": @"meeting_ready"}];
    [[[ZoomInstantSDK shareInstance] getVideoHelper] rotateMyVideo:UIDeviceOrientationPortrait];
}

/*!
 @brief The callback of session left.
 */
- (void)onSessionLeave
{
    [[VideoZoomControl shared] sendEvent:@{@"event": @"onSessionLeave"}];
}

/*!
 @brief The callback of all event error message.
 @param ErrorType A enum of error
 @param details The detail of error message.
 */
- (void)onError:(ZoomInstantSDKERROR)ErrorType detail:(NSInteger)details
{
    [[VideoZoomControl shared] sendEvent:@{@"event": @"onError"}];
    OWSLogVerbose(@"%@ - %@", @(ErrorType), @(details));
}

/*!
 @brief The callback of user join session.
 @param userArray Array contain 'ZoomInstantSDKUser'.
 */
- (void)onUserJoin:(ZoomInstantSDKUserHelper *)helper users:(NSArray <ZoomInstantSDKUser *>*)userArray
{
    OWSLogVerbose(@"");
    for (int i = 0; i < userArray.count; i++) {
        ZoomInstantSDKUser *user = userArray[i];
        [[VideoZoomControl shared] sendEvent:@{
            @"event": @"sinkMeetingUserJoin",
            @"userID": [user getUserId],
            @"userName": [user getUserName],
        }];
    }
}

/*!
 @brief The callback of user left session.
 @param userArray Array contain userId.
 */
- (void)onUserLeave:(ZoomInstantSDKUserHelper *)helper users:(NSArray <ZoomInstantSDKUser *>*)userArray
{
    OWSLogVerbose(@"");
    for (int i = 0; i < userArray.count; i++) {
        ZoomInstantSDKUser *user = userArray[i];
        [[VideoZoomControl shared] sendEvent:@{
            @"event": @"sinkMeetingUserLeft",
            @"userID": [user getUserId],
            @"userName": [user getUserName],
        }];
    }
}

///*!
// @brief The callback of user's video status change.
// @param userArray Array contain userId.
// */
//- (void)onUserVideoStatusChanged:(ZoomInstantSDKVideoHelper *)helper user:(NSArray <ZoomInstantSDKUser *>*)userArray
//{
//    OWSLogVerbose(@"");
//}
//
///*!
// @brief The callback of user's audio status change.
// @param userArray Array contain userId.
// */
//- (void)onUserAudioStatusChanged:(ZoomInstantSDKAudioHelper *)helper user:(NSArray <ZoomInstantSDKUser *>*)userArray
//{
//    OWSLogVerbose(@"");
//}
//
///*!
// @brief The callback of user's share status change.
// @param status A enum of share status.
// */
//- (void)onUserShareStatusChanged:(ZoomInstantSDKShareHelper *)helper user:(ZoomInstantSDKUser *)user status:(ZoomInstantSDKReceiveSharingStatus)status
//{
//    OWSLogVerbose(@"");
//}
//
///*!
// @brief The callback of user's live stream status change.
// @param status A enum of live stream status.
// */
//- (void)onLiveStreamStatusChanged:(ZoomInstantSDKLiveStreamHelper *)helper status:(ZoomInstantSDKLiveStreamStatus)status
//{
//    OWSLogVerbose(@"");
//}
//
///*!
// @brief The callback of instant message in the session.
// @param chatMessage The object which contains the message content.
// */
//- (void)onChatNewMessageNotify:(ZoomInstantSDKChatHelper *)helper message:(ZoomInstantSDKChatMessage *)chatMessage
//{
//    OWSLogVerbose(@"");
//}
//
///*!
// @brief The callback of session's host change.
// */
//- (void)onUserHostChanged:(ZoomInstantSDKUserHelper *)helper users:(ZoomInstantSDKUser *)user
//{
//    OWSLogVerbose(@"");
//}
//
///*!
//@brief The callback of session's manager change.
//*/
//- (void)onUserManagerChanged:(ZoomInstantSDKUser *)user
//{
//    OWSLogVerbose(@"");
//}
//
///*!
//@brief The callback of user's name change.
//*/
//- (void)onUserNameChanged:(ZoomInstantSDKUser *)user
//{
//    OWSLogVerbose(@"");
//}
//
///*!
// @brief The callback of active audio change.
// @param userArray The active array of user's id.
// */
//- (void)onUserActiveAudioChanged:(ZoomInstantSDKUserHelper *)helper users:(NSArray <ZoomInstantSDKUser *>*)userArray
//{
//    OWSLogVerbose(@"%@", userArray);
//    for (int i = 0; i < userArray.count; i++) {
//        ZoomInstantSDKUser *user = userArray[i];
//        NSLog(@"+++ 111 %@ - %@", [user getUserName], [user getUserId]);
//    }
//}
//
///*!
// @brief The callback of the session need password.
// */
//- (void)onSessionNeedPassword:(ZoomInstantSDKERROR (^)(NSString *password, BOOL leaveSessionIgnorePassword))completion
//{
//    OWSLogVerbose(@"");
//}
//
///*!
// @brief The callback of the session password wrong.
// */
//- (void)onSessionPasswordWrong:(ZoomInstantSDKERROR (^)(NSString *password, BOOL leaveSessionIgnorePassword))completion
//{
//    OWSLogVerbose(@"");
//}
//
///*!
// @brief This method is used to receive audio mixed raw data.
// @param rawData Audio's raw data.
// */
//- (void)onMixedAudioRawDataReceived:(ZoomInstantSDKAudioRawData *)rawData
//{
//    OWSLogVerbose(@"");
//}
//
///*!
// @brief This method is used to receive each road user audio raw data.
// @param rawData Audio's raw data.
// */
//- (void)onOneWayAudioRawDataReceived:(ZoomInstantSDKAudioRawData *)rawData user:(ZoomInstantSDKUser *)user
//{
//    OWSLogVerbose(@"");
//}
@end
