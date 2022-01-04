//
//  KJNetworkEmptyPlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/10/25.
//  https://github.com/yangKJ/KJNetworkPlugin
//  空数据UI展示插件

#import "KJNetworkBasePlugin.h"
#import "KJEmptyProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class KJEmptyDataView;
/// 空数据UI展示插件，其中包括网络请求失败，数据为空等系列
@interface KJNetworkEmptyPlugin : KJNetworkBasePlugin

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@property (nonatomic, strong, readonly) KJEmptyDataView * emptyView;

/// 初始化
/// @param provider 需求参数
- (instancetype)initWithEmptyProvider:(nullable KJEmptyProvider *)provider;

/// 主动显示空数据页面，不受自动隐藏的限制
- (void)showEmptyView;

/// 主动隐藏空数据页面
- (void)hideEmptyView;

@end

NS_ASSUME_NONNULL_END
