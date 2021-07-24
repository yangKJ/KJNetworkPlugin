//
//  KJNetworkPluginManager.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  插件管理器，插件中枢神经
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJBaseNetworking.h"
#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN
/// 成功回调
typedef void(^_Nullable KJNetworkPluginSuccess)(KJNetworkingRequest * request, id responseObject);
/// 失败回调
typedef void(^_Nullable KJNetworkPluginFailure)(KJNetworkingRequest * request, NSError * error);
@interface KJNetworkPluginManager : KJBaseNetworking

/// 插件版网络请求
/// @param request 请求体
/// @param success 成功回调
/// @param failure 失败回调
+ (void)HTTPPluginRequest:(KJNetworkingRequest *)request success:(KJNetworkPluginSuccess)success failure:(KJNetworkPluginFailure)failure;

@end

NS_ASSUME_NONNULL_END
