//
//  CanvasViewController.m
//  ZoomInstantSample
//
//  Created by Zoom Video Communications on 2019/5/27.
//  Copyright © 2019 Zoom. All rights reserved.
//

#import <ReplayKit/ReplayKit.h>
#import "CanvasViewController.h"
#import "TopBarView.h"
#import "ControlBar.h"
#import "ChatInputView.h"
#import "BottomBarView.h"
#import "ChatView.h"
#import "KGModal.h"
#import "VideoZoomAppDelegate.h"
#import "SwitchBtn.h"

#define kBroadcastPickerTag 10001
#define kEmojiTag           10002
#define kBackgroudTag       10003

@implementation ZoomView

@end

@interface CanvasViewController () <ZoomInstantSDKDelegate, BottomBarViewDelegate, ChatInputViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) TopBarView              *topBarView;
@property (strong, nonatomic) ControlBar              *controlBarView;
@property (strong, nonatomic) ChatInputView           *chatInputView;
@property (strong, nonatomic) BottomBarView           *bottomView;
@property (strong, nonatomic) ChatView                *chatView;
@property (strong, nonatomic) SwitchBtn               *switchShareBtn;

@property (nonatomic, strong) ZoomView  *fullScreenCanvas;

@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *selectImgView;
@property (nonatomic, strong) UIButton *stopShareBtn;

@property (nonatomic, strong) NSMutableArray *avatarArr;
@property (nonatomic, strong) NSTimer *speakerTimer;

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) UILabel *statisticLabel;
@end

@implementation CanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ZoomInstantSDK shareInstance].delegate = self;
    self.avatarArr = [NSMutableArray array];
    
    [self initSubView];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateFrame];
}

- (void)updateFrame {
    self.fullScreenCanvas.frame = self.view.bounds;
    
    [self.topBarView setNeedsLayout];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    if (landscape) {
        if (orientation == UIInterfaceOrientationLandscapeRight && IPHONE_X) {
            self.switchShareBtn.frame = CGRectMake(SAFE_ZOOM_INSETS+10, Top_Height + 5, 180, 35);
        } else {
            self.switchShareBtn.frame = CGRectMake(8, Top_Height + 5, 180, 35);
        }
        self.statisticLabel.frame = CGRectMake(SCREEN_WIDTH - CGRectGetWidth(_topBarView.leaveBtn.frame) - 90 - 30, 23.5, 90, 25);
    } else {
        self.switchShareBtn.frame = CGRectMake(8, (IPHONE_X ? Top_Height + SAFE_ZOOM_INSETS : Top_Height) + 5, 180, 35);
        self.statisticLabel.frame = CGRectMake(SCREEN_WIDTH - 90 - 16, (IPHONE_X ? Top_Height + SAFE_ZOOM_INSETS : Top_Height), 90, 25);
    }
    
    [self.chatView setNeedsLayout];

    [self.controlBarView setNeedsLayout];
    if (_bottomView) {
        [self.bottomView setNeedsLayout];
    }
    
    CGRect fullRect = self.fullScreenCanvas.bounds;
    for (UIView *subView in self.fullScreenCanvas.subviews) {
        if (subView.tag == kBackgroudTag) {
            subView.frame = fullRect;
        }
        
        if (subView.tag == kEmojiTag) {
            subView.frame = CGRectMake(fullRect.size.width * 0.25, fullRect.size.height * 0.25, fullRect.size.width * 0.5, fullRect.size.height * 0.5);
        }
    }
    
    self.shareView.frame = self.view.bounds;
    self.scrollView.frame = self.view.bounds;
    self.selectImgView.frame = self.view.bounds;
    
    CGFloat bottom = IPHONE_X ? (landscape ? 21.f : 34.f) : 0.0;
    CGFloat right = IPHONE_X ? 44.0 : 0.0;
    CGFloat width = 104.0;
    CGFloat height = 28.0;
    self.stopShareBtn.frame = CGRectMake(SCREEN_WIDTH - width - 16 - right, SCREEN_HEIGHT - 16 - height - bottom, width, height);
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)sendAction:(NSString *)chatString
{
    NSLog(@"chatString===>%@",chatString);
    
    if (chatString.length == 0) {
        return;
    }
    
    [[[ZoomInstantSDK shareInstance] getChatHelper] SendChatToAll:chatString];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    VideoZoomAppDelegate *delegate = (VideoZoomAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.canRotation = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
    
    VideoZoomAppDelegate *delegate = (VideoZoomAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.canRotation = NO;
}

- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [ZoomInstantSDK shareInstance].delegate = nil;
    [[KGModal sharedInstance] hideAnimated:NO];
    [self stopUpdateTimer];
}

- (void)keyBoardWillShow:(NSNotification *)notification {
    [self.chatInputView keyBoardWillShow:notification];
    self.chatView.hidden = NO;
    self.controlBarView.hidden = NO;
}

- (void)keyBoardDidShow:(NSNotification *)notification {
    [self.chatView updateFrame:NO notification:notification];
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    [self.chatInputView keyBoardWillHide:notification];
}

- (void)keyBoardDidHide:(NSNotification *)notification {
    [self.chatView updateFrame:YES notification:notification];
}


- (void)initSubView {
    
    [self initfullScreenCanvas];
    
    _topBarView = [[TopBarView alloc] init];

    [self updateTitleIsJoined:NO];
    
    __weak CanvasViewController *weakSelf = self;
    _topBarView.endOnClickBlock = ^(void) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure that you want to leave the session?"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Leave"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [[ZoomInstantSDK shareInstance] leaveSession:NO];
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                          }]];
        
        if ([[[[ZoomInstantSDK shareInstance] getSession] getMySelf] isHost]) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"End Session"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [[ZoomInstantSDK shareInstance] leaveSession:YES];
                                                              }]];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        if (popover)
        {
            UIButton *btn = weakSelf.topBarView.leaveBtn;
            popover.sourceView = btn;
            popover.sourceRect = btn.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        VideoZoomAppDelegate *appDelegate = (VideoZoomAppDelegate *)[UIApplication sharedApplication].delegate;
        [[appDelegate topViewController] presentViewController:alertController animated:YES completion:nil];
    };
    _topBarView.sessionInfoOnClickBlock = ^(void) {
        [weakSelf showSessionInfo];
    };
    
    [self.view addSubview:_topBarView];
    [self.view addSubview:self.switchShareBtn];
    
    [self.view addSubview:self.statisticLabel];
}

