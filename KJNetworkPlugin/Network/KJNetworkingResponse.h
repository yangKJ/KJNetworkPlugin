//
//  KJNetworkingResponse.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  响应结果相关
//  https://github.com/yangKJ/KJNetworkPlugin

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KJBaseNetworking.h"

NS_ASSUME_NONNULL_BEGIN
/// 插件请求时机
typedef NS_ENUM(NSUInteger, KJNetworkingRequestOpportunity) {
    KJNetworkingRequestOpportunityPrepare, /// 开始准备网络请求
    KJNetworkingRequestOpportunityWillSend,/// 网络请求开始时刻请求
    KJNetworkingRequestOpportunitySuccess, /// 成功
    KJNetworkingRequestOpportunityFailure, /// 失败
    KJNetworkingRequestOpportunityProcess  /// 最终处理时刻
};
@interface KJNetworkingResponse : NSObject

/// 网络请求插件时机，
@property (nonatomic, assign) KJNetworkingRequestOpportunity opportunity;

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

/// 临时数据，内部最终返回时刻处理插件使用
@property (nonatomic, strong, readonly) id tempResponse;

@end

NS_ASSUME_NONNULL_END
