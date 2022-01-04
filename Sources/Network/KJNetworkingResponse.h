//
//  KJNetworkingResponse.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin
//  响应结果相关

#import <Foundation/Foundation.h>
#import "KJNetworkingType.h"

NS_ASSUME_NONNULL_BEGIN

/// 响应结果相关
@interface KJNetworkingResponse : NSObject

/// 网络请求插件时机，
@property (nonatomic, assign) KJRequestOpportunity opportunity;

/// 原始网络成功返回数据，未经过任何处理
@property (nonatomic, strong, readonly) id responseObject;
/// 插件处理过成功数据，未处理时刻为空
@property (nonatomic, strong, readonly) id successResponse;
/// 插件处理过失败数据，未处理时刻为空
@property (nonatomic, strong, readonly) id failureResponse;
/// 准备插件处理的数据，未处理时刻为空
@property (nonatomic, strong, readonly) id prepareResponse;
/// 最终加工处理的数据，未处理时刻为空
@property (nonatomic, strong, readonly) id processResponse;
/// 网络请求task
@property (nonatomic, strong, readonly) NSURLSessionDataTask *task;
/// 失败
@property (nonatomic, strong, readonly) NSError *error;

@end

NS_ASSUME_NONNULL_END
