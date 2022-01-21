//
//  KJBaseNetworking.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJBaseNetworking.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "KJNetworkingConsoleLog.h"

@implementation KJBaseSuperNetworking

+ (void)initialize{
    // @synchronized()的作用是创建一个互斥锁，
    // 保证在同一时间内没有其它线程对self对象进行修改,起到线程的保护作用
    @synchronized (self) {
        // 开始监测网络状态
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        // 打开状态栏菊花
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
}

/// 更新默认基本参数
/// @param value 更新值
/// @param key 更新键
+ (void)updateBaseParametersWithValue:(id)value key:(NSString *)key{
    NSMutableDictionary * __autoreleasing dict = [NSMutableDictionary dictionaryWithDictionary:self.baseParameters];
    [dict setValue:value forKey:key];
    self.baseParameters = dict.mutableCopy;
}

/// 实时获取网络状态
+ (void)getNetworkStatusWithBlock:(void(^)(KJNetworkStatusType status))block{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                block ? block(KJNetworkStatusUnknown) : nil;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                block ? block(KJNetworkStatusNotReachable) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                block ? block(KJNetworkStatusReachablePhone) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                block ? block(KJNetworkStatusReachableWiFi) : nil;
                break;
            default:
                break;
        }
    }];
}

/// 判断是否有网
+ (BOOL)isNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

/// 是否是手机网络
+ (BOOL)isWWANNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

/// 是否是WiFi网络
+ (BOOL)isWiFiNetwork{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

/// 取消所有Http请求
+ (void)cancelRequests{
    @synchronized (self) {
        [self.sessionTaskDatas enumerateObjectsUsingBlock:^(NSURLSessionTask  * task, NSUInteger idx, BOOL * stop) {
            [task cancel];
        }];
        [self.sessionTaskDatas removeAllObjects];
    }
}

/// 取消指定URL的Http请求
+ (void)cancelRequestWithURL:(NSString *)url{
    if (url == nil) return;
    @synchronized (self) {
        [self.sessionTaskDatas enumerateObjectsUsingBlock:^(NSURLSessionTask * task, NSUInteger idx, BOOL * stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:url]) {
                [task cancel];
                [self.sessionTaskDatas removeObject:task];
                *stop = YES;
            }
        }];
    }
}

/// 获取指定task
+ (NSURLSessionTask *)appointTaskWithTaskIdentifier:(NSUInteger)taskIdentifier{
    @synchronized (self) {
        __block NSURLSessionTask * _task = nil;
        [self.sessionTaskDatas enumerateObjectsUsingBlock:^(NSURLSessionTask * task, NSUInteger idx, BOOL * stop) {
            if (task.taskIdentifier == taskIdentifier) {
                _task = task;
                *stop = YES;
            }
        }];
        return _task;
    }
}

/// 是否打开网络加载菊花(默认打开)
+ (void)openNetworkActivityIndicator:(BOOL)open{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}

#pragma mark - lazy

static NSMutableArray *_sessionTaskDatas;
+ (NSMutableArray *)sessionTaskDatas{
    if (!_sessionTaskDatas) {
        _sessionTaskDatas = [NSMutableArray array];
    }
    return _sessionTaskDatas;
}
+ (void)setSessionTaskDatas:(NSMutableArray *)sessionTaskDatas{
    _sessionTaskDatas = sessionTaskDatas;
}

static BOOL _openLog = YES;
+ (BOOL)openLog{
    return _openLog;
}
+ (void)setOpenLog:(BOOL)openLog{
    _openLog = openLog;
}

static NSDictionary *_baseParameters = nil;
+ (NSDictionary *)baseParameters{
    return _baseParameters;
}
+ (void)setBaseParameters:(NSDictionary *)baseParameters{
    _baseParameters = baseParameters;
}

static NSString *_baseURL;
+ (NSString *)baseURL{
    return _baseURL;
}
+ (void)setBaseURL:(NSString *)baseURL{
    _baseURL = baseURL;
}

@end


@interface KJBaseNetworking ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation KJBaseNetworking

+ (instancetype)sharedDefault{
    @synchronized (self) {
        KJBaseNetworking * info = [[KJBaseNetworking alloc] init];
        return info;
    }
}

#pragma mark - lazy

