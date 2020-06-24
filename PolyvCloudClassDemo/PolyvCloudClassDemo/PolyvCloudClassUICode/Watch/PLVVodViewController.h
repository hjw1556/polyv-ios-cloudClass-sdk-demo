//
//  PLVVodViewController.h
//  PolyvCloudClassDemo
//
//  Created by zykhbl on 2018/8/30.
//  Copyright © 2018年 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PolyvCloudClassSDK/PolyvCloudClassSDK.h>

/// 回放类型
typedef NS_ENUM(NSInteger, PLVVodViewControllerType) {
    /// 普通直播
    PLVVodViewControllerTypeLive = 1,
    /// 云课堂
    PLVVodViewControllerTypeCloudClass = 2
};

/// 回放控制器
@interface PLVVodViewController : UIViewController

/// 回放类型（1：普通直播；2：云课堂）
@property (nonatomic, assign) PLVVodViewControllerType vodType;
/// 聊天室相关的Tab信息
@property (nonatomic, strong) PLVLiveVideoChannelMenuInfo *channelMenuInfo;

/// 点播列表
@property (nonatomic, assign) BOOL vodList;

@end
