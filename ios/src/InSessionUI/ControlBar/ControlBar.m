//
//  ControlBar.m
//  ZoomInstantSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import "ControlBar.h"
#import "TopBarView.h"
#import <AudioToolbox/AudioToolbox.h>

#define kTagButtonVideo         2000
#define kTagButtonShare         (kTagButtonVideo+1)
#define kTagButtonAudio          (kTagButtonVideo+2)
#define kTagButtonMore          (kTagButtonVideo+3)

@interface ControlBar ()
@property (strong, nonatomic) UIButton          *videoBtn;
@property (strong, nonatomic) UIButton          *moreBtn;

@property (nonatomic, assign) BOOL              isSpeaker;
@property (nonatomic, assign) NSInteger         indexOfExternalVideoSource;
@end

@implementation ControlBar

- (id)init
{
    self = [super init];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    float button_width;
    if (landscape) {
        if (IS_IPAD) {
            button_width = 65.0;
        } else {
            if (SCREEN_HEIGHT <= 375.0) {
                button_width = 50;
            } else {
                button_width = 55;
            }
        }
    } else {
        button_width = 65;
    }
    
    ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    _audioBtn.frame = CGRectMake(0, 0, button_width, button_width * ([UIImage imageNamed:@"icon_no_audio"].size.height/[UIImage imageNamed:@"icon_no_audio"].size.width));
    if (myUser.audioStatus.audioType == ZoomInstantSDKAudioType_None) {
        _audioBtn.frame = CGRectMake(0, 0, button_width, button_width * ([UIImage imageNamed:@"icon_no_audio"].size.height/[UIImage imageNamed:@"icon_no_audio"].size.width));
    } else {
        if (!myUser.audioStatus.isMuted) {
            [_audioBtn setImage:[UIImage imageNamed:@"icon_mute"] forState:UIControlStateNormal];
        } else {
            [_audioBtn setImage:[UIImage imageNamed:@"icon_unmute"] forState:UIControlStateNormal];
        }
    }
    
    _shareBtn.frame = CGRectMake(0, CGRectGetMaxY(_audioBtn.frame), button_width, button_width * ([UIImage imageNamed:@"icon_video_share"].size.height/[UIImage imageNamed:@"icon_video_share"].size.width));
    _videoBtn.frame = CGRectMake(0, CGRectGetMaxY(_shareBtn.frame), button_width, button_width * ([UIImage imageNamed:@"icon_video_on"].size.height/[UIImage imageNamed:@"icon_video_on"].size.width));
    _moreBtn.frame = CGRectMake(0, CGRectGetMaxY(_videoBtn.frame), button_width, button_width * ([UIImage imageNamed:@"icon_video_more"].size.height/[UIImage imageNamed:@"icon_video_more"].size.width));
    
    float controlBar_height = Height(_moreBtn)+Height(_videoBtn)+Height(_shareBtn)+Height(_audioBtn);
    
    float controlBar_x = SCREEN_WIDTH-button_width - 5;
    float controlBar_y;
    if (landscape) {
        if (orientation == UIInterfaceOrientationLandscapeLeft && IPHONE_X) {
            controlBar_x = SCREEN_WIDTH-button_width-SAFE_ZOOM_INSETS;
        } else {
            controlBar_x = SCREEN_WIDTH-button_width - 12;
        }
    }
    
    if (landscape && !IS_IPAD && SCREEN_HEIGHT <= 375.0) {
        controlBar_y = Top_Height + 20;
    } else {
        controlBar_y = (SCREEN_HEIGHT - controlBar_height)/2;
    }
    self.frame = CGRectMake(controlBar_x, controlBar_y, button_width, controlBar_height);
}

- (void)initSubView {
    _videoBtn = [[UIButton alloc] init];
    _videoBtn.tag = kTagButtonVideo;
    [_videoBtn setImage:[UIImage imageNamed:@"icon_video_off"] forState:UIControlStateNormal];
    [_videoBtn setImage:[UIImage imageNamed:@"icon_video_on"] forState:UIControlStateSelected];
    [_videoBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_videoBtn];
    
    _shareBtn = [[UIButton alloc] init];
    _shareBtn.tag = kTagButtonShare;
    [_shareBtn setImage:[UIImage imageNamed:@"icon_video_share"] forState:UIControlStateNormal];
    [_shareBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareBtn];
    
    _audioBtn = [[UIButton alloc] init];
    _audioBtn.tag = kTagButtonAudio;
    [_audioBtn setImage:[UIImage imageNamed:@"icon_no_audio"] forState:UIControlStateNormal];
    [_audioBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_audioBtn];
        
    _moreBtn = [[UIButton alloc] init];
    _moreBtn.tag = kTagButtonMore;
    [_moreBtn setImage:[UIImage imageNamed:@"icon_video_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget: self action: @selector(onBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_moreBtn];
    
    
}


- (void)onBarButtonClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case kTagButtonMore:
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];

            if (!IS_IPAD) {
                NSString *speakDispaly;
                if (self.isSpeaker) {
                    speakDispaly = @"Turn off Speaker";
                } else {
                    speakDispaly = @"Turn on Speaker";
                }
                [alertController addAction:[UIAlertAction actionWithTitle:speakDispaly
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [self switchSpeaker];
                                                                  }]];
            }
            
            ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
            if (myUser.videoStatus.on) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"Switch Camera"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [[[ZoomInstantSDK shareInstance] getVideoHelper] switchCamera];
                                                                  }]];
            }
            
