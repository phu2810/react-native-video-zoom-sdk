//
//  CreateViewController.h
//  ZoomInstantSample
//
//  Created by Zoom Video Communications on 2019/6/5.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZoomInstantCreateJoinType) {
    ZoomInstantCreateJoinType_Create      = 0,
    ZoomInstantCreateJoinType_Join
};

@interface CreateViewController : UIViewController
@property (nonatomic, assign) ZoomInstantCreateJoinType type;
@end


