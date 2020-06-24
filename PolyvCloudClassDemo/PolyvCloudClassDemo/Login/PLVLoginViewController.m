//
//  PLVLoginViewController.m
//  PolyvCloudSchoolDemo
//
//  Created by zykhbl on 2018/8/8.
//  Copyright © 2018年 polyv. All rights reserved.
//
#import "PLVLoginViewController.h"
#import <Masonry/Masonry.h>
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import <PolyvCloudClassSDK/PLVLiveVideoAPI.h>
#import <PolyvCloudClassSDK/PLVLiveVideoConfig.h>
#import "PLVLiveViewController.h"
#import "PLVVodViewController.h"
#import "PCCUtils.h"

static NSString * const NSUserDefaultKey_VodLoginInfo = @"vodLoginInfo";
static NSString * const NSUserDefaultKey_LiveLoginInfo = @"liveLoginInfo";

@interface PLVLoginViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImgView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *liveBtn;
@property (nonatomic, weak) IBOutlet UIView *liveSelectView;
@property (nonatomic, weak) IBOutlet UIButton *vodBtn;
@property (nonatomic, weak) IBOutlet UIView *vodSelectView;
@property (nonatomic, weak) IBOutlet UITextField *channelIdTF;
@property (nonatomic, weak) IBOutlet UITextField *appIDTF;
@property (nonatomic, weak) IBOutlet UITextField *userIDTF;
@property (nonatomic, weak) IBOutlet UIView *userLineView;
@property (nonatomic, weak) IBOutlet UITextField *appSecretTF;
@property (nonatomic, weak) IBOutlet UIView *appSecretLineView;
@property (nonatomic, weak) IBOutlet UITextField *vIdTF;
@property (nonatomic, weak) IBOutlet UIView *vidLineView;
@property (nonatomic, weak) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UISwitch *enterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *viewerSwitch;
@property (weak, nonatomic) IBOutlet UILabel *viewerSwitchLabel;

@end

@implementation PLVLoginViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNotification];
    [self addGestureRecognizer];
}

- (void)dealloc {
    [self removeNotification];
}

#pragma mark - init
- (void)initUI {
    for (UIView *textField in self.view.subviews) {
        if ([textField isKindOfClass:UITextField.class]) {
            //使用了私有的实现修改UITextField里clearButton的图片
            UIButton *clearButton = [textField valueForKey:@"_clearButton"];
            [clearButton setImage:[UIImage imageNamed:@"plv_clear.png"] forState:UIControlStateNormal];
        }
    }
    
    self.liveSelectView.hidden = YES;
    [self switchLiveAction:self.liveBtn];
    self.loginBtn.layer.cornerRadius = self.loginBtn.bounds.size.height * 0.5;
}

#pragma mark - UIViewController+UIViewControllerRotation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;//登录窗口只支持竖屏方向
}

#pragma mark - Notification
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - GestureRecognizer
- (void)addGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapAction {
    [self.view endEditing:YES];
}

#pragma mark - IBAction
- (IBAction)switchLiveAction:(UIButton *)sender {
    [self switchToLiveUI];
}

- (IBAction)switchVodAction:(UIButton *)sender {
    [self switchToVodUI];
}

- (IBAction)loginButtonClickAction:(UIButton *)sender {
    [self tapAction];
    [self loginRequest];
}

- (IBAction)textEditChangedAction:(id)sender {
    [self refreshLoginBtnUI];
}

- (IBAction)videoDecodeSwitchChanged:(UISwitch *)sender {
    PLVLiveVideoConfig.sharedInstance.videoToolBox = sender.isOn;
    
    NSString *detail = @"硬解码效率更高，软解码兼容性更好。如果视频画面出现问题，如花屏、黑屏等可尝试切换软解码模式";
    [PCCUtils showHUDWithTitle:sender.isOn ? @"硬解码" : @"软解码" detail:detail view:self.view];
}