- (BottomBarView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[BottomBarView alloc] initWithDelegate:self];
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT - kTableHeight, SCREEN_WIDTH, kTableHeight);
        [self.view addSubview:_bottomView];
    }
    
    return _bottomView;
}

- (SwitchBtn *)switchShareBtn {
    if (!_switchShareBtn) {
        _switchShareBtn = [[SwitchBtn alloc] initWithFrame:CGRectZero];
        [_switchShareBtn setTitle:@"Switch to Share" forState:UIControlStateNormal];
        _switchShareBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_switchShareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _switchShareBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _switchShareBtn.clipsToBounds = YES;
        _switchShareBtn.layer.cornerRadius = 6;
        [_switchShareBtn addTarget:self action:@selector(switchToShare:) forControlEvents:UIControlEventTouchUpInside];
        _switchShareBtn.hidden = YES;
    }
    
    return _switchShareBtn;
}

- (ControlBar *)controlBarView {
    if (!_controlBarView) {
        _controlBarView = [[ControlBar alloc] init];
        __weak CanvasViewController *weakSelf = self;
        _controlBarView.chatOnClickBlock = ^(void) {
            [weakSelf.chatInputView showKeyBoard];
        };
        _controlBarView.shareOnClickBlock = ^(void) {
            if ([[[ZoomInstantSDK shareInstance] getShareHelper] isOtherSharing]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"Some one is alerady sharing";
                // Move to bottm center.
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:2.f];
                return;
            }
            [weakSelf showShareOptionView];
        };
    }
    return _controlBarView;
}

- (UILabel *)statisticLabel {
    if (!_statisticLabel) {
        _statisticLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statisticLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _statisticLabel.font = [UIFont systemFontOfSize:9.0];
        _statisticLabel.textColor = [UIColor whiteColor];
        _statisticLabel.numberOfLines = 1;
        _statisticLabel.textAlignment = 1;
        _statisticLabel.clipsToBounds = YES;
        _statisticLabel.layer.cornerRadius = 6.0;
        _statisticLabel.hidden = YES;
    }
    return _statisticLabel;
}

- (void)initfullScreenCanvas {
    self.fullScreenCanvas = [[ZoomView alloc] initWithFrame:self.view.bounds];
    self.fullScreenCanvas.backgroundColor = [UIColor blackColor];
    
    // subscribe my video;
    ZoomInstantSDKUser *mySelfUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    self.fullScreenCanvas.user = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    self.fullScreenCanvas.dataType = ZoomInstantSDKVideoType_VideoData;
    [[mySelfUser getVideoCanvas] subscribeWithView:self.fullScreenCanvas andAspectMode:ZoomInstantSDKVideoAspect_LetterBox];
    
    [self startUpdateTimer];
    [self.view addSubview:self.fullScreenCanvas];
    
    self.fullScreenCanvas.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    [self.fullScreenCanvas addGestureRecognizer:tapGesture];
}

- (void)onSingleTap {
    if ([self.chatInputView.chatTextField isEditing]) {
        [self.chatInputView hideKeyBoard];
        return;
    }
    
    if (self.chatView.hidden == NO) {
        [UIView animateWithDuration:0.3 animations:^{
            self.chatView.hidden = YES;
            self.controlBarView.hidden = YES;
            self.statisticLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.chatView.hidden = NO;
            self.controlBarView.hidden = NO;
            self.statisticLabel.alpha = 1.0;
        }];
    }
}

