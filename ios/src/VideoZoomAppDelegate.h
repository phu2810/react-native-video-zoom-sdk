//
//  VideoZoomAppDelegate.h
//  ZoomInstantSample
//
//  Created by Zoom Video Communications on 2019/5/24.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAppToken   @"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ2ZXJzaW9uIjoxLCJ1c2VyX2lkZW50aXR5IjoiaG9jc2luaF9kZW1vQGdtYWlsLmNvbSIsImFwcF9rZXkiOiJGVjFqZmJBOWo2anEyR01EUmhEMHFUYmFCQTBDbmhXeUFuVzAiLCJpYXQiOjE2MTkxNjMzMDAsImV4cCI6MTYxOTE5MDUwMCwidHBjIjoiZGVtb190b3BpYzIifQ.wkPebTX4UgpjGdUvHabNK4zz9nMww1NojQMYqxQim2M"
#define kSDKDomain  @""

@interface VideoZoomAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) BOOL canRotation;

- (UIViewController *)topViewController;
@end

