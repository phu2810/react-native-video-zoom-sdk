//
//  LogUtils.h
//  react-native-video-zoom-sdk
//
//  Created by Phu on 5/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define OWSLogPrefix()                                                                                                 \
    ([NSString stringWithFormat:@"[%@:%d %s]: ",                                                                       \
               [[NSString stringWithUTF8String:__FILE__] lastPathComponent],                                           \
               __LINE__,                                                                                               \
               __PRETTY_FUNCTION__])

#define OWSLogVerbose(_messageFormat, ...)                                                                             \
    do {                                                                                                               \
        NSLog(@"💙 %@%@", OWSLogPrefix(), [NSString stringWithFormat:_messageFormat, ##__VA_ARGS__]);              \
    } while (0)

@interface LogUtils : NSObject

+ (void) logFunction;

@end

NS_ASSUME_NONNULL_END
