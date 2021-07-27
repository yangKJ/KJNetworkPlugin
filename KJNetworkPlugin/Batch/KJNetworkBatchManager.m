//
//  KJNetworkBatchManager.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/26.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkBatchManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "KJNetworkingRequest.h"
#import "KJNetworkPluginManager.h"

@interface KJNetworkingRequest (BatchAgainCount)

/// 重连次数
@property (nonatomic, assign) NSInteger againRequestCount;

@end

@implementation KJNetworkingRequest (BatchAgainCount)

- (NSInteger)againRequestCount{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setAgainRequestCount:(NSInteger)againRequestCount{
    objc_setAssociatedObject(self, @selector(againRequestCount), @(againRequestCount), OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface KJNetworkBatchManager ()

// 配置文件
@property (nonatomic, strong) KJBatchConfiguration * configuration;
// 请求体
@property (nonatomic, strong) NSArray<__kindof KJNetworkingRequest *> * requestArray;
// 数据存储器
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> * resultDictionary;
// 正在请求中的网络
@property (nonatomic, strong) NSMutableSet<__kindof KJNetworkingRequest *> * requestingSet;
// 未请求的网络
@property (nonatomic, strong) NSMutableSet<__kindof KJNetworkingRequest *> * unRequestSet;
// 失败的网络请求
@property (nonatomic, strong) NSMutableSet<__kindof KJNetworkingRequest *> * failRequsetSet;

@end

@implementation KJNetworkBatchManager

/// 批量网络请求
+ (void)HTTPBatchRequestConfiguration:(KJBatchConfiguration *)configuration
                            reconnect:(KJNetworkBatchReconnect)reconnect
                             complete:(KJNetworkBatchComplete)complete{
    @synchronized (self) {
        KJNetworkBatchManager * manager = [[KJNetworkBatchManager alloc] init];
        manager.configuration = configuration;
        [manager createHTTPBatchConfiguration:configuration reconnect:reconnect complete:complete];
    }
}

- (void)createHTTPBatchConfiguration:(KJBatchConfiguration *)configuration
                           reconnect:(KJNetworkBatchReconnect)reconnect
                            complete:(KJNetworkBatchComplete)complete{
    NSInteger index = 520;
    for (KJNetworkingRequest * request in configuration.requestArray) {
        [request setValue:[NSString stringWithFormat:@"%ld", index] forKey:@"requestIdentifier"];
        index ++;
    }
    self.requestArray = configuration.requestArray;
    [self.unRequestSet addObjectsFromArray:configuration.requestArray];
    dispatch_group_t group = dispatch_group_create();
    for (KJNetworkingRequest * request in configuration.requestArray) {
        if (self.requestingSet.count <= configuration.maxQueue) {
            [self kj_recursionHTTPBatchRequest:request group:group reconnect:reconnect];
        } else {
            break;
        }
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        complete ? complete([self sortResponseArray]) : nil;
    });
}

- (void)kj_recursionHTTPBatchRequest:(__kindof KJNetworkingRequest *)request
                               group:(dispatch_group_t)group
                           reconnect:(KJNetworkBatchReconnect)reconnect{
    @synchronized (self.requestingSet) {
        [self.requestingSet addObject:request];
    }
    dispatch_group_enter(group);
    __weak __typeof(&*self) weakself = self;
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull __request, id  _Nonnull responseObject) {
        dispatch_group_leave(group);
        @synchronized (weakself.resultDictionary) {
            [weakself.resultDictionary setValue:responseObject forKey:__request.requestIdentifier];
        }
        KJNetworkingRequest * currentRequest = [weakself currentRequestWithRequestIdentifier:__request.requestIdentifier];
        if ([weakself dealCompleteRequset:&currentRequest requestSuccess:YES reconnect:reconnect]) {
            [weakself kj_recursionHTTPBatchRequest:currentRequest group:group reconnect:reconnect];
        }
    } failure:^(KJNetworkingRequest * _Nonnull __request, NSError * _Nonnull error) {
        dispatch_group_leave(group);
        @synchronized (weakself.resultDictionary) {
            [weakself.resultDictionary setValue:error forKey:__request.requestIdentifier];
        }
        KJNetworkingRequest * currentRequest = [weakself currentRequestWithRequestIdentifier:__request.requestIdentifier];
        if ([weakself dealCompleteRequset:&currentRequest requestSuccess:NO reconnect:reconnect]) {
            [weakself kj_recursionHTTPBatchRequest:currentRequest group:group reconnect:reconnect];
        }
    }];
}