- (AFHTTPSessionManager *)sessionManager{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
    }
    return _sessionManager;
}

#pragma mark - nework

- (NSURLSessionTask *)HTTPWithMethod:(KJNetworkRequestMethod)method
                                 url:(NSString *)url
                          parameters:(NSDictionary *)parameters
                             success:(KJNetworkSuccess)success
                             failure:(KJNetworkFailure)failure{
    if ([KJBaseNetworking openLog]) {
        KJNetworkLog(@">>>>>>>>>>>>>>>>>>>>>🎷🎷🎷 REQUEST 🎷🎷🎷>>>>>>>>>>>>>>>>>>>>>>>>>>  \
                     \n请求方式 = %@\n请求URL = %@\n请求参数 = %@  \
                     \n<<<<<<<<<<<<<<<<<<<<<🎷🎷🎷 REQUEST 🎷🎷🎷<<<<<<<<<<<<<<<<<<<<<<<<<<",
                     KJNetworkRequestMethodStringMap[method], url, [KJBaseNetworking kHTTPParametersToString:parameters]);
    }
    return [self dataTaskWithHTTPMethod:method url:url parameters:parameters
                                success:^(NSURLSessionDataTask * task, id responseObject) {
        if ([KJBaseNetworking openLog]) {
            KJNetworkLog(@"🎷🎷🎷请求结果 = %@", [KJBaseNetworking kHTTPResponseObjectToString:responseObject]);
        }
        [KJBaseNetworking.sessionTaskDatas removeObject:task];
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([KJBaseNetworking openLog]) {
            KJNetworkLog(@"🎷🎷🎷错误内容 = %@", error);
        }
        [KJBaseNetworking.sessionTaskDatas removeObject:task];
        if (failure) {
            failure(task, error);
        }
    }];
}

- (NSURLSessionTask *)dataTaskWithHTTPMethod:(KJNetworkRequestMethod)method
                                         url:(NSString *)url
                                  parameters:(NSDictionary *)parameters
                                     success:(void(^)(NSURLSessionDataTask *, id _Nullable))success
                                     failure:(void(^)(NSURLSessionDataTask *, NSError *))failure{
    NSURLSessionTask * sessionTask = nil;
    if (method == KJNetworkRequestMethodGET) {
        sessionTask = [self.sessionManager GET:url parameters:parameters headers:nil progress:nil success:success failure:failure];
    }else if (method == KJNetworkRequestMethodPOST) {
        sessionTask = [self.sessionManager POST:url parameters:parameters headers:nil progress:nil success:success failure:failure];
    }else if (method == KJNetworkRequestMethodHEAD) {
        sessionTask = [self.sessionManager HEAD:url parameters:parameters headers:nil success:nil failure:failure];
    }else if (method == KJNetworkRequestMethodPUT) {
        sessionTask = [self.sessionManager PUT:url parameters:parameters headers:nil success:nil failure:failure];
    }else if (method == KJNetworkRequestMethodPATCH) {
        sessionTask = [self.sessionManager PATCH:url parameters:parameters headers:nil success:nil failure:failure];
    }else if (method == KJNetworkRequestMethodDELETE) {
        sessionTask = [self.sessionManager DELETE:url parameters:parameters headers:nil success:nil failure:failure];
    }
    if (sessionTask) {
        [KJBaseNetworking.sessionTaskDatas addObject:sessionTask];
    }
    return sessionTask;
}

#pragma mark - upload

/// 上传资源
- (NSURLSessionTask *)postMultipartFormDataWithURL:(NSString *)url
                                            params:(NSDictionary * _Nullable)params
                         constructingBodyWithBlock:(KJNetworkConstructingBody)block
                                          progress:(KJNetworkProgress)progress
                                           success:(KJNetworkSuccess)success
                                           failure:(KJNetworkFailure)failure{
    NSURLSessionTask * sessionTask =
    [self.sessionManager POST:url parameters:params headers:nil
    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        block ? block(formData) : nil;
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [KJBaseNetworking.sessionTaskDatas removeObject:task];
        success ? success(task,responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [KJBaseNetworking.sessionTaskDatas removeObject:task];
        failure ? failure(task, error) : nil;
    }];
    if (sessionTask) {
        [KJBaseNetworking.sessionTaskDatas addObject:sessionTask];
    }
    return sessionTask;
}