- (void)leave
{
    ZoomInstantSDKUser *user = self.fullScreenCanvas.user;
    if (user.shareStatus.sharingStatus == ZoomInstantSDKReceiveSharingStatus_Start) {
        [[user getShareCanvas] unSubscribeWithView:self.fullScreenCanvas];
    } else {
        [[user getVideoCanvas] unSubscribeWithView:self.fullScreenCanvas];
    }
    [self.fullScreenCanvas removeFromSuperview];
    [self stopThumbViewVideo];
    [self.bottomView removeAllThumberViewItem];
    [self.avatarArr removeAllObjects];
    
    [self stopUpdateTimer];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)noVideofailBack {
    ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    self.fullScreenCanvas.user = user;
    if (user.shareStatus.sharingStatus == ZoomInstantSDKReceiveSharingStatus_Start) {
        self.fullScreenCanvas.dataType = ZoomInstantSDKVideoType_ShareData;
        [[user getShareCanvas] subscribeWithView:self.fullScreenCanvas andAspectMode:ZoomInstantSDKVideoAspect_Original];
    } else {
        self.fullScreenCanvas.dataType = ZoomInstantSDKVideoType_VideoData;
        [[user getVideoCanvas] subscribeWithView:self.fullScreenCanvas andAspectMode:ZoomInstantSDKVideoAspect_LetterBox];
    }
}

- (void)showSessionInfo {
    NSLog(@"showSessionInfo");
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor whiteColor]];
    [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeNone];
    [[KGModal sharedInstance] setTapOutsideToDismiss:YES];
    [[KGModal sharedInstance] showWithContentView:[self alertViewOfSessionInfo] andAnimated:YES];
}

- (UIView*)alertViewOfSessionInfo {
    UIView *dialogView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 237)];
    dialogView.layer.masksToBounds = YES;
    
    NSArray *userArr = [[[ZoomInstantSDK shareInstance] getSession] getAllUsers];
    ZoomInstantSDKSession *session = [[ZoomInstantSDK shareInstance] getSession];
    
    //Title Label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 21, 256, 24)];
    titleLabel.text = NSLocalizedString(@"Session Information", @"");
    titleLabel.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [dialogView addSubview:titleLabel];
    
    UILabel *sessionNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(titleLabel.frame) + 25, 256, 20)];
    sessionNameTitle.text = NSLocalizedString(@"Session name", @"");
    sessionNameTitle.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    sessionNameTitle.textAlignment = NSTextAlignmentLeft;
    sessionNameTitle.font = [UIFont systemFontOfSize:12.0];
    [dialogView addSubview:sessionNameTitle];
    
    UILabel *sessionNameValue = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(sessionNameTitle.frame), 256, 16)];
    sessionNameValue.text = session.getSessionName;
    sessionNameValue.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    sessionNameValue.textAlignment = NSTextAlignmentLeft;
    sessionNameValue.font = [UIFont boldSystemFontOfSize:16.0];
    [dialogView addSubview:sessionNameValue];
    
    UILabel *pswTitle = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(sessionNameValue.frame) + 20, 256, 20)];
    pswTitle.text = NSLocalizedString(@"Password", @"");
    pswTitle.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    pswTitle.textAlignment = NSTextAlignmentLeft;
    pswTitle.font = [UIFont systemFontOfSize:12.0];
    [dialogView addSubview:pswTitle];
    
    BOOL hasPassword = (session.getSessionPassword && ![session.getSessionPassword isEqualToString:@""]);
    UILabel *pswValue = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(pswTitle.frame), 256, 16)];
    pswValue.text = hasPassword ? session.getSessionPassword : @"Not Set";
    pswValue.textColor = hasPassword ? RGBCOLOR(0x23, 0x23, 0x23) : RGBCOLOR(0x74, 0x74, 0x87);
    pswValue.textAlignment = NSTextAlignmentLeft;
    pswValue.font = [UIFont boldSystemFontOfSize:16.0];
    [dialogView addSubview:pswValue];
    
    UILabel *participantsTitle = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(pswValue.frame) + 20, 256, 20)];
    participantsTitle.text = NSLocalizedString(@"Participants", @"");
    participantsTitle.textColor = RGBCOLOR(0x74, 0x74, 0x87);
    participantsTitle.textAlignment = NSTextAlignmentLeft;
    participantsTitle.font = [UIFont systemFontOfSize:12.0];
    [dialogView addSubview:participantsTitle];
    
    NSUInteger count = userArr.count;
    if (count == 0) {
        count = 1;
    }
    UILabel *pValue = [[UILabel alloc] initWithFrame:CGRectMake(24, CGRectGetMaxY(participantsTitle.frame), 256, 16)];
    pValue.text = [NSString stringWithFormat:@"%@", @(count)];
    pValue.textColor = RGBCOLOR(0x23, 0x23, 0x23);
    pValue.textAlignment = NSTextAlignmentLeft;
    pValue.font = [UIFont boldSystemFontOfSize:16.0];
    [dialogView addSubview:pValue];
    
    return dialogView;
}