#pragma mark - UI control
- (void)refreshLoginBtnUI {
    if (!self.liveSelectView.hidden) {
        if ([self checkTextField:self.channelIdTF] || [self checkTextField:self.appIDTF] || [self checkTextField:self.userIDTF] || [self checkTextField:self.appSecretTF]) {
            self.loginBtn.enabled = NO;
            self.loginBtn.alpha = 0.4;
        } else {
            self.loginBtn.enabled = YES;
            self.loginBtn.alpha = 1.0;
        }
    } else {
        if ([self checkTextField:self.vIdTF] || [self checkTextField:self.appIDTF] || [self checkTextField:self.userIDTF] || [self checkTextField:self.channelIdTF] ) {
            self.loginBtn.enabled = NO;
            self.loginBtn.alpha = 0.4;
        } else {
            self.loginBtn.enabled = YES;
            self.loginBtn.alpha = 1.0;
        }
    }
}

- (void)switchToLiveUI {
    if (self.liveSelectView.hidden) {
        [self switchScenes:NO];
        NSArray *liveLoginInfo = [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultKey_LiveLoginInfo];
        if (liveLoginInfo) {
            self.channelIdTF.text = liveLoginInfo[0];
            self.appIDTF.text = liveLoginInfo[1];
            self.userIDTF.text = liveLoginInfo[2];
            self.appSecretTF.text = liveLoginInfo[3];
        } else {
            PLVLiveVideoConfig *liveConfig = [PLVLiveVideoConfig sharedInstance];
            self.channelIdTF.text = liveConfig.channelId;
            self.appIDTF.text = liveConfig.appId;
            self.userIDTF.text = liveConfig.userId;
            self.appSecretTF.text = liveConfig.appSecret;
        }
        [self refreshLoginBtnUI];
    }
}

