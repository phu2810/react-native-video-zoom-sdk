//
//  MetalViewController.h
//  ZoomInstantSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetalView.h"

@interface MetalRawdataRenderer : NSObject
@property (nonatomic, assign) ZoomInstantSDKVideoType dataType;
@property (nonatomic, assign) BOOL isFullScreenDelegate;
@property (nonatomic, strong) MetalView *metalView;
@property (nonatomic, strong) ZoomInstantSDKUser *user;
@property (nonatomic, strong) UILabel *statisticLabel;

@end

@interface MetalViewController : UIViewController
@property (nonatomic,copy) ZoomInstantSDKERROR(^joinSessionOrIgnorePasswordBlock)(NSString *, BOOL);
@end
