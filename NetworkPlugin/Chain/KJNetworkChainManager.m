//
//  KJNetworkChainManager.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/26.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkChainManager.h"
#import "KJNetworkPluginManager.h"

@interface KJNetworkChainManager ()

@property (nonatomic, copy, readwrite, nullable) KJNetworkChainFailure failure;
@property (nonatomic, strong, nullable) KJNetworkingRequest *request;
@property (nonatomic, strong) id lastResponseObject;

@end

@implementation KJNetworkChainManager

#pragma mark - 第一种链式网络请求
/// 链式网络请求
+ (void)HTTPChainRequest:(__kindof KJNetworkingRequest *)request
                 success:(KJNetworkChainSuccess)success
                 failure:(KJNetworkChainFailure)failure
                   chain:(KJNetworkNextChainRequest)chain,...{
    // 获取
    __block NSMutableArray * chainTemps = [NSMutableArray arrayWithObject:chain];
    va_list args;
    KJNetworkingRequest * (^block)(id);
    va_start(args, chain);
    while ((block = va_arg(args, KJNetworkingRequest * (^)(id)))) {
        [chainTemps addObject:block];
    }
    va_end(args);
    
    // 初次网络请求
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * request, id responseObject) {
        NSMutableArray * successTemps = [NSMutableArray arrayWithObject:responseObject];
        [KJNetworkChainManager kj_recursionHTTPChainTemps:chainTemps successTemps:successTemps success:success failure:failure];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        failure ? failure(error) : nil;
    }];
    
}

/// 递归获取网络请求
/// @param chainTemps 存储链式数组
/// @param successTemps 成功数据存储数组
/// @param success 成功回调
/// @param failure 失败回调
+ (void)kj_recursionHTTPChainTemps:(NSMutableArray *)chainTemps
                      successTemps:(NSMutableArray *)successTemps
                           success:(KJNetworkChainSuccess)success
                           failure:(KJNetworkChainFailure)failure{
    KJNetworkingRequest * request = nil;
    if (chainTemps.count) {
        KJNetworkingRequest * (^tempChain)(id) = chainTemps.firstObject;
        id response = successTemps.lastObject;
        request = tempChain(response);
        [chainTemps removeObjectAtIndex:0];
    }
    if (request) {
        [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * request, id responseObject) {
            [successTemps addObject:responseObject];
            [KJNetworkChainManager kj_recursionHTTPChainTemps:chainTemps successTemps:successTemps success:success failure:failure];
        } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
            failure ? failure(error) : nil;
        }];
    } else {
        success ? success(successTemps.mutableCopy) : nil;
    }
}

#pragma mark - 第二种链式网络请求

/// 链式网络请求
/// @param request 请求体系
/// @param failure 失败回调，只要一个失败就会响应
+ (instancetype)HTTPChainRequest:(__kindof KJNetworkingRequest *)request failure:(KJNetworkChainFailure)failure{
    @synchronized (self) {
        __block KJNetworkChainManager * manager = [[KJNetworkChainManager alloc] init];
        manager.failure = failure;
        manager.lastResponseObject = [manager syncResponseWithRequest:request];
        return manager;
    }
}

- (KJNetworkChainManager * (^)(KJNetworkNextChainRequest))chain {
    return ^(KJNetworkNextChainRequest tempChain){
        if (tempChain) {
            self.request = tempChain(self.lastResponseObject);
            self.lastResponseObject = [self syncResponseWithRequest:self.request];
        }
        return self;
    };
}

- (void(^)(void(^)(id responseObject)))lastChain {
    return ^(void(^tempChain)(id responseObject)){
        if (tempChain) {
            tempChain(self.lastResponseObject);
        }
    };
}

/// 信号量同步获取请求结果
- (id)syncResponseWithRequest:(__kindof KJNetworkingRequest *)request{
    [request setValue:@(YES) forKey:@"useSemaphore"];
    __weak __typeof(&*self) weakself = self;
    __block id response = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * request, id responseObject) {
        response = responseObject;
        dispatch_semaphore_signal(semaphore);
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        weakself.failure ? weakself.failure(error) : nil;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return response;
}

@end
