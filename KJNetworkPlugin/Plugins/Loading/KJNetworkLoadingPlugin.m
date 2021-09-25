//
//  KJNetworkLoadingPlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/27.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkLoadingPlugin.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface KJNetworkLoadingPlugin ()

@property (nonatomic, strong) MBProgressHUD *failHud;

@end

@implementation KJNetworkLoadingPlugin

- (instancetype)init{
    if (self = [super init]) {
        self.loadDisplayString = @"";
        self.displayErrorMessage = NO;
        self.displayLoading = NO;
        self.delayHiddenLoading = 0.0;
        self.displayInWindow = YES;
    }
    return self;
}

/// 开始准备网络请求
/// @param request 请求相关数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回缓存数据，successResponse 不为空表示存在缓存数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request endRequest:(BOOL *)endRequest{
    [super prepareWithRequest:request endRequest:endRequest];
    
    // 清除上次的错误提示
    if (self.displayErrorMessage && self.failHud) {
        [KJNetworkLoadingPlugin hideMBProgressHUD];
        NSTimer * hideDelayTimer = [self.failHud valueForKey:@"hideDelayTimer"];
        if (hideDelayTimer) {
            [hideDelayTimer invalidate];
            hideDelayTimer = nil;
        }
        self.failHud = nil;
    }
    
    return self.response;
}

/// 网络请求开始时刻请求
/// @param request 请求相关数据
/// @param stopRequest 是否停止网络请求
/// @return 返回网络请求开始时刻插件处理后的数据
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request stopRequest:(BOOL *)stopRequest{
    [super willSendWithRequest:request stopRequest:stopRequest];
    
    // 显示加载框
    if (self.displayLoading) {
        MBProgressHUD * hud = nil;
        if (self.displayInWindow) {
            hud = [MBProgressHUD HUDForView:[KJNetworkLoadingPlugin kKeyWindow]];
        } else {
            hud = [MBProgressHUD HUDForView:[KJNetworkLoadingPlugin topViewController].view];
        }
        if (hud == nil) {
            [KJNetworkLoadingPlugin createMBProgressHUDWithMessage:self.loadDisplayString
                                                            window:self.displayInWindow
                                                             delay:0];
        }
    }
    
    return self.response;
}

/// 成功接收数据
/// @param request  接收成功数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    [super succeedWithRequest:request againRequest:againRequest];
    
    // 隐藏加载框
    if (self.displayLoading) {
        if (self.delayHiddenLoading) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayHiddenLoading * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [KJNetworkLoadingPlugin hideMBProgressHUD];
            });
        } else {
            [KJNetworkLoadingPlugin hideMBProgressHUD];
        }
    }
    
    return self.response;
}

/// 失败处理
/// @param request  失败的网络活动
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    [super failureWithRequest:request againRequest:againRequest];
    
    // 错误提醒
    if (self.displayErrorMessage) {
        if (self.delayHiddenLoading) {
            __weak __typeof(&*self) weakself = self;
            NSString * string = [self.response.error.localizedDescription copy];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayHiddenLoading * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                if (weakself.response.responseObject == nil) {
                    weakself.failHud = [KJNetworkLoadingPlugin showTipMessage:string
                                                                       window:weakself.displayInWindow
                                                                        delay:2];
                }
            });
        } else {
            self.failHud = [KJNetworkLoadingPlugin showTipMessage:self.response.error.localizedDescription
                                                           window:self.displayInWindow
                                                            delay:2];
        }
    }
    
    return self.response;
}

#pragma mark - method

/// 隐藏加载小菊花
+ (void)hideMBProgressHUD{
    [MBProgressHUD hideHUDForView:[self topViewController].view animated:YES];
    [MBProgressHUD hideHUDForView:[self kKeyWindow] animated:YES];
}

/// 创建小菊花加载
+ (MBProgressHUD *)createMBProgressHUDWithMessage:(NSString *)message window:(BOOL)window delay:(NSTimeInterval)delay{
    // 隐藏加载框
    [self hideMBProgressHUD];
    
    UIView *view = window ? [self kKeyWindow] : [self topViewController].view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = message ? message : NSLocalizedString(@"Loading", nil);
    hud.label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    hud.label.numberOfLines = 0;
    hud.backgroundView.color = [UIColor colorWithRed:18/255.0 green:20/255.0 blue:20/255.0 alpha:0.1];
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [UIColor.blackColor colorWithAlphaComponent:0.7];
    hud.bezelView.layer.cornerRadius = 14;
    hud.label.textColor = UIColor.whiteColor;
    
    hud.mode = MBProgressHUDModeIndeterminate;
    if (delay > 0) {
        [hud hideAnimated:YES afterDelay:delay];
    }
    hud.label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    
    // 设置菊花框为白色
    UIActivityIndicatorView *indicatorView = [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]];
    indicatorView.color = [UIColor whiteColor];
    
    return hud;
}

/// 显示提示文本
+ (void)showTipHUD:(NSString *)message{
    [self showTipMessage:message window:YES delay:2.5];
}

+ (MBProgressHUD *)showTipMessage:(NSString *)message window:(BOOL)window delay:(NSTimeInterval)delay{
    MBProgressHUD *hud = [self createMBProgressHUDWithMessage:message window:window delay:delay];
    hud.mode = MBProgressHUDModeText;
    if (delay > 0) {
        [hud hideAnimated:YES afterDelay:delay];
    }
    hud.bezelView.color = [UIColor.blackColor colorWithAlphaComponent:0.7];
    hud.bezelView.layer.cornerRadius = 14;
    hud.label.textColor = UIColor.whiteColor;
    hud.contentColor = UIColor.whiteColor;
    hud.offset = CGPointMake(0, [UIScreen mainScreen].bounds.size.height / 3);
    
    return hud;
}


+ (UIView *)kKeyWindow{
    UIWindow *window;
    if (@available(iOS 13.0, *)) {
        window = [UIApplication sharedApplication].windows.firstObject;
    } else if (@available(iOS 11.0, *)) {
        window = [[UIApplication sharedApplication] delegate].window;
    }
    return (UIView *)window;
}

/// 顶部控制器
+ (UIViewController *)topViewController{
    UIViewController *result = nil;
    UIWindow *window = (UIWindow *)[self kKeyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *vc = window.rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController * tabbar = (UITabBarController *)vc;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        result = nav.childViewControllers.lastObject;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UIViewController * nav = (UIViewController *)vc;
        result = nav.childViewControllers.lastObject;
    } else {
        result = vc;
    }
    return result;
}

@end
