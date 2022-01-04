//
//  KJBatchConfiguration.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/26.
//  https://github.com/yangKJ/KJNetworkPlugin
//  批量网络请求配置文件

#import <Foundation/Foundation.h>
#import "KJNetworkingRequest.h"

NS_ASSUME_NONNULL_BEGIN
/// 网络请求失败重连时机
typedef NS_ENUM(NSUInteger, KJBatchReRequestOpportunity) {
    KJBatchReRequestOpportunityNone = 0,/// 不重新请求
    KJBatchReRequestOpportunityOther,   /// 其余网络请求之后
    KJBatchReRequestOpportunityPromptly,/// 立即重连
};
/// 批量网络请求配置文件
@interface KJBatchConfiguration : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/// 默认初始化方法
+ (instancetype)sharedBatch;

/// 设置网络并发最大数量，默认5条
@property (nonatomic, assign) NSInteger maxQueue;
/// 设置最大失败重调次数，默认3次
@property (nonatomic, assign) NSInteger againCount;
/// 网络连接失败重连时机，默认 KJBatchReRequestOpportunityNone
@property (nonatomic, assign) KJBatchReRequestOpportunity opportunity;

/// 批量请求体，
@property (nonatomic, strong) NSArray<__kindof KJNetworkingRequest *> * requestArray;

@end

/// 批量网络请求结果体
@interface KJBatchResponse : NSObject

@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSError *error;

@end

NS_ASSUME_NONNULL_END