- (void)switchToVodUI {
    if (self.vodSelectView.hidden) {
        [self switchScenes:YES];
        
        NSArray *vodLoginInfo = [[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultKey_VodLoginInfo];
        if (vodLoginInfo) {
            self.channelIdTF.text = vodLoginInfo[0];
            self.userIDTF.text = vodLoginInfo[1];
            self.appIDTF.text = vodLoginInfo[2];
            self.vIdTF.text = vodLoginInfo[3];
        } else {
            PLVLiveVideoConfig *liveConfig = [PLVLiveVideoConfig sharedInstance];
            self.channelIdTF.text = liveConfig.channelId;
            self.userIDTF.text = liveConfig.userId;
            self.appIDTF.text = liveConfig.appId;
            self.vIdTF.text = liveConfig.vodId;
        }
        [self refreshLoginBtnUI];
    }
}

- (void)switchScenes:(BOOL)flag {
    self.liveSelectView.hidden = flag;
    self.vodSelectView.hidden = !flag;
    self.vidLineView.hidden = self.vIdTF.hidden = !flag;
    self.viewerSwitchLabel.text = flag ? @"点播列表" : @"特邀观众";
}

#pragma mark - network request
- (void)loginRequest {
    PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    [hud.label setText:@"登录中..."];
    __weak typeof(self) weakSelf = self;
    if (!self.liveSelectView.hidden) {
        [[NSUserDefaults standardUserDefaults] setObject:@[self.channelIdTF.text, self.appIDTF.text, self.userIDTF.text, self.appSecretTF.text] forKey:NSUserDefaultKey_LiveLoginInfo];
        
        [PLVLiveVideoAPI verifyPermissionWithChannelId:self.channelIdTF.text.integerValue vid:@"" appId:self.appIDTF.text userId:self.userIDTF.text appSecret:self.appSecretTF.text completion:^(NSDictionary * _Nonnull data) {
            /// 设置聊天室相关的私有服务器的域名
            [PLVLiveVideoConfig setPrivateDomainWithData:data];
            
            [PLVLiveVideoAPI liveStatus2:weakSelf.channelIdTF.text completion:^(NSString *liveType, PLVLiveStreamState liveState) {
                [PLVLiveVideoAPI getChannelMenuInfos:weakSelf.channelIdTF.text.integerValue completion:^(PLVLiveVideoChannelMenuInfo *channelMenuInfo) {
                    [hud hideAnimated:YES];
                    [weakSelf presentToLiveViewControllerFromViewController:weakSelf liveState:liveState lievType:liveType channelMenuInfo:channelMenuInfo];
                } failure:^(NSError *error) {
                    NSLog(@"频道菜单获取失败！%@",error);
                    [hud hideAnimated:YES];
                    [weakSelf presentToLiveViewControllerFromViewController:weakSelf liveState:liveState lievType:liveType channelMenuInfo:nil];
                }];
            } failure:^(NSError *error) {
                [hud hideAnimated:YES];
                [PCCUtils presentAlertViewController:@"" message:error.localizedDescription inViewController:weakSelf];
            }];
        } failure:^(NSError *error) {
            [hud hideAnimated:YES];
            [weakSelf presentToAlertViewControllerWithError:error inViewController:weakSelf];
        }];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@[self.channelIdTF.text, self.userIDTF.text, self.appIDTF.text, self.vIdTF.text] forKey:NSUserDefaultKey_VodLoginInfo];
        
        [PLVLiveVideoAPI verifyPermissionWithChannelId:self.channelIdTF.text.integerValue vid:self.vIdTF.text appId:self.appIDTF.text userId:self.userIDTF.text appSecret:@"" completion:^(NSDictionary * _Nonnull data) {
            /// 设置聊天室相关的私有服务器的域名
            [PLVLiveVideoConfig setPrivateDomainWithData:data];
            
            [PLVLiveVideoAPI getVodType:self.vIdTF.text completion:^(BOOL vodType) {
                [hud hideAnimated:YES];
                if (vodType && weakSelf.viewerSwitch.isOn) {
                    [PCCUtils presentAlertViewController:@"" message:@"三分屏场景暂不支持使用点播列表播放" inViewController:weakSelf];
                    return;
                }
                
                [PLVLiveVideoAPI getChannelMenuInfos:weakSelf.channelIdTF.text.integerValue completion:^(PLVLiveVideoChannelMenuInfo *channelMenuInfo) {
                    [hud hideAnimated:YES];
                    [weakSelf presentToVodViewControllerFromViewController:weakSelf vodType:vodType channelMenuInfo:channelMenuInfo];
                } failure:^(NSError *error) {
                    NSLog(@"频道菜单获取失败！%@",error);
                    [hud hideAnimated:YES];
                    [weakSelf presentToVodViewControllerFromViewController:weakSelf vodType:vodType channelMenuInfo:nil];
                }];
            } failure:^(NSError *error) {
                [hud hideAnimated:YES];
                [weakSelf presentToAlertViewControllerWithError:error inViewController:weakSelf];
            }];
        } failure:^(NSError *error) {
            [hud hideAnimated:YES];
            [weakSelf presentToAlertViewControllerWithError:error inViewController:weakSelf];
        }];
    }
}

