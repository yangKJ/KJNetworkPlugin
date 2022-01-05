//
//  KJNetworkManager.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/8/29.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkManager.h"
#import "KJNetworkPluginManager.h"
#import "KJNetworkComplete.h"

#if __has_include("KJNetworkCapturePlugin.h")
#import "KJNetworkCapturePlugin.h"
#endif

@implementation KJNetworkManager

/// 取消网络请求，
+ (void)cancelRequestWithTask:(NSURLSessionTask *)task{
    if (task == nil) {
        return;
    }
    [KJBaseNetworking cancelRequestWithURL:task.currentRequest.URL.absoluteString];
}

/// 二次封装插件版网络请求
/// @param request 请求体
/// @param configuration 配置信息
/// @param complete 结果回调
+ (nullable NSURLSessionTask *)HTTPRequest:(__kindof KJNetworkingRequest *)request
                             configuration:(nullable KJNetworkConfiguration *)configuration
                                  complete:(nullable KJNetworkPluginComplete)complete{
    return [self HTTPRequest:request configuration:configuration success:^(KJNetworkComplete * _complete) {
        complete ? complete(KJResponseObjectTypeSuccess, _complete) : nil;
    } failure:^(KJNetworkComplete * _Nonnull _complete) {
        complete ? complete(KJResponseObjectTypeFailure, _complete) : nil;
    }];
}

/// 二次封装插件版网络请求
/// @param request 请求体
/// @param configuration 配置信息
/// @param success 成功回调
/// @param failure 失败回调
+ (nullable NSURLSessionTask *)HTTPRequest:(__kindof KJNetworkingRequest *)request
                             configuration:(nullable KJNetworkConfiguration *)configuration
                                   success:(nullable void(^)(KJNetworkComplete * complete))success
                                   failure:(nullable void(^)(KJNetworkComplete * complete))failure{
    if (configuration == nil) {
        configuration = [KJNetworkConfiguration defaultConfiguration];
    }
    __block KJNetworkComplete * complete = [[KJNetworkComplete alloc] init];
    complete.request = request;
    if (configuration.constructingBody) {
        // 是否为上传资源相关
        KJBaseNetworking * baseNetworking = [KJNetworkManager createBaseNetworkingWithRequest:request];
        return [baseNetworking postMultipartFormDataWithURL:request.URLString
                                                     params:request.secretParams
                                  constructingBodyWithBlock:configuration.constructingBody.constructingBodyWithBlock
                                                   progress:configuration.constructingBody.uploadProgressWithBlock
                                                    success:^(NSURLSessionDataTask * task, id responseObject) {
            complete.task = task;
            complete.responseObject = responseObject;
            kNetworkHandlingSuccess(complete, configuration, success, failure);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            complete.task = task;
            complete.error = error;
            failure ? failure(complete) : nil;
        }];
    } else if (configuration.downloadBody) {
        // 是否为下载文件
        KJBaseNetworking * baseNetworking = [KJNetworkManager createBaseNetworkingWithRequest:request];
        return [baseNetworking downloadWithURL:request.URLString
                                   destination:configuration.downloadBody.destination
                                      progress:configuration.downloadBody.downloadProgressWithBlock
                                       success:^(NSURLSessionDataTask * task, id responseObject) {
            NSString * filePathString = (NSString *)responseObject;
            complete.task = task;
            complete.responseObject = filePathString;
            success ? success(complete) : nil;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            complete.task = task;
            complete.error = error;
            failure ? failure(complete) : nil;
        }];
    } else {
        // 插件版网络请求
        if (configuration.openCapture) [self captureRequest:&request];
        [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _request, id responseObject) {
            complete.responseObject = responseObject;
            [KJNetworkManager setupComplete:&complete request:_request];
            kNetworkHandlingSuccess(complete, configuration, success, failure);
        } failure:^(KJNetworkingRequest * _Nonnull _request, NSError * _Nonnull error) {
            complete.error = error;
            [KJNetworkManager setupComplete:&complete request:_request];
            failure ? failure(complete) : nil;
        }];
        NSUInteger taskIdentifier = [[request valueForKey:@"taskIdentifier"] unsignedIntegerValue];
        complete.task = [KJBaseNetworking appointTaskWithTaskIdentifier:taskIdentifier];
        return complete.task;
    }
}

