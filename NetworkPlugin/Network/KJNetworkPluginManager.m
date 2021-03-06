//
//  KJNetworkPluginManager.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkPluginManager.h"
#import "KJNetworkingResponse.h"
#import "KJNetworkingDelegate.h"

#if __has_include("KJNetworkingRequest+KJCertificate.h")
#import "KJNetworkingRequest+KJCertificate.h"
#endif

@implementation KJNetworkPluginManager

/// 插件版网络请求
+ (void)HTTPPluginRequest:(KJNetworkingRequest *)request success:(KJNetworkPluginSuccess)success failure:(KJNetworkPluginFailure)failure{
    // 设置请求时机，切勿更改至`KJNetworkBasePlugin`当中，否则插件会出问题
    [request setValue:@(KJRequestOpportunityPrepare) forKey:@"opportunity"];
    // 响应结果
    __block KJNetworkingResponse * response = [[KJNetworkingResponse alloc] init];
    response.opportunity = KJRequestOpportunityPrepare;
    
    // 成功插件处理
    id (^successPluginHandle)(id, BOOL *) = ^id(id responseObject, BOOL * again){
        [request setValue:@(KJRequestOpportunitySuccess) forKey:@"opportunity"];
        response.opportunity = KJRequestOpportunitySuccess;
        [response setValue:responseObject forKey:@"responseObject"];
        for (id<KJNetworkDelegate> plugin in request.plugins) {
            response = [plugin succeedWithRequest:request response:response againRequest:again];
        }
        return response.successResponse ?: responseObject;
    };
    
    // 失败插件处理
    id (^failurePluginHandle)(NSURLSessionDataTask *, NSError *, BOOL *) =
    ^id(NSURLSessionDataTask * task, NSError * error, BOOL * again){
        [request setValue:@(KJRequestOpportunityFailure) forKey:@"opportunity"];
        response.opportunity = KJRequestOpportunityFailure;
        [response setValue:task  forKey:@"task"];
        [response setValue:error forKey:@"error"];
        for (id<KJNetworkDelegate> plugin in request.plugins) {
            response = [plugin failureWithRequest:request response:response againRequest:again];
        }
        return response.failureResponse ?: nil;
    };
    
    // 最终结果插件处理
    id (^processPluginHandle)(id, NSError **) = ^id(id responseObject, NSError **error){
        [request setValue:@(KJRequestOpportunityProcess) forKey:@"opportunity"];
        response.opportunity = KJRequestOpportunityProcess;
        [response setValue:responseObject forKey:@"tempResponse"];
        for (id<KJNetworkDelegate> plugin in request.plugins) {
            response = [plugin processSuccessResponseWithRequest:request response:response error:error];
        }
        return response.processResponse ?: responseObject;
    };
    
    // 网络请求准备时刻，插件处理
    id prepareResponse = nil;
    BOOL endRequest = NO;
    for (id<KJNetworkDelegate> plugin in request.plugins) {
        response = [plugin prepareWithRequest:request response:response endRequest:&endRequest];
        if (response.prepareResponse) {
            prepareResponse = response.prepareResponse;
        }
    }
    
    // 结束后续网络请求
    if (endRequest) {
        if (prepareResponse) {
            BOOL again = NO;
            NSError * processError = nil;
            id successResponse = successPluginHandle(prepareResponse, &again);
            id processResponse = processPluginHandle(successResponse, &processError);
            if (processError == nil) {
                success ? success(request, processResponse) : nil;
            } else {
                failure ? failure(request, response.error) : nil;
            }
        } else {
            failure ? failure(request, response.error) : nil;
        }
        return;
    } else if (prepareResponse) {
        // 缓存插件，STNetworkCachePolicyCacheThenNetwork 抛出本地数据
        if ([[response valueForKey:@"cacheCastLocalResponse"] boolValue]) {
            NSError * processError = nil;
            id processResponse = processPluginHandle(prepareResponse, &processError);
            if (processError == nil) {
                success ? success(request, processResponse) : nil;
            } else {
                failure ? failure(request, response.error) : nil;
            }
            [request  setValue:@(NO) forKey:@"cacheData"];
            [response setValue:@(NO) forKey:@"cacheCastLocalResponse"];
        }
    }
    
    // 网络请求基类
    KJBaseNetworking * baseNetworking = [self createBaseNetworkingWithRequest:request];
    
    // 网络请求
    NSURLSessionTask * sessionTask =
    [baseNetworking HTTPWithMethod:request.method url:request.URLString parameters:request.secretParams
                           success:^(NSURLSessionDataTask * task, id responseObject) {
        BOOL again = NO;
        id successResponse = successPluginHandle(responseObject, &again);
        if (again) {// 再次重复网络请求
            @synchronized (KJBaseNetworking.sessionTaskDatas) {
                [KJBaseNetworking.sessionTaskDatas removeObject:task];
            }
            [KJNetworkPluginManager HTTPPluginRequest:request success:success failure:failure];
            return;
        }
        NSError * processError = nil;
        id processResponse = processPluginHandle(successResponse, &processError);
        if (processError == nil) {
            success ? success(request, processResponse) : nil;
        } else {
            failure ? failure(request, response.error) : nil;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        BOOL again = NO;
        id failureResponse = failurePluginHandle(task, error, &again);
        if (again) {// 再次重复网络请求
            @synchronized (KJBaseNetworking.sessionTaskDatas) {
                [KJBaseNetworking.sessionTaskDatas removeObject:task];
            }
            [KJNetworkPluginManager HTTPPluginRequest:request success:success failure:failure];
            return;
        }
        if (failureResponse) {
            NSError * processError = nil;
            id processResponse = processPluginHandle(failureResponse, &processError);
            if (processError == nil) {
                success ? success(request, processResponse) : nil;
            } else {
                failure ? failure(request, response.error) : nil;
            }
        } else {
            failure ? failure(request, error) : nil;
        }
    }];
    
    // 网络请求开始时刻，插件处理
    BOOL stopRequest = NO;
    [request setValue:@(KJRequestOpportunityWillSend) forKey:@"opportunity"];
    response.opportunity = KJRequestOpportunityWillSend;
    [request setValue:@(sessionTask.taskIdentifier) forKey:@"taskIdentifier"];
    [response setValue:sessionTask forKey:@"task"];
    for (id<KJNetworkDelegate> plugin in request.plugins) {
        response = [plugin willSendWithRequest:request response:response stopRequest:&stopRequest];
    }
    if (stopRequest) {
        [sessionTask cancel];
        @synchronized (KJBaseNetworking.sessionTaskDatas) {
            [KJBaseNetworking.sessionTaskDatas removeObject:sessionTask];
        }
    }
}

+ (KJBaseNetworking *)createBaseNetworkingWithRequest:(__kindof KJNetworkingRequest *)request{
    @synchronized (self) {
        KJBaseNetworking * baseNetworking = [KJBaseNetworking sharedDefault];
        [baseNetworking setRequestSerializer:request.requestSerializer];
        [baseNetworking setResponseSerializer:request.responseSerializer];
        [baseNetworking setTimeoutInterval:request.timeoutInterval];
        for (NSString * key in request.header) {
            [baseNetworking setValue:request.header[key] forHTTPHeaderField:key];
        }
        if ([[request valueForKey:@"useSemaphore"] boolValue]) {
            // 解决信号量卡顿主线程问题，开启一条子线程
            baseNetworking.sessionManager.completionQueue =
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        }
        #if __has_include("KJNetworkingRequest+KJCertificate.h")
        if (request.certificatePath && request.certificatePath.length) {
            [baseNetworking setSecurityPolicyWithCerPath:request.certificatePath
                                     validatesDomainName:request.validatesDomainName];
        }
        #endif
        return baseNetworking;
    }
}

@end
