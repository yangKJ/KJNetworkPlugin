//
//  KJEmptyProvider.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/10/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJEmptyProvider.h"

@interface KJEmptyProvider ()

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;

@end

@implementation KJEmptyProvider

- (instancetype)init{
    if (self = [super init]) {
        self.autoHidden = YES;
    }
    return self;
}

- (void)setSuperView:(UIView *)superView{
    _superView = superView;
    if (superView == nil) {
        _superView = [KJEmptyProvider topViewController].view;
    }
}

/// 再次加载按钮事件绑定，和 `clickRefreshButton` 按钮回调互斥
/// @param target 目标
/// @param action 事件
- (void)target:(id)target action:(SEL)action{
    self.target = target;
    self.action = action;
}

#pragma mark - privete method

/// 顶部控制器
+ (UIViewController *)topViewController{
    UIViewController *result = nil;
    UIWindow *window;
    if (@available(iOS 13.0, *)) {
        window = [UIApplication sharedApplication].windows.firstObject;
    } else if (@available(iOS 11.0, *)) {
        window = [[UIApplication sharedApplication] delegate].window;
    }
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