/// 创建
/// @param request 请求体
+ (KJBaseNetworking *)createBaseNetworkingWithRequest:(__kindof KJNetworkingRequest *)request{
    @synchronized (self) {
        KJBaseNetworking * baseNetworking = [KJBaseNetworking sharedDefault];
        [baseNetworking setRequestSerializer:request.requestSerializer];
        [baseNetworking setResponseSerializer:request.responseSerializer];
        [baseNetworking setTimeoutInterval:request.timeoutInterval];
        for (NSString * key in request.header) {
            [baseNetworking setValue:request.header[key] forHTTPHeaderField:key];
        }
        return baseNetworking;
    }
}

/// 处理成功结果
NS_INLINE void kNetworkHandlingSuccess(KJNetworkComplete * complete,
                                       KJNetworkConfiguration * configuration,
                                       void(^success)(KJNetworkComplete *),
                                       void(^failure)(KJNetworkComplete *)){
    id responseObject = complete.responseObject;
    if (configuration.analysisResponseObject) {
        // manager response serializer 被外部修改为 json 时，这里会直接收到 字典或数组
        if ([responseObject isKindOfClass:NSDictionary.class] || [responseObject isKindOfClass:NSArray.class]) {
            success ? success(complete) : nil;
        } else {
            NSError * error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:responseObject
                                                        options:NSJSONReadingFragmentsAllowed
                                                          error:&error];
            if (error != nil) {
                // 解析失败直接将原数据抛出
                success ? success(complete) : nil;
            } else {
                if ([result isKindOfClass:[NSDictionary class]]) {
                    // 是否处理自己服务器的请求，处理 code
                    NSInteger code = [result[configuration.codeKeyName] integerValue];
                    if (code == configuration.successCode) {
                        complete.responseObject = result;
                        success ? success(complete) : nil;
                    } else {
                        if (kDictionaryContainsKey(result, configuration.errorKeyName)) {
                            error = [NSError errorWithDomain:@"kj.network"
                                                        code:code
                                                    userInfo:@{NSLocalizedDescriptionKey: result[configuration.errorKeyName]}];
                        } else {
                            error = [NSError errorWithDomain:@"kj.network"
                                                        code:code
                                                    userInfo:@{NSLocalizedDescriptionKey: @"code analysis error."}];
                        }
                        complete.error = error;
                        failure ? failure(complete) : nil;
                    }
                } else {
                    complete.responseObject = result;
                    success ? success(complete) : nil;
                }
            }
        }
    } else {
        success ? success(complete) : nil;
    }
}

/// 字典是否包含某个键
NS_INLINE BOOL kDictionaryContainsKey(NSDictionary * dict, NSString * key){
    if (!key) return NO;
    return dict[key] != nil;
}

/// 默认加入抓包插件
/// @param request 请求体
+ (void)captureRequest:(__kindof KJNetworkingRequest **)request{
    __kindof KJNetworkingRequest * tempRequest = * request;
#if __has_include("KJNetworkCapturePlugin.h")
    BOOL have = NO;
    for (id<KJNetworkDelegate> plugin in tempRequest.plugins) {
        if ([plugin isKindOfClass:[KJNetworkCapturePlugin class]]) {
            have = YES;
            break;
        }
    }
    if (have == NO) {
        KJNetworkCapturePlugin * capture = [KJNetworkCapturePlugin sharedInstance];
        capture.openLog = YES;
        NSMutableArray * temp = [NSMutableArray array];
        if (tempRequest.plugins) {
            [temp addObjectsFromArray:tempRequest.plugins];
        }
        // 抓包插件处于最后一个
        [temp addObject:capture];
        tempRequest.plugins = temp.mutableCopy;
    }
#endif
    * request = tempRequest;
}

/// 数据传递
/// 由于 `request` 会在后面发生变化，所以需要再次赋值操作
+ (void)setupComplete:(KJNetworkComplete **)complete request:(KJNetworkingRequest *)request{
    KJNetworkComplete * temp = * complete;
    temp.request = request;
    * complete = temp;
}

@end