- (void)showShareOptionView {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Share" message:nil preferredStyle: UIAlertControllerStyleActionSheet];
    if (@available(iOS 11.0, *)) {
        [sheet addAction:[UIAlertAction actionWithTitle:@"Share Device Screen"
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                      BOOL isOtherSharing = [[[ZoomInstantSDK shareInstance] getShareHelper] isOtherSharing];
                                                      if (isOtherSharing) {
                                                          MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                          hud.mode = MBProgressHUDModeText;
                                                          hud.label.text = @"Others are sharing";
                                                          // Move to bottm center.
                                                          hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                          [hud hideAnimated:YES afterDelay:2.f];
                                                          return;
                                                      }
                                                      
                                                      if (@available(iOS 12.0, *)) {
                                                          RPSystemBroadcastPickerView *broadcastView = [[RPSystemBroadcastPickerView alloc] init];
                                                          broadcastView.preferredExtension = kScreenShareBundleId;
                                                          broadcastView.tag = kBroadcastPickerTag;
                                                          
                                                          [self.view addSubview:broadcastView];
                                                          
                                                          [self sendTouchDownEventToBroadcastButton];
                                                          
                                                      } else {
                                                          // Guide page
                                                      }
                                                  }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Share a Picture"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                  [UIView animateWithDuration: 0. delay: 0 options: UIViewAnimationOptionLayoutSubviews  animations:^{

                                                  } completion:^(BOOL finished){
                                                      BOOL isOtherSharing = [[[ZoomInstantSDK shareInstance] getShareHelper] isOtherSharing];
                                                      if (isOtherSharing) {
                                                          MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                          hud.mode = MBProgressHUDModeText;
                                                          hud.label.text = @"Others are sharing";
                                                          // Move to bottm center.
                                                          hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                                                          [hud hideAnimated:YES afterDelay:2.f];
                                                          return;
                                                      }
                                                      
                                                      
                                                      UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                                                      controller.delegate = self;
                                                      controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                      [self presentViewController:controller animated:YES completion:NULL];
                                                  } ];
                                              }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popover = sheet.popoverPresentationController;
    if (popover)
    {
        UIButton *btn = (UIButton*)self.controlBarView.shareBtn;
        popover.sourceView = btn;
        popover.sourceRect = btn.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)sendTouchDownEventToBroadcastButton
{
    if (@available(iOS 12.0, *)) {
        RPSystemBroadcastPickerView *broadcastView = [self.view viewWithTag:kBroadcastPickerTag];
        if (!broadcastView) return;

        
        for (UIView *subView in broadcastView.subviews) {
            if ([subView isKindOfClass:[UIButton class]])
            {
                UIButton *broadcastBtn = (UIButton *)subView;
                [broadcastBtn sendActionsForControlEvents:UIControlEventAllTouchEvents];
                break;
            }
        }
    }
}

- (void)showReconnectingUI
{
    [self stopThumbViewVideo];
    [self.bottomView removeAllThumberViewItem];
    [self.avatarArr removeAllObjects];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.chatView removeFromSuperview];
        [self.chatInputView removeFromSuperview];
        [self.controlBarView removeFromSuperview];
        self.statisticLabel.alpha = 0.0;
    }];
    
    [self updateTitleIsJoined:NO];
    ZoomInstantSDKUser *my = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    self.fullScreenCanvas.user = my;
    self.fullScreenCanvas.dataType = ZoomInstantSDKVideoType_VideoData;
    [my.getVideoCanvas subscribeWithView:self.fullScreenCanvas andAspectMode:ZoomInstantSDKVideoAspect_LetterBox];
}

- (void)showZoomPasswordAlert:(BOOL)wrongPwd
{
    NSString *message = wrongPwd ? NSLocalizedString(@"Incorrect password, please try again", @"") : NSLocalizedString(@"Please enter your password", @"");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] becomeFirstResponder];
    
    [alert show];
}


#pragma mark - uiimagepicker delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.shareView = [[UIView alloc] initWithFrame:self.view.bounds];
    UIImage *selectPic = info[UIImagePickerControllerOriginalImage];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 3.0;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleShareTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    self.selectImgView = [[UIImageView alloc] initWithImage:selectPic];
    self.selectImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.selectImgView.frame = self.view.bounds;
    
    [self.scrollView addSubview:self.selectImgView];
    [self.shareView addSubview:self.scrollView];
    [self.view addSubview:self.shareView];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    CGFloat bottom = IPHONE_X ? (landscape ? 21.f : 34.f) : 0.0;
    CGFloat right = IPHONE_X ? 44.0 : 0.0;
    CGFloat width = 104.0;
    CGFloat height = 28.0;
    
    self.stopShareBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - width - 16 - right, SCREEN_HEIGHT - 16 - height - bottom, width, height)];
    [self.stopShareBtn setTitle:@"STOP SHARE" forState:UIControlStateNormal];
    self.stopShareBtn.clipsToBounds = YES;
    self.stopShareBtn.layer.cornerRadius = height * 0.5;
    self.stopShareBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    self.stopShareBtn.backgroundColor = [UIColor redColor];
    [self.stopShareBtn addTarget:self action:@selector(stopShareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stopShareBtn];
    
    [[[ZoomInstantSDK shareInstance] getShareHelper] startShareWithView:self.shareView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.selectImgView;
}

- (void)handleDoubleShareTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGFloat zs = self.scrollView.zoomScale;
    zs = (zs == self.scrollView.minimumZoomScale) ? self.scrollView.maximumZoomScale : self.scrollView.minimumZoomScale;
    CGRect zoomRect = [self zoomRectForScale: zs withCenter: [gestureRecognizer locationInView: gestureRecognizer.view]];
    [self.scrollView zoomToRect: zoomRect animated: YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    CGFloat w = [self.scrollView frame].size.width;
    CGFloat h = [self.scrollView frame].size.height;
    zoomRect.size.height = h / scale;
    zoomRect.size.width  = w / scale;
    
    CGFloat x = center.x - (zoomRect.size.width  / 2.0);
    CGFloat y = center.y - (zoomRect.size.height / 2.0);
    
    CGSize shareSource = self.view.bounds.size;
    CGFloat offsetX = fabs(shareSource.width / scale - w) / 2;
    CGFloat offsetY = fabs(shareSource.height / scale - h) / 2;
    if (x < offsetX) x = 0;
    if (y < offsetY) y = 0;
    if (x > offsetX && (x + zoomRect.size.width) * scale > shareSource.width) x = (shareSource.width - w) / scale;
    if (y > offsetY && (y + zoomRect.size.height) * scale > shareSource.height) y = (shareSource.height - h) / scale;
    zoomRect.origin.x = x;
    zoomRect.origin.y = y;
    
    return zoomRect;
}

- (void)stopShareBtnClicked:(id)sender {
    NSLog(@"stop share");
    [self.shareView removeFromSuperview];
    [self.stopShareBtn removeFromSuperview];
    [[[ZoomInstantSDK shareInstance] getShareHelper] stopShare];
    
    [self pinMyself];
}


#pragma mark - ZoomInstantSDK delegate -
- (void)onError:(ZoomInstantSDKERROR)ErrorType detail:(NSInteger)details
{
    NSLog(@"ErrorType========%@, %@",@(ErrorType), [self formatErrorString:ErrorType]);
    NSLog(@"ErrorDetails========%@",@(details));
    
    switch (ErrorType) {
        case Errors_Session_Join_Failed:
        {
            [self leave];
        }
            break;
        case Errors_Session_Disconncting:
        {
        }
            break;
        case Errors_Session_Reconncting:
        {
            [self showReconnectingUI];
        }
            break;
        default:
            break;
    }
    
    NSString *string = [self formatErrorString:ErrorType];
    if (string) {
        string = [string stringByAppendingFormat:@". Error code: %@", @(details)];
        UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = string;
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:4.f];
    }
}