#pragma mark - present ViewController
- (void)presentToLiveViewControllerFromViewController:(UIViewController *)vc liveState:(PLVLiveStreamState)liveState lievType:(NSString *)liveType channelMenuInfo:(PLVLiveVideoChannelMenuInfo *)channelMenuInfo {
    if (self.viewerSwitch.isOn) {
        if (!channelMenuInfo) {
            [PCCUtils showHUDWithTitle:@"频道菜单获取失败，请稍后再试" detail:nil view:self.view];
            return;
        }else if (channelMenuInfo.rtcType.length == 0 || [channelMenuInfo.rtcType isEqualToString:@"urtc"]){
            [PCCUtils showHUDWithTitle:@"特邀观众暂不支持该rtc类型" detail:nil view:self.view];
            return;
        }
    }
    
    //必需先设置 PLVLiveVideoConfig 单例里需要的信息，因为在后面的加载中需要使用
    PLVLiveVideoConfig *liveConfig = [PLVLiveVideoConfig sharedInstance];
    liveConfig.channelId = self.channelIdTF.text;
    liveConfig.appId = self.appIDTF.text;
    liveConfig.userId = self.userIDTF.text;
    liveConfig.appSecret = self.appSecretTF.text;
    
    PLVLiveViewController *liveVC = [PLVLiveViewController new];
    liveVC.liveType = [@"ppt" isEqualToString:liveType] ? PLVLiveViewControllerTypeCloudClass : PLVLiveViewControllerTypeLive;
    liveVC.liveState = liveState;
    liveVC.viewer = self.viewerSwitch.isOn;
    liveVC.channelMenuInfo = channelMenuInfo;
    
    // 读取app配置信息
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    id chaseFrame = [userDefaults objectForKey:@"chaseFrame_enabled"];
    if (chaseFrame) {
        liveVC.chaseFrame = [chaseFrame boolValue];
    }
    
    // 抽奖功能必须固定唯一的 nickName 和 userId，如果忘了填写上次的中奖信息，有固定的 userId 还会再次弹出相关填写页面
//    liveVC.nickName = @"iOS user"; // 设置登录聊天室的用户名
//    liveVC.avatarUrl = @"https://"; // 设置自定义聊天室用户头像地址
    
    if (self.enterSwitch.isOn) {
        liveVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [vc presentViewController:liveVC animated:YES completion:nil];
    } else {
        // 支持导航跳转，暂不支持系统导航栏控制（影响UI及退出等）
        [self.navigationController pushViewController:liveVC animated:YES];
    }
}

- (void)presentToVodViewControllerFromViewController:(UIViewController *)vc vodType:(BOOL)vodType channelMenuInfo:(PLVLiveVideoChannelMenuInfo *)channelMenuInfo {
    //必需先设置 PLVLiveVideoConfig 单例里需要的信息，因为在后面的加载中需要使用
    PLVLiveVideoConfig *liveConfig = [PLVLiveVideoConfig sharedInstance];
    liveConfig.vodId = self.vIdTF.text;
    liveConfig.appId = self.appIDTF.text;
    liveConfig.appSecret = self.appSecretTF.text;
    // 用于回放跑马灯显示
    liveConfig.channelId = self.channelIdTF.text;
    liveConfig.userId = self.userIDTF.text;
    
    PLVVodViewController *vodVC = [PLVVodViewController new];
    vodVC.vodType = vodType ? PLVVodViewControllerTypeCloudClass : PLVVodViewControllerTypeLive;
    vodVC.channelMenuInfo = channelMenuInfo;
    vodVC.vodList = self.viewerSwitch.isOn;
    
    if (self.enterSwitch.isOn) {
        vodVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [vc presentViewController:vodVC animated:YES completion:nil];
    } else {
        // 支持导航跳转，暂不支持系统导航栏控制（影响UI及退出等）
        [self.navigationController pushViewController:vodVC animated:YES];
    }
}

- (void)presentToAlertViewControllerWithError:(NSError *)error inViewController:(UIViewController *)vc {
    [PCCUtils presentAlertViewController:@"" message:error.localizedDescription inViewController:vc];
}

#pragma mark - keyboard control
- (void)keyboardWillShow:(NSNotification *)notification {
    [self followKeyboardAnimation:UIEdgeInsetsMake(-110.0, 0.0, 110.0, 0.0) duration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] flag:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self followKeyboardAnimation:UIEdgeInsetsZero duration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] flag:NO];
}

- (void)followKeyboardAnimation:(UIEdgeInsets)contentInsets duration:(NSTimeInterval)duration flag:(BOOL)flag {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:MAX(0.0, duration - 0.1) animations:^{
            weakSelf.logoImgView.hidden = flag;
            weakSelf.titleLabel.hidden = !flag;
            weakSelf.scrollView.contentInset = contentInsets;
            weakSelf.scrollView.scrollIndicatorInsets = contentInsets;
        }];
    });
}

#pragma mark - textfield input validate
- (BOOL)checkTextField:(UITextField *)textField {
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textField.text.length == 0) {
        return YES;
    }
    return NO;
}

@end
