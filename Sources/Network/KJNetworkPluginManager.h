//
//  KJNetworkPluginManager.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin
//  插件管理器，插件中枢神经

#import "KJBaseNetworking.h"
#import "KJNetworkingRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 插件管理器，插件中枢神经
@interface KJNetworkPluginManager : KJBaseNetworking

/// 备注提示：关于插件版网络使用技巧
/// 插件的添加顺序需注意使用，因为插件在调用之时前面插件数据会影响后面插件数据
/// 成功回调的数据 `responseObject` 即为最后一个插件的处理数据
/// 偷偷告诉你隐藏用法，这里提供 KJNetworkThiefPlugin 插件，可以从这当中取到原始数据
/// 具体怎么使用，请查看文档：https://juejin.cn/post/6988730050820456455/

/// 插件版网络请求
/// @param request 请求体
/// @param success 成功回调
/// @param failure 失败回调
+ (void)HTTPPluginRequest:(KJNetworkingRequest *)request
                  success:(KJNetworkPluginSuccess)success
                  failure:(KJNetworkPluginFailure)failure;

@end

NS_ASSUME_NONNULL_END
