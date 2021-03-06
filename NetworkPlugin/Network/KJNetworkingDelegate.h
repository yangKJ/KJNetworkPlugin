//
//  KJNetworkDelegate.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin
//  插件协议，暂时抽离出来这几个方法。

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KJNetworkingRequest , KJNetworkingResponse;
/// 插件协议
@protocol KJNetworkDelegate <NSObject>

@optional;

/// 开始准备网络请求
/// @param request 请求相关数据
/// @param response 响应数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回缓存数据，successResponse 不为空表示存在缓存数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                  endRequest:(BOOL *)endRequest;

/// 网络请求开始时刻请求
/// @param request 请求相关数据
/// @param response 响应数据
/// @param stopRequest 是否停止网络请求
/// @return 返回网络请求开始时刻插件处理后的数据
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request
                                     response:(KJNetworkingResponse *)response
                                  stopRequest:(BOOL *)stopRequest;

/// 成功接收数据
/// @param request  接收成功数据
/// @param response 响应数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                againRequest:(BOOL *)againRequest;

/// 失败处理
/// @param request  失败的网络活动
/// @param response 响应数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                againRequest:(BOOL *)againRequest;

/// 准备返回给业务逻辑时刻调用
/// @param request 请求相关数据
/// @param response 响应数据
/// @param error 错误信息
/// @return 返回最终加工之后的数据
- (KJNetworkingResponse *)processSuccessResponseWithRequest:(KJNetworkingRequest *)request
                                                   response:(KJNetworkingResponse *)response
                                                      error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
