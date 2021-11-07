//
//  KJEmptyProvider.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/10/25.
//  https://github.com/yangKJ/KJNetworkPlugin
//  空数据展示需求参数

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 空数据展示需求参数
@interface KJEmptyProvider : NSObject

/// 展示页面对应控件，默认当前控件
@property (nonatomic, strong, nullable) UIView *superView;
/// 是否自动显示空数据UI控件，默认yes
/// 自动只支持 `UITableView` 和 `UICollectionView` 两种展示控件
@property (nonatomic, assign) BOOL autoHidden;

/// 再次刷新按钮点击回调
@property (nonatomic, copy, readwrite) dispatch_block_t clickRefreshButton;

@property (nonatomic, assign, readonly) SEL action;
/// 再次加载按钮事件绑定，和 `clickRefreshButton` 按钮回调互斥
/// @param target 目标
/// @param action 事件
- (void)target:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
