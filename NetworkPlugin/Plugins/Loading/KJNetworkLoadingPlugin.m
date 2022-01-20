//
//  KJNetworkLoadingPlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/27.
//  https://github.com/yangKJ/KJNetworkPlugin

///`MBProgressHUD`文档
/// https://github.com/jdg/MBProgressHUD

#import "KJNetworkLoadingPlugin.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation KJNetworkLoadingPlugin

- (instancetype)init{
    if (self = [super init]) {
        self.loadDisplayString = @"";
        self.displayLoading = NO;
        self.delayHiddenLoading = 0.0;
        self.displayInWindow = YES;
    }
    return self;
}

/// 网络请求开始时刻请求
/// @param request 请求相关数据
/// @param response 响应数据
/// @param stopRequest 是否停止网络请求
/// @return 返回网络请求开始时刻插件处理后的数据
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request
                                     response:(KJNetworkingResponse *)response
                                  stopRequest:(BOOL *)stopRequest{
    
    // 显示加载框
    if (self.displayLoading) {
        [KJNetworkLoadingPlugin createMBProgressHUDWithMessage:self.loadDisplayString
                                                        window:self.displayInWindow
                                                         delay:0];
    }
    
    return response;
}

/// 成功接收数据
/// @param request  接收成功数据
/// @param response 响应数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                againRequest:(BOOL *)againRequest{
    
    [self hideLoading];
    
    return response;
}

- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request response:(KJNetworkingResponse *)response againRequest:(BOOL *)againRequest {
    
    [self hideLoading];
    
    return response;
}

#pragma mark - method

/// 隐藏加载框
- (void)hideLoading{
    if (self.displayLoading && self.delayHiddenLoading) {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, self.delayHiddenLoading * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [KJNetworkLoadingPlugin hideMBProgressHUD];
        });
    } else if (self.displayLoading) {
        [KJNetworkLoadingPlugin hideMBProgressHUD];
    }
}

/// 隐藏加载小菊花
+ (void)hideMBProgressHUD{
    [MBProgressHUD hideHUDForView:[self topViewController].view animated:YES];
    [MBProgressHUD hideHUDForView:[self kKeyWindow] animated:YES];
}

/// 创建小菊花加载
+ (MBProgressHUD *)createMBProgressHUDWithMessage:(NSString *)message window:(BOOL)window delay:(NSTimeInterval)delay{
    // 隐藏加载框
    [self hideMBProgressHUD];
    
    // 设置菊花框为白色
    UIActivityIndicatorView * indicatorView =
    [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]];
    indicatorView.color = [UIColor whiteColor];
    
    UIView *view = window ? [self kKeyWindow] : [self topViewController].view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = message ? message : NSLocalizedString(@"Loading", nil);
    hud.label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    hud.label.numberOfLines = 0;
    hud.backgroundView.color = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.1];
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
        for (UIWindow * win in windows) {
            if (win.windowLevel == UIWindowLevelNormal) {
                window = win;
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
