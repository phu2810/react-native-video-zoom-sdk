//
//  CanvasViewController.h
//  ZoomInstantSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomView : UIView
@property (nonatomic, strong) ZoomInstantSDKUser *user;
@property (nonatomic, assign) ZoomInstantSDKVideoType dataType;
@end


@interface CanvasViewController : UIViewController
@property (nonatomic,copy) ZoomInstantSDKERROR(^joinSessionOrIgnorePasswordBlock)(NSString *, BOOL);
@end
