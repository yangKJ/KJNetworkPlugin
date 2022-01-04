//
//  KJBatchConfiguration.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/26.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJBatchConfiguration.h"

@implementation KJBatchConfiguration

/// 默认初始化方法
+ (instancetype)sharedBatch{
    @synchronized (self) {
        KJBatchConfiguration * batch = [[KJBatchConfiguration alloc] init];
        batch.maxQueue = 5;
        batch.againCount = 3;
        batch.opportunity = KJBatchReRequestOpportunityNone;
        return batch;
    }
}

@end

@implementation KJBatchResponse

@end