- (void)onSessionJoin {
    NSLog(@"onSessionJoin====>");
    
    _chatView = [[ChatView alloc] init];
    [self.view addSubview:_chatView];
    _chatView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap)];
    [_chatView addGestureRecognizer:tapGesture];
    
    self.chatInputView = [[ChatInputView alloc] initWithView:self.view];
    self.chatInputView.delegate = self;
    [self.view addSubview:self.chatInputView];
    self.chatInputView.hidden = NO;
    
    [self.view addSubview:self.controlBarView];
    
    [self updateTitleIsJoined:YES];
    
    ZoomInstantSDKUser *mySelf = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    if (mySelf) {
        [self onUserJoin:nil users:@[mySelf]];
    }
}

- (void)onSessionLeave {
    NSLog(@"onSessionLeave====>");
    [self leave];
}

- (void)onUserJoin:(ZoomInstantSDKUserHelper *)helper users:(NSArray<ZoomInstantSDKUser *> *)userArray {
    NSLog(@"onUserJoin====>");
    self.fullScreenCanvas.user = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    NSArray *allUser = [[[ZoomInstantSDK shareInstance] getSession] getAllUsers];
    for (int i = 0; i < allUser.count; i++) {
        ZoomInstantSDKUser *user = allUser[i];
        if ([self.avatarArr containsObject:user]) {
            continue;
        }
        
        [self.avatarArr addObject:user];
        
        ZoomView *view = [[ZoomView alloc] initWithFrame:CGRectMake(15, 10, kTableHeight - 15 * 2, kCellHeight - 10)];
        view.user = user;
        view.backgroundColor = [UIColor blackColor];
        view.dataType = ZoomInstantSDKVideoType_VideoData;
        
        [[user getVideoCanvas] subscribeWithView:view andAspectMode:ZoomInstantSDKVideoAspect_PanAndScan];
        
        ViewItem *item = [[ViewItem alloc] init];
        item.userId = user.getUserId;
        item.view = view;
        item.isActive = NO;
        item.itemName = user.getUserName;
        
        [self.bottomView addThumberViewItem:item];
        
        if (!helper) {
            [self viewItemSelected:item];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateAvatar:view user:user];
        });
    }
    [self.view insertSubview:self.controlBarView aboveSubview:self.bottomView];
    if (![[[ZoomInstantSDK shareInstance] getShareHelper] isSharingOut]) {
        [self.view bringSubviewToFront:self.chatInputView];
    }
    
    [self updateTitleIsJoined:YES];
}

- (void)onUserLeave:(ZoomInstantSDKUserHelper *)helper users:(NSArray<ZoomInstantSDKUser *> *)userArray {
    for (int i = 0; i < userArray.count; i++) {
        ZoomInstantSDKUser *user = userArray[i];
        
        NSArray *items = [self.bottomView getThumberViewItems:user.getUserId];
        for (ViewItem *item in items) {
            ZoomView *view = (ZoomView *)item.view;
            ZoomInstantSDKUser *user = [[[ZoomInstantSDK shareInstance] getSession] getUser:item.userId];
            if (user.shareStatus.sharingStatus == ZoomInstantSDKReceiveSharingStatus_Start) {
                [[user getShareCanvas] unSubscribeWithView:view];
            } else {
                [[user getVideoCanvas] unSubscribeWithView:view];
            }
        }
        [self.bottomView removeThumberViewItemWithUserId:user.getUserId];
        [self.avatarArr removeObject:user];
        
        if (self.fullScreenCanvas.user == user) {
            [self pinMyself];
        }
    }
    
    [self updateTitleIsJoined:YES];
}

