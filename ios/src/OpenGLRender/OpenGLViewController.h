//
//  OpenGLViewController.h
//  ZoomInstantSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenglView.h"

@interface OpenGLRawdataRenderer : NSObject
@property (nonatomic, assign) ZoomInstantSDKVideoType dataType;
@property (nonatomic, assign) BOOL isFullScreenDelegate;
@property (nonatomic, strong) OpenglView *openGLView;
@property (nonatomic, strong) ZoomInstantSDKUser *user;
@property (nonatomic, strong) UILabel *statisticLabel;

@end

@interface OpenGLViewController : UIViewController
@property (nonatomic,copy) ZoomInstantSDKERROR(^joinSessionOrIgnorePasswordBlock)(NSString *, BOOL);
@end
