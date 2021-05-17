//
//  NSObject+ErrorMessage.h
//  ZoomInstantSample
//
//  Created by Zoom Video Communications on 2019/11/29.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ErrorMessage)

- (NSString *)formatErrorString:(ZoomInstantSDKERROR)errorCode;

@end

NS_ASSUME_NONNULL_END