- (ZoomView *)getBottomCanvsViewByUserId:(NSString *)userId {
    NSArray *viewItems = [self.bottomView getThumberViewItems:userId];
    ViewItem *item = [viewItems firstObject];
    ZoomView *view = (ZoomView *)item.view;
    return view;
}

- (void)updateAvatar:(ZoomView *)canvas user:(ZoomInstantSDKUser *)user{
    if (!canvas) {
        return;
    }
    
    NSMutableArray *needRemove = [NSMutableArray new];
    for (UIView *view in [canvas subviews]) {
        if (view.tag == kEmojiTag) {
            [needRemove addObject:view];
        }
        if (view.tag == kBackgroudTag) {
            [needRemove addObject:view];
        }
    }
    [needRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSLog(@"user.videoStatus.on=======%@",@(user.videoStatus.on));
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!user.videoStatus.on && (canvas.dataType != ZoomInstantSDKVideoType_ShareData)) {
            UIView *bgView = [[UIView alloc] initWithFrame:canvas.bounds];
            bgView.backgroundColor = RGBCOLOR(0x23, 0x23, 0x23);
            bgView.tag = kBackgroudTag;
            [canvas addSubview:bgView];
            [canvas insertSubview:bgView atIndex:1];
            
            ZoomInstantSDKUser *litter_user = [[[ZoomInstantSDK shareInstance] getSession] getUser:user.getUserId];
            NSInteger index = [self.avatarArr indexOfObject:litter_user];
            if (index == NSNotFound) index = 0;
            NSString *imageName = [NSString stringWithFormat:@"default_avatar"];
            UIImage *image = [UIImage imageNamed:imageName];
            UIImageView *view = [[UIImageView alloc] initWithImage:image];
            view.frame = CGRectMake(canvas.bounds.size.width * 0.25, canvas.bounds.size.height * 0.25, canvas.bounds.size.width * 0.5, canvas.bounds.size.height * 0.5);
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.tag = kEmojiTag;
            [canvas addSubview:view];
        }
    });
}

- (void)onUserVideoStatusChanged:(ZoomInstantSDKVideoHelper *)helper user:(NSArray <ZoomInstantSDKUser *>*)userArray {
    NSLog(@"onUserVideoStatusChanged====>: %@", userArray);

    NSArray *allUsers = [[[ZoomInstantSDK shareInstance] getSession] getAllUsers];
    NSLog(@"ok haha");
    for (int i = 0; i<allUsers.count; i++) {
        ZoomInstantSDKUser *user = allUsers[i];
        NSLog(@"Ok haha %@", [user getUserName]);
    }
    
    for (int i = 0; i < userArray.count; i++) {
        ZoomInstantSDKUser *user = userArray[i];
        
        // update full cavas avatar
        if (user == self.fullScreenCanvas.user) {
            [self updateAvatar:self.fullScreenCanvas user:user];
        }
        
        // update bottom cavas avatar
        ZoomView *canvas = [self getBottomCanvsViewByUserId:user.getUserId];
        [self updateAvatar:canvas user:user];
    }
}

- (void)onUserShareStatusChanged:(ZoomInstantSDKShareHelper *)helper user:(ZoomInstantSDKUser *)user status:(ZoomInstantSDKReceiveSharingStatus)status;
{
    NSLog(@"onUserShareStatusChanged====>%@, %@",user.getUserId, @(status));
    NSString *myId = [[[ZoomInstantSDK shareInstance] getSession] getMySelf].getUserId;
    if ([user.getUserId isEqualToString:myId]) {
        return;
    }
    
    if (status == ZoomInstantSDKReceiveSharingStatus_Start) {
        self.fullScreenCanvas.dataType = ZoomInstantSDKVideoType_ShareData;
        [[user getShareCanvas] subscribeWithView:self.fullScreenCanvas andAspectMode:ZoomInstantSDKVideoAspect_Original];
    } else if (status == ZoomInstantSDKReceiveSharingStatus_Stop) {
        self.fullScreenCanvas.dataType = ZoomInstantSDKVideoType_VideoData;
        [[user getVideoCanvas] subscribeWithView:self.fullScreenCanvas andAspectMode:ZoomInstantSDKVideoAspect_LetterBox];
    }
    
    self.fullScreenCanvas.user = user;
    [self updateAvatar:self.fullScreenCanvas user:user];
    
    if (user.shareStatus.sharingStatus == ZoomInstantSDKReceiveSharingStatus_Start) {
        self.switchShareBtn.sharedUser = user;
        NSArray *viewItems = [self.bottomView getThumberViewItems:user.getUserId];
        ViewItem *item = [viewItems firstObject];
        [self viewItemSelected:item];
        ZoomView *view = (ZoomView *)item.view;
        view.dataType = ZoomInstantSDKVideoType_VideoData;
        [[user getVideoCanvas] subscribeWithView:view andAspectMode:ZoomInstantSDKVideoAspect_LetterBox];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopThumbViewVideo];
            [self.bottomView scrollToVisibleArea:item];
        });
    } else {
        self.switchShareBtn.sharedUser = nil;
    }
    
    for (ViewItem *item in self.bottomView.viewArray) {
        if ([user.getUserId isEqualToString:item.userId]) {
            [self viewItemSelected:item];
        }
    }
    self.switchShareBtn.hidden = YES;
}

