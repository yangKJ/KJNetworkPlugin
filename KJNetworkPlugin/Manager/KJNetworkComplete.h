//
//  KJNetworkComplete.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/10/23.
//  https://github.com/yangKJ/KJNetworkPlugin

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KJNetworkingRequest;
/// 结果扩展
@interface KJNetworkComplete : NSObject

/// 请求体
@property (nonatomic, strong) __kindof KJNetworkingRequest * request;
/// 请求task
@property (nonatomic, strong, nullable) __kindof NSURLSessionTask * task;
/// 请求结果
@property (nonatomic, strong, nullable) id responseObject;
/// 失败信息
@property (nonatomic, strong, nullable) NSError * error;

/// 是否为缓存数据，配合 `KJNetworkCachePlugin` 插件使用
@property (nonatomic, assign, readonly) BOOL cacheData;
/// 网络请求标识符号
@property (nonatomic, assign, readonly) NSUInteger taskIdentifier;

@end

NS_ASSUME_NONNULL_END