#pragma mark - download

- (NSURLSessionTask *)downloadWithURL:(NSString *)url
                          destination:(KJNetworkDestination)destination
                             progress:(KJNetworkProgress)progress
                              success:(KJNetworkSuccess)success
                              failure:(KJNetworkFailure)failure{
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __block NSURLSessionDownloadTask * downloadTask =
    [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * downloadProgress) {
        if ([KJBaseNetworking openLog]) {
            KJNetworkLog(@"🎷🎷🎷下载进度:%.2f%%",100.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:destination completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
        [KJBaseNetworking.sessionTaskDatas removeObject:downloadTask];
        if (failure && error) {
            failure ? failure(nil, error) : nil;
            return;
        }
        success ? success(nil, filePath.absoluteString) : nil;
    }];
    [downloadTask resume];
    if (downloadTask) {
        [KJBaseNetworking.sessionTaskDatas addObject:downloadTask];
    }
    return downloadTask;
}

#pragma mark - private method

/// 拼接完整的url
- (NSString *)printRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters{
    path = [path hasPrefix:@"http"] ? path : [NSString stringWithFormat:@"%@%@", _baseURL, path];
    NSMutableString * pathAndParams = [[NSMutableString alloc] initWithString:path];
    [pathAndParams appendString:@"?"];
    for (NSString * categoryId in [parameters allKeys]) {
        [pathAndParams appendFormat:@"%@=%@&", categoryId, [parameters objectForKey:categoryId]];
    }
    return [pathAndParams substringToIndex:[pathAndParams length] - 1];
}

/// 请求参数转字符串
+ (NSString *)kHTTPParametersToString:(NSDictionary *)parameters{
    if (parameters == nil || parameters.count == 0) return @"空";
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parameters
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:nil];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/// 请求结果转换
+ (NSString *)kHTTPResponseObjectToString:(id)responseObject{
    if (responseObject == nil) return @"";
    NSError * error = nil;
    if ([responseObject isKindOfClass:NSDictionary.class] ||
        [responseObject isKindOfClass:NSArray.class]) {
        
    } else {
        responseObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                         options:NSJSONReadingFragmentsAllowed
                                                           error:&error];
        if (error != nil) {
            return @"";
        }
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        return @"";
    }
}

#pragma mark - 重置AFHTTPSessionManager相关属性

- (void)setRequestSerializer:(KJSerializer)requestSerializer{
    /// 保存已设置数据
    NSTimeInterval timeoutInterval = self.sessionManager.requestSerializer.timeoutInterval;
    NSDictionary *header = self.sessionManager.requestSerializer.HTTPRequestHeaders;
    
    switch (requestSerializer) {
        case KJSerializerHTTP:
            self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        case KJSerializerJSON:
            self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        default:
            break;
    }
    
    /// 重新设置数据
    self.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
    NSMutableDictionary * headInfo = [NSMutableDictionary dictionaryWithDictionary:[KJBaseNetworking baseParameters]];
    [headInfo addEntriesFromDictionary:header];
    for (NSString * key in headInfo) {
        [self.sessionManager.requestSerializer setValue:headInfo[key] forHTTPHeaderField:key];
    }
}

- (void)setResponseSerializer:(KJSerializer)responseSerializer{
    switch (responseSerializer) {
        case KJSerializerHTTP:
            self.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        case KJSerializerJSON:
            self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        default:
            break;
    }
    
    /// 重新设置数据
    self.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                                     @"application/json",
                                                                     @"text/html",
                                                                     @"text/json",
                                                                     @"text/plain",
                                                                     @"text/javascript",
                                                                     @"text/xml",
                                                                     @"image/*",
                                                                     nil];
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval{
    self.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field{
    [self.sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

- (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName{
    NSData * cerData = [NSData dataWithContentsOfFile:cerPath];
    //使用证书验证模式
    AFSecurityPolicy * securitypolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //如果需要验证自建证书(无效证书)，需要设置为YES
    securitypolicy.allowInvalidCertificates = YES;
    //是否需要验证域名，默认为YES
    securitypolicy.validatesDomainName = validatesDomainName;
    securitypolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    [self.sessionManager setSecurityPolicy:securitypolicy];
}

@end