- (void)onUserActiveAudioChanged:(ZoomInstantSDKUserHelper *)helper users:(NSArray<ZoomInstantSDKUser *> *)userArray {
    for (ZoomInstantSDKUser *user in userArray) {
        [self.bottomView activeThumberViewItem:user.getUserId];
    }
    
    [self startSpeakerTimer];
}

- (void)onUserAudioStatusChanged:(ZoomInstantSDKAudioHelper *)helper user:(NSArray <ZoomInstantSDKUser *>*)userArray; {
// can update audio UI here
    NSString *myId = [[[ZoomInstantSDK shareInstance] getSession] getMySelf].getUserId;
    for (ZoomInstantSDKUser *user in userArray) {
        if ([user.getUserId isEqualToString:myId]) {
            if (user.audioStatus.audioType == ZoomInstantSDKAudioType_None) {
                [self.controlBarView.audioBtn setImage:[UIImage imageNamed:@"icon_no_audio"] forState:UIControlStateNormal];
            } else {
                if (!user.audioStatus.isMuted) {
                    [self.controlBarView.audioBtn setImage:[UIImage imageNamed:@"icon_mute"] forState:UIControlStateNormal];
                } else {
                    [self.controlBarView.audioBtn setImage:[UIImage imageNamed:@"icon_unmute"] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)onChatNewMessageNotify:(ZoomInstantSDKChatHelper *)helper message:(ZoomInstantSDKChatMessage *)chatMessage {
    [self.chatView.chatMsgArray addObject:chatMessage];
    [self.chatView.tableView reloadData];
    [self.chatView scrollToBottom];
}

- (void)onSessionNeedPassword:(ZoomInstantSDKERROR (^)(NSString *password, BOOL leaveSessionIgnorePassword))completion
{
    if (completion) {
        self.joinSessionOrIgnorePasswordBlock = completion;
        
        [self showZoomPasswordAlert:NO];
    }
}

- (void)onSessionPasswordWrong:(ZoomInstantSDKERROR (^)(NSString *password, BOOL leaveSessionIgnorePassword))completion
{
    if (completion) {
        self.joinSessionOrIgnorePasswordBlock = completion;
        
        [self showZoomPasswordAlert:YES];
    }
}

#pragma mark - BottomBarViewDelegate -
- (void)stopThumbViewVideo {
    for (ViewItem *item in self.bottomView.viewArray) {
        ZoomView *view = (ZoomView *)item.view;
        ZoomInstantSDKUser *user = view.user;
        if (user.shareStatus.sharingStatus == ZoomInstantSDKReceiveSharingStatus_Start) {
            [[user getShareCanvas] unSubscribeWithView:view];
        } else {
            [[user getVideoCanvas] unSubscribeWithView:view];
        }
    }
}

- (void)startThumbViewVideo {
    NSArray <UITableViewCell *> *cellArray = self.bottomView.thumbTableView.visibleCells;
    
    for (int i = 0; i < cellArray.count; i++) {
        UITableViewCell *cell = [cellArray objectAtIndex:i];
        NSIndexPath *indexPath = [self.bottomView.thumbTableView indexPathForCell:cell];
        
        ViewItem *item = [self.bottomView.viewArray objectAtIndex:indexPath.row];
        ZoomView *view = (ZoomView *)item.view;
        view.dataType = ZoomInstantSDKVideoType_VideoData;
        ZoomInstantSDKUser *user = view.user;
        [[user getVideoCanvas] subscribeWithView:view andAspectMode:ZoomInstantSDKVideoAspect_PanAndScan];
    }
}

- (void)pinThumberViewItem:(ViewItem *)item {
    
    if (!item) {
        return;
    }
    
    NSLog(@"Pin thumbernail view %@", item);
    ZoomInstantSDKUser *itemUser = [[[ZoomInstantSDK shareInstance] getSession] getUser:item.userId];
    
    ZoomInstantSDKUser *olduser = self.fullScreenCanvas.user;
    
    self.fullScreenCanvas.user = itemUser;
    self.fullScreenCanvas.dataType = ZoomInstantSDKVideoType_VideoData;
    [[itemUser getVideoCanvas] subscribeWithView:self.fullScreenCanvas andAspectMode:ZoomInstantSDKVideoAspect_PanAndScan];
    
    if (olduser.videoStatus.on != itemUser.videoStatus.on && self.fullScreenCanvas.dataType != ZoomInstantSDKVideoType_ShareData) {
         [self updateAvatar:self.fullScreenCanvas user:itemUser];;
    }
    
    [self viewItemSelected:item];
    
//    [self onUserVideoStatusChanged:@[@(item.userId)]];
    
    [self updateTitleIsJoined:YES];
    
    if (self.switchShareBtn.sharedUser) {
        self.switchShareBtn.hidden = NO;
    }
}

- (void)scrollToThumberViewItem:(ViewItem *)item {
    if (!item) {
        return;
    }
    
    UIView *view = item.view;
    ZoomInstantSDKUser *itemUser = [[[ZoomInstantSDK shareInstance] getSession] getUser:item.userId];
    [[itemUser getVideoCanvas] subscribeWithView:view andAspectMode:ZoomInstantSDKVideoAspect_PanAndScan];
}

- (void)pinMyself {
    ZoomInstantSDKUser *myUser = [[[ZoomInstantSDK shareInstance] getSession] getMySelf];
    for (ViewItem *item in self.bottomView.viewArray) {
        if ([myUser.getUserId isEqualToString:item.userId]) {
            [self pinThumberViewItem:item];
            [self.bottomView scrollToVisibleArea:item];
        }
    }
}

- (void)viewItemSelected:(ViewItem *)item {
    for (ViewItem *item in self.bottomView.viewArray) {
        item.view.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    }
    
    item.view.layer.borderColor = [UIColor greenColor].CGColor;
}

- (void)switchToShare:(SwitchBtn *)switchShareBtn {
    switchShareBtn.hidden = YES;
    
    if (!switchShareBtn.sharedUser) {
        return;
    }
    
    self.fullScreenCanvas.dataType = ZoomInstantSDKVideoType_ShareData;
    [[switchShareBtn.sharedUser getShareCanvas] subscribeWithView:self.fullScreenCanvas andAspectMode:ZoomInstantSDKVideoAspect_Original];
    
    for (ViewItem *item in self.bottomView.viewArray) {
        if ([switchShareBtn.sharedUser.getUserId isEqualToString:item.userId]) {
            [self viewItemSelected:item];
        }
    }
}

- (void)startSpeakerTimer {
    if ([self.speakerTimer isValid]) {
        [self stopSpeakerTimer];
    }
    if (@available(iOS 10.0, *)) {
        self.speakerTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:NO
                                                              block:^(NSTimer * _Nonnull timer) {
                                                                  [self speakerOffAll];
                                                              }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)stopSpeakerTimer {
    [self.speakerTimer invalidate];
    self.speakerTimer = nil;
}

- (void)speakerOffAll {
    [self.bottomView deactiveAllThumberView];
}

- (void)updateTitleIsJoined:(BOOL)isJoined
{
    BOOL beforeSession = NO;
    ZoomInstantSDKSession *session = [[ZoomInstantSDK shareInstance] getSession];
    if (!session) {
        beforeSession = YES;
    }
    
    if (beforeSession) {
        [self.topBarView updateTopBarWithSessionName:session.getSessionName totalNum:1 password:session.getSessionPassword isJoined:isJoined];
    } else {
        NSArray *allUsers = [session getAllUsers];
        [self.topBarView updateTopBarWithSessionName:session.getSessionName totalNum:allUsers.count password:session.getSessionPassword isJoined:isJoined];
    }
}

#pragma mark - uialertview -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (!self.joinSessionOrIgnorePasswordBlock) {
        return;
    }
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        //Join
        NSString *password = [alertView textFieldAtIndex: 0].text;
        ZoomInstantSDKERROR error = self.joinSessionOrIgnorePasswordBlock(password, NO);
        if (error != Errors_Success) {
            [self showZoomPasswordAlert:YES];
        }
        NSLog(@"Input password error code : %@", @(error));
    } else if (buttonIndex == alertView.cancelButtonIndex) {
        //Cancel
        ZoomInstantSDKERROR error = self.joinSessionOrIgnorePasswordBlock(nil, YES);
        NSLog(@"Cancel error code : %@", @(error));
    }
}

- (void)startUpdateTimer {
    if ([self.updateTimer isValid]) {
        [self stopUpdateTimer];
    }
    if (@available(iOS 10.0, *)) {
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES
                                                             block:^(NSTimer * _Nonnull timer) {
                                                                 [self updateStatisticInfo];
                                                             }];
    } else {
        // Fallback on earlier versions
    }
}

- (void)stopUpdateTimer {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)updateStatisticInfo {
    ZoomInstantSDKUser *user = self.fullScreenCanvas.user;
    NSString *statisticStr = @"";
    if (self.fullScreenCanvas.dataType == ZoomInstantSDKVideoType_VideoData) {
        ZoomInstantSDKVideoStatisticInfo *info = [user getVideoStatisticInfo];
        statisticStr = [NSString stringWithFormat:@"%@x%@ %@FPS", @(info.width), @(info.height), @(info.fps)];
    } else {
        ZoomInstantSDKShareStatisticInfo *info = [user getShareStatisticInfo];
        statisticStr = [NSString stringWithFormat:@"%@x%@ %@FPS", @(info.width), @(info.height), @(info.fps)];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![statisticStr isEqualToString:@"0x0 0FPS"]) {
            self.statisticLabel.hidden = NO;
            self.statisticLabel.text = statisticStr;
        } else {
            self.statisticLabel.hidden = YES;
            self.statisticLabel.text = statisticStr;
        }
    });
}

- (void)onDeviceOrientationChangeNotification:(NSNotification *)aNotification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if ((orientation == UIDeviceOrientationUnknown) || (orientation == UIDeviceOrientationFaceUp) || (orientation == UIDeviceOrientationFaceDown))
    {
        orientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }
    
    [[[ZoomInstantSDK shareInstance] getVideoHelper] rotateMyVideo:orientation];
}


@end
