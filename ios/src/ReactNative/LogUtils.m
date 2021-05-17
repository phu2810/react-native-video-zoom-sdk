//
//  LogUtils.m
//  react-native-video-zoom-sdk
//
//  Created by Phu on 5/11/21.
//

#import "LogUtils.h"

@implementation LogUtils

+ (void) logFunction
{
    NSLog(@"<%@:%@:%d>", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__);
}

@end
