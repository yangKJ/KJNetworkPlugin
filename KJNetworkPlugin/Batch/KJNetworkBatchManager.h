//
//  KJNetworkBatchManager.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/26.
//  批量网络请求
//  https://github.com/yangKJ/KJNetworkPlugin

#import <Foundation/Foundation.h>
#import "KJBatchConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/// 批量重连回调
typedef BOOL(^_Nullable KJNetworkBatchReconnect)(NSArray<KJNetworkingRequest *> * reconnectArray);
/// 批量结果回调
typedef void(^_Nullable KJNetworkComplete)(NSArray<KJBatchResponse *> * result);
@interface KJNetworkBatchManager : NSObject

/// 批量网络请求
/// @param configuration 批量请求配置信息
/// @param reconnect 网络请求失败时候回调，返回YES再次继续批量处理
/// @param complete 最终结果回调，返回成功和失败数据数组
+ (void)HTTPBatchRequestConfiguration:(KJBatchConfiguration *)configuration
                            reconnect:(KJNetworkBatchReconnect)reconnect
                             complete:(KJNetworkComplete)complete;

@end

NS_ASSUME_NONNULL_END
