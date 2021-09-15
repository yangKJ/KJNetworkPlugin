//
//  KJNetworkLoadingPlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/27.
//  https://github.com/yangKJ/KJNetworkPlugin
//  加载动画插件

#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN
@class MBProgressHUD;
/// 加载动画插件
@interface KJNetworkLoadingPlugin : KJNetworkBasePlugin

/// 是否显示再Window，默认YES
@property (nonatomic, assign) BOOL displayInWindow;
/// 是否需要显示加载小菊花，默认NO
@property (nonatomic, assign) BOOL displayLoading;
/// 是否需要展示错误提示，默认NO
@property (nonatomic, assign) BOOL displayErrorMessage;
/// 加载显示内容，默认空
@property (nonatomic, strong, nullable) NSString *loadDisplayString;
/// 故意延迟消失加载loading，默认零秒
@property (nonatomic, assign) CGFloat delayHiddenLoading;

/// 创建小菊花加载
/// @param message 显示文字
/// @param window 是否显示在窗口
/// @param delay 延迟展示时间
+ (MBProgressHUD *)createMBProgressHUDWithMessage:(NSString *)message
                                           window:(BOOL)window
                                            delay:(NSTimeInterval)delay;
/// 隐藏加载小菊花
+ (void)hideMBProgressHUD;

/// 显示提示文本
+ (void)showTipHUD:(NSString *)message;
/// 显示提示文本
/// @param message 显示内容
/// @param window 是否显示在窗口
/// @param delay 延迟展示时间
+ (void)showTipMessage:(NSString *)message
                window:(BOOL)window
                 delay:(NSTimeInterval)delay;

/// 窗口视图
+ (UIView *)kKeyWindow;
/// 顶部控制器
+ (UIViewController *)topViewController;

@end

NS_ASSUME_NONNULL_END
