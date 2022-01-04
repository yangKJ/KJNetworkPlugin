//
//  KJNetworkChainManager.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/26.
//  https://github.com/yangKJ/KJNetworkPlugin
//  链式网络请求

#import <Foundation/Foundation.h>
#import "KJNetworkingRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 链式网络成功回调
typedef void(^_Nullable KJNetworkChainSuccess)(NSArray<id> * responseArray);
/// 链式网络失败回调
typedef void(^_Nullable KJNetworkChainFailure)(NSError * error);
/// 链式网络处理下一个请求体
typedef __kindof KJNetworkingRequest * _Nullable(^_Nullable KJNetworkNextChainRequest)(id responseObject);

/// 链式网络请求
@interface KJNetworkChainManager : NSObject

/// 链式网络请求
/// @param request 请求体系
/// @param success 全部成功回调，存放请求所有结果数据
/// @param failure 失败回调，只要一个失败就会响应
/// @param chain 链式回调，返回下个网络请求体，为空时即可结束后续请求，responseObject上个网络请求响应数据
+ (void)HTTPChainRequest:(__kindof KJNetworkingRequest *)request
                 success:(KJNetworkChainSuccess)success
                 failure:(KJNetworkChainFailure)failure
                   chain:(KJNetworkNextChainRequest)chain,... NS_REQUIRES_NIL_TERMINATION;


//******************************** 链式网络请求 ********************************

/// 链式网络请求，需 `chain` 和 `lastchain` 配合使用
/// @param request 请求体系
/// @param failure 失败回调，只要一个失败就会响应
/// @return 返回自身对象
+ (instancetype)HTTPChainRequest:(__kindof KJNetworkingRequest *)request failure:(KJNetworkChainFailure)failure;
/// 请求体传递载体，回调返回上一个网络请求结果
@property (nonatomic, copy, readonly) KJNetworkChainManager * (^chain)(KJNetworkNextChainRequest);
/// 最后链数据回调，回调最后一个网络请求结果
@property (nonatomic, copy, readonly) void(^lastChain)(void(^)(id responseObject));

//******************************** 链式网络请求 ********************************

@end

NS_ASSUME_NONNULL_END
