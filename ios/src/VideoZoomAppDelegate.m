//
//  VideoZoomAppDelegate.m
//  ZoomInstantSample
//
//  Created by Zoom Video Communications on 2019/5/24.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "VideoZoomAppDelegate.h"
#import "MainViewController.h"
#import "BaseNavigationController.h"
#import "IntroViewController.h"

@interface VideoZoomAppDelegate ()

@end

@implementation VideoZoomAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //     Override point for customization after application launch.

    ZoomInstantSDKInitParams *context = [[ZoomInstantSDKInitParams alloc] init];
    context.domain = @"https://zoom.us";
    context.appGroupId = @"group.us.zoom.instantsdk";
    context.enableLog = YES;
    //    context.videoRawdataMemoryMode = ZoomInstantSDKRawDataMemoryModeHeap;
    //    context.shareRawdataMemoryMode = ZoomInstantSDKRawDataMemoryModeHeap;
    //    context.audioRawdataMemoryMode = ZoomInstantSDKRawDataMemoryModeHeap;
    
    ZoomInstantSDKERROR ret = [[ZoomInstantSDK shareInstance] initialize:context];
    NSLog(@"initializeWithAppKey=====>%@", @(ret));
    
    NSString *version = [[ZoomInstantSDK shareInstance] getSDKVersion];
    NSLog(@"Instant SDK version: %@", version);
    

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    IntroViewController *viewController = [IntroViewController new];

    BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:viewController];

    MainViewController *mainViewController = [MainViewController new];
    mainViewController.rootViewController = navigationController;
    [mainViewController setupWithType];

    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
    
 
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.canRotation) {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)topViewController
{
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc
{
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [[ZoomInstantSDK shareInstance] appWillResignActive];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[ZoomInstantSDK shareInstance] appDidEnterBackgroud];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[ZoomInstantSDK shareInstance] appDidBecomeActive];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[ZoomInstantSDK shareInstance] appWillTerminate];
}


@end