/// 处理完成相关逻辑
/// @param request 请求头
/// @param requestSuccess 是否为网络请求成功
/// @param reconnect 重连回调
/// @return 返回是否递归调用
- (BOOL)dealCompleteRequset:(__kindof KJNetworkingRequest * _Nonnull __strong * _Nonnull)request
             requestSuccess:(BOOL)requestSuccess
                  reconnect:(KJNetworkBatchReconnect)reconnect{
    KJNetworkingRequest * currentRequest = * request;
    @synchronized (self.requestingSet) {
        [self.requestingSet removeObject:currentRequest];
    }
    @synchronized (self.failRequsetSet) {
        if (requestSuccess) {
            [self.failRequsetSet removeObject:currentRequest];
        } else if (currentRequest.againRequestCount < self.configuration.againCount) {
            if (self.configuration.opportunity == KJBatchReRequestOpportunityNone) {
                currentRequest.againRequestCount += self.configuration.againCount;
            } else {
                currentRequest.againRequestCount += 1;
            }
            [self.failRequsetSet addObject:currentRequest];
            if (self.configuration.opportunity == KJBatchReRequestOpportunityPromptly) {
                return YES;
            }
        }
    }
    @synchronized (self.unRequestSet) {
        // 判断是否还存在未请求网络
        [self.unRequestSet removeObject:currentRequest];
        if (self.unRequestSet.count) {
            * request = [self.unRequestSet anyObject];
            return YES;
        }
        // 重新请求逻辑处理，再次请求网络
        @synchronized (self.failRequsetSet) {
            NSArray * array = [self.failRequsetSet allObjects];
            if (array.count && reconnect && reconnect(array)) {
                [self.unRequestSet addObjectsFromArray:array];
                * request = [self.unRequestSet anyObject];
                [self.failRequsetSet removeAllObjects];
                return YES;
            }
        }
    }
    return NO;
}

/// 根据请求体标识符获取请求体
- (__kindof KJNetworkingRequest * _Nonnull)currentRequestWithRequestIdentifier:(NSString *)requestIdentifier{
    __block NSInteger index = 0;
    [self.requestArray enumerateObjectsUsingBlock:^(__kindof KJNetworkingRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([requestIdentifier isEqualToString:obj.requestIdentifier]) {
            index = idx;
            * stop = YES;
        }
    }];
    return self.requestArray[index];
}

/// 排序数组
- (NSArray *)sortResponseArray{
    @autoreleasepool {
        NSMutableArray * temp = [NSMutableArray array];
        NSArray * keys = [[self.resultDictionary allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for (NSString * key in keys) {
            KJBatchResponse * response = [[KJBatchResponse alloc] init];
            id value = self.resultDictionary[key];
            if ([value isKindOfClass:[NSError class]]) {
                response.error = value;
            } else {
                response.responseObject = value;
            }
            [temp addObject:response];
        }
        return temp.mutableCopy;
    }
}

#pragma mark - lazy

- (NSMutableDictionary<NSString *, id> *)resultDictionary{
    if (!_resultDictionary) {
        _resultDictionary = [NSMutableDictionary dictionary];
    }
    return _resultDictionary;
}

- (NSMutableSet<__kindof KJNetworkingRequest *> *)requestingSet{
    if (!_requestingSet) {
        _requestingSet = [NSMutableSet set];
    }
    return _requestingSet;
}

- (NSMutableSet<__kindof KJNetworkingRequest *> *)unRequestSet{
    if (!_unRequestSet) {
        _unRequestSet = [NSMutableSet set];
    }
    return _unRequestSet;
}

- (NSMutableSet<__kindof KJNetworkingRequest *> *)failRequsetSet{
    if (!_failRequsetSet) {
        _failRequsetSet = [NSMutableSet set];
    }
    return _failRequsetSet;
}

@end