#if DEBUG
            if ((myUser.isHost || myUser.isManager) && ![[[ZoomInstantSDK shareInstance] getShareHelper] isShareLocked]) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"Lock Share"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [[[ZoomInstantSDK shareInstance] getShareHelper] lockShare:YES];
                                                                  }]];
            }
            
            if ((myUser.isHost || myUser.isManager) && [[[ZoomInstantSDK shareInstance] getShareHelper] isShareLocked]) {
                [alertController addAction:[UIAlertAction actionWithTitle:@"Unlock Share"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      [[[ZoomInstantSDK shareInstance] getShareHelper] lockShare:NO];
                                                                  }]];
            }
            
            if (myUser.isHost) {
                BOOL haveManager = NO;
                for (ZoomInstantSDKUser *user in [[[ZoomInstantSDK shareInstance] getSession] getAllUsers]) {
                    if (user.isManager) {
                        haveManager = YES;
                    }
                }
                
                if (!haveManager) {
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Make Manager"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          for (ZoomInstantSDKUser *user in [[[ZoomInstantSDK shareInstance] getSession] getAllUsers]) {
                                                                              if (![user isEqual:[[[ZoomInstantSDK shareInstance] getSession] getMySelf]] && !user.isManager) {
                                                                                  [[[ZoomInstantSDK shareInstance] getUserHelper] makeManager:user];
                                                                                  break;
                                                                              }
                                                                          }
                                                                      }]];
                }
                
                if (haveManager) {
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Revoke Manager"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action) {
                                                                          for (ZoomInstantSDKUser *user in [[[ZoomInstantSDK shareInstance] getSession] getAllUsers]) {
                                                                              if (![user isEqual:[[[ZoomInstantSDK shareInstance] getSession] getMySelf]] && user.isManager) {
                                                                                  [[[ZoomInstantSDK shareInstance] getUserHelper] revokeManager:user];
                                                                              }
                                                                          }
                                                                      }]];
                }
                
                [alertController addAction:[UIAlertAction actionWithTitle:@"Change name"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                    [[[ZoomInstantSDK shareInstance] getUserHelper] changeName:@"test Change" withUser:[[[ZoomInstantSDK shareInstance] getSession] getMySelf]];
                                                                    }]];
            }
#endif
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            
            UIPopoverPresentationController *popover = alertController.popoverPresentationController;
            if (popover)
            {
                UIButton *btn = (UIButton*)sender;
                popover.sourceView = btn;
                popover.sourceRect = btn.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            VideoZoomAppDelegate *appDelegate = (VideoZoomAppDelegate *)[UIApplication sharedApplication].delegate;
            [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
            break;
        }

        case kTagButtonVideo:
        {
            ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
            if (myUser.videoStatus.on) {
                [[[ZoomInstantSDK shareInstance] getVideoHelper] stopVideo];
                [_videoBtn setSelected:YES];
            } else {
                [[[ZoomInstantSDK shareInstance] getVideoHelper] startVideo];
                [_videoBtn setSelected:NO];
            }
            break;
        }
        case kTagButtonShare:
        {
            if (self.shareOnClickBlock) {
                self.shareOnClickBlock();
            }
            break;
        }
        case kTagButtonAudio:
        {
            ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
            if (myUser.audioStatus.audioType == ZoomInstantSDKAudioType_None) {
                [[[ZoomInstantSDK shareInstance] getAudioHelper] startAudio];
            } else {
                if (!myUser.audioStatus.isMuted) {
                    [[[ZoomInstantSDK shareInstance] getAudioHelper] muteAudio:myUser];
                } else {
                    [[[ZoomInstantSDK shareInstance] getAudioHelper] unmuteAudio:myUser];
                }
            }
        }
        default:
            break;
    }
}

- (void)switchSpeaker
{
#define COMPARE(FIRST,SECOND) (CFStringCompare(FIRST, SECOND, kCFCompareCaseInsensitive) == kCFCompareEqualTo)
    CFDictionaryRef route;
    UInt32 size = sizeof (route);
    OSStatus status = AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &size, &route);
    if (status != noErr) {
        return;
    }
    
    CFArrayRef outputs = (CFArrayRef)CFDictionaryGetValue(route, kAudioSession_AudioRouteKey_Outputs);
    if (!outputs || CFArrayGetCount(outputs) == 0) {
        if(route) CFRelease(route);
        return;
    }
    
    CFDictionaryRef item = (CFDictionaryRef)CFArrayGetValueAtIndex(outputs, 0);
    CFStringRef device = (CFStringRef)CFDictionaryGetValue(item, kAudioSession_AudioRouteKey_Type);
    if (device && COMPARE(device, kAudioSessionOutputRoute_BuiltInReceiver))
    {
        UInt32 isSpeaker = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(isSpeaker), &isSpeaker);
        self.isSpeaker = YES;
    }
    else if (device && COMPARE(device, kAudioSessionOutputRoute_BuiltInSpeaker))
    {
        UInt32 isSpeaker = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(isSpeaker), &isSpeaker);
        self.isSpeaker = NO;
    }
    
    if(route) CFRelease(route);
}

@end


