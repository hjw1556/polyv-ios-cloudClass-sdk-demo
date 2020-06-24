//
//  PLVBaseMediaViewController+PPT.h
//  PolyvCloudClassDemo
//
//  Created by zykhbl on 2018/8/1.
//  Copyright © 2018年 polyv. All rights reserved.
//

#import "PLVBaseMediaViewController.h"
#import "PLVMediaSecondaryView.h"

/// 云课堂播放器类别 - PLVBaseMediaViewController 的 PPT 类别（PPT相关功能：1.显示或隐藏副屏窗口；2.主副屏切换；3.切换主副屏兼容连麦的窗口切换）
@interface PLVBaseMediaViewController (PPT) <PLVMediaSecondaryViewDelegate>

#pragma mark - public
/// 横竖屏旋转动画开始前
- (void)dealDeviceOrientationBeignAnimation;

/// 横竖屏旋转动画结束时
- (void)dealDeviceOrientationEndAnimation;

/// 横竖屏旋转动画
- (void)dealDeviceOrientationDidChangeSubAnimation;

/// 切换主副屏的操作
- (void)dealSwitchAction:(BOOL)manualControl;

/// 打开副屏
- (void)openSecondaryView;

/// 关闭副屏
- (void)closeSecondaryView:(PLVPlayerSkinView *)skinView;

/// 直播时，关闭或打开副屏时，调整连麦顶部窗口的frame
- (void)resetLinkMicTopControlFrame:(BOOL)close;

/// 在暖场准备好播放时的回调里调用
- (void)subPlaybackIsPreparedToPlay:(NSNotification *)notification;

/// 在主播放器准备好播放时的回调里调用
- (void)mainPlaybackIsPreparedToPlay:(NSNotification *)notification;

@end
