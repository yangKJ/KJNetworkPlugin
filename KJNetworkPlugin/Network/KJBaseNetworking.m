//
//  KJBaseNetworking.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//

#import "KJBaseNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

#ifdef DEBUG
#define KJAppLog(s, ... ) NSLog( @"[%@ in line %d] ===============>\n%@", \
[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  \
[NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define KJAppLog(s, ... )
#endif

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

#pragma mark - 网络请求处理

- (void)GETHTTPRequsetWithURL:(NSString *)url
                   parameters:(NSDictionary *)parameters
                      success:(KJNetworkSuccess)success
                      failure:(KJNetworkFailure)failure{
    [self HTTPWithMethod:KJNetworkRequestMethodGET url:url parameters:parameters success:success failure:failure];
}

- (void)POSTHTTPRequsetWithURL:(NSString *)url
                    parameters:(NSDictionary *)parameters
                       success:(KJNetworkSuccess)success
                       failure:(KJNetworkFailure)failure{
    [self HTTPWithMethod:KJNetworkRequestMethodPOST url:url parameters:parameters success:success failure:failure];
}

- (NSURLSessionTask *)HTTPWithMethod:(KJNetworkRequestMethod)method
                                 url:(NSString *)url
                          parameters:(NSDictionary *)parameters
                             success:(KJNetworkSuccess)success
                             failure:(KJNetworkFailure)failure{
    if ([KJBaseNetworking openLog]) {
        KJAppLog(@">>>>>>>>>>>>>>>>>>>>>🎷🎷🎷 REQUEST 🎷🎷🎷>>>>>>>>>>>>>>>>>>>>>>>>>>  \
                 \n请求方式 = %@\n请求URL = %@\n请求参数 = %@  \
                 \n<<<<<<<<<<<<<<<<<<<<<🎷🎷🎷 REQUEST 🎷🎷🎷<<<<<<<<<<<<<<<<<<<<<<<<<<",
                 [self kj_methodString:method], url, kHTTPParametersToString(parameters));
    }
    return [self dataTaskWithHTTPMethod:method url:url parameters:parameters success:^(NSURLSessionDataTask * task, id responseObject) {
        if ([KJBaseNetworking openLog]) {
            KJAppLog(@"🎷🎷🎷请求结果 = %@", kHTTPResponseObjectToString(responseObject));
        }
        [KJBaseNetworking.sessionTaskDatas removeObject:task];
        if (success) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([KJBaseNetworking openLog]) {
            KJAppLog(@"🎷🎷🎷错误内容 = %@", error);
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
                       success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                       failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    NSURLSessionTask * sessionTask = nil;
    if (method == KJNetworkRequestMethodGET){
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

#pragma mark - 上传下载

/// 上传资源
- (void)postMultipartFormDataWithURL:(NSString *)url
                              params:(NSDictionary * _Nullable)params
           constructingBodyWithBlock:(void(^_Nullable)(id<AFMultipartFormData> formData))block
                            progress:(KJNetworkProgress)progress
                             success:(KJNetworkSuccess)success
                             failure:(KJNetworkFailure)failure{
    NSURLSessionTask * sessionTask =
    [self.sessionManager POST:url parameters:params headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
}

#pragma mark - 上传文件
- (void)uploadFileWithURL:(NSString *)url
               parameters:(NSDictionary *)parameters
                     name:(NSString *)name
                 filePath:(NSString *)filePath
                 progress:(KJNetworkProgress)progress
                  success:(KJNetworkSuccess)success
                  failure:(KJNetworkFailure)failure{
    NSURLSessionTask * sessionTask =
    [self.sessionManager POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError * error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        [KJBaseNetworking.sessionTaskDatas removeObject:task];
        success ? success(task,responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [KJBaseNetworking.sessionTaskDatas removeObject:task];
        failure ? failure(task, error) : nil;
    }];
    if (sessionTask) {
        [KJBaseNetworking.sessionTaskDatas addObject:sessionTask];
    }
}

#pragma mark - 上传图片文件
- (void)uploadImageURL:(NSString *)url
            parameters:(NSDictionary *)parameters
                images:(NSArray<UIImage *> *)images
                  name:(NSString *)name
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
              progress:(KJNetworkProgress)progress
               success:(KJNetworkSuccess)success
               failure:(KJNetworkFailure)failure{
    NSURLSessionTask * sessionTask =
    [self.sessionManager POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //压缩-添加-上传图片
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData * imageData = UIImageJPEGRepresentation(image, 0.5);
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:[NSString stringWithFormat:@"%@%lu.%@",fileName, (unsigned long)idx, mimeType ?: @"jpeg"]
                                    mimeType:[NSString stringWithFormat:@"image/%@",mimeType ?: @"jpeg"]];
        }];
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
}

#pragma mark - 下载文件
- (void)downloadWithURL:(NSString *)url
                fileDir:(NSString *)fileDir
               progress:(KJNetworkProgress)progress
                success:(KJNetworkSuccess)success
                failure:(KJNetworkFailure)failure{
    if (fileDir.length == 0) {
        if ([KJBaseNetworking openLog]) {
            KJAppLog(@"🎷🎷🎷下载路径为空，使用默认目录");
        }
        NSString * documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        fileDir = [documents stringByAppendingPathComponent:@"KJDownloader"];
    }
    
    NSString *fileName = url.lastPathComponent;
    NSString *savePath = [fileDir stringByAppendingPathComponent:fileName];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:savePath]) {//文件已下载，直接返回
        if ([KJBaseNetworking openLog]) {
            KJAppLog(@"🎷🎷🎷文件已下载，直接返回");
        }
        success ? success(nil,savePath) : nil;
        return;
    }
    
    NSError * createError = nil;
    if (![fileManager fileExistsAtPath:fileDir]) {//文件夹不存在，创建目录
        if ([KJBaseNetworking openLog]) {
            KJAppLog(@"🎷🎷🎷文件夹不存在，创建目录");
        }
        [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:&createError];
    }
    if (createError) {
        failure ? failure(nil, createError) : nil;
        return;
    }
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __block NSURLSessionDownloadTask * downloadTask =
    [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * downloadProgress) {
        if ([KJBaseNetworking openLog]) {
            KJAppLog(@"🎷🎷🎷下载进度:%.2f%%",100.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    } destination:^NSURL * (NSURL * targetPath, NSURLResponse * response) {
        return [NSURL fileURLWithPath:savePath]; // 返回的是文件存放在本地沙盒的地址NSURL对象
    } completionHandler:^(NSURLResponse * response, NSURL * filePath, NSError * error) {
        [KJBaseNetworking.sessionTaskDatas removeObject:downloadTask];
        if (failure && error) {
            failure ? failure(nil, error) : nil;
            return;
        }
        success ? success(nil,filePath.absoluteString) : nil;
    }];
    [downloadTask resume]; // 启动下载任务
    if (downloadTask) {
        [KJBaseNetworking.sessionTaskDatas addObject:downloadTask];
    }
}

- (NSURLSessionTask *)downloadWithURL:(NSString *)url
                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                             progress:(KJNetworkProgress)progress
                              success:(KJNetworkSuccess)success
                              failure:(KJNetworkFailure)failure{
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    __block NSURLSessionDownloadTask * downloadTask =
    [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * downloadProgress) {
        if ([KJBaseNetworking openLog]) {
            KJAppLog(@"🎷🎷🎷下载进度:%.2f%%", 100.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
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
        success ? success(nil,filePath.absoluteString) : nil;
    }];
    [downloadTask resume];
    if (downloadTask) {
        [KJBaseNetworking.sessionTaskDatas addObject:downloadTask];
    }
    return downloadTask;
}

#pragma mark - private method

- (NSString *)kj_methodString:(KJNetworkRequestMethod)method{
    switch (method) {
        case KJNetworkRequestMethodGET:return @"GET";
        case KJNetworkRequestMethodPOST:return @"POST";
        case KJNetworkRequestMethodHEAD:return @"HEAD";
        case KJNetworkRequestMethodPUT:return @"PUT";
        case KJNetworkRequestMethodPATCH:return @"PATCH";
        case KJNetworkRequestMethodDELETE:return @"DELETE";
        default:break;
    }
}

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
NS_INLINE NSString * kHTTPParametersToString(NSDictionary * parameters){
    if (parameters == nil || parameters.count == 0) return @"空";
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/// 请求结果转换
NS_INLINE id kHTTPResponseObjectToString(id responseObject){
    if (responseObject == nil) return @"";
    NSError * error = nil;
    if ([responseObject isKindOfClass:NSDictionary.class] || [responseObject isKindOfClass:NSArray.class]) {
        
    } else {
        responseObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingFragmentsAllowed error:&error];
        if (error != nil) {
            return @"";
        }
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        return @"";
    }
}

#pragma mark - 重置AFHTTPSessionManager相关属性

- (void)setRequestSerializer:(KJRequestSerializer)requestSerializer{
    self.sessionManager.requestSerializer = requestSerializer == KJRequestSerializerHTTP ?
    [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

- (void)setResponseSerializer:(KJResponseSerializer)responseSerializer{
    self.sessionManager.responseSerializer = responseSerializer == KJResponseSerializerHTTP ?
    [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
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

#pragma mark - lazy

- (AFHTTPSessionManager *)sessionManager{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        // 编码
        _sessionManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        // 设置请求超时时间
        _sessionManager.requestSerializer.timeoutInterval = 30.f;
        // 设置允许同时最大并发数量，过大容易出问题
        _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
        // 设置请求参数接收类型
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        // 设置服务器返回结果的类型:JSON(AFJSONResponseSerializer,AFHTTPResponseSerializer)
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                                     @"application/json",
                                                                     @"text/html",
                                                                     @"text/json",
                                                                     @"text/plain",
                                                                     @"text/javascript",
                                                                     @"text/xml",
                                                                     @"image/*",
                                                                     nil];
        // 配置默认参数
        NSDictionary * headInfo = [KJBaseNetworking baseParameters];
        for (NSString * key in headInfo) {
            [_sessionManager.requestSerializer setValue:headInfo[key] forHTTPHeaderField:key];
        }
    }
    return _sessionManager;
}

@end

#pragma mark - 控制台中文打印

#if defined(DEBUG) && DEBUG // 调试模式打印
@implementation NSArray (KJChinaLog)

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level{
    NSMutableString *desc = [NSMutableString string];
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"\t"];
    }
    
    NSString *tab = (level > 0) ? tabString : @"";
    
    [desc appendString:@"(\n"];
    
    for (int i = 0; i < self.count; i++) {
        id obj = self[i];
        if ([obj isKindOfClass:[NSDictionary class]] ||
            [obj isKindOfClass:[NSArray class]] ||
            [obj isKindOfClass:[NSSet class]]) {
            NSString *str = [((NSDictionary *)obj) descriptionWithLocale:locale indent:level + 1];
            (i == (self.count - 1)) ? [desc appendFormat:@"%@\t%@\n", tab, str] : [desc appendFormat:@"%@\t%@,\n", tab, str];
        }else if ([obj isKindOfClass:[NSString class]]) {
            (i == (self.count - 1)) ? [desc appendFormat:@"%@\t\"%@\"\n", tab, obj] : [desc appendFormat:@"%@\t\"%@\",\n", tab, obj];
        }else if ([obj isKindOfClass:[NSData class]]) {
            // 如果是NSData类型，尝试去解析结果，以打印出可阅读的数据
            NSError *error = nil;
            NSObject *result = [NSJSONSerialization JSONObjectWithData:obj
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
            // 解析成功
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]] ||
                    [result isKindOfClass:[NSArray class]] ||
                    [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) descriptionWithLocale:locale indent:level + 1];
                    (i == (self.count - 1)) ? [desc appendFormat:@"%@\t%@\n", tab, str] : [desc appendFormat:@"%@\t%@,\n", tab, str];
                }else if ([obj isKindOfClass:[NSString class]]) {
                    (i == (self.count - 1)) ? [desc appendFormat:@"%@\t\"%@\"\n", tab, result] : [desc appendFormat:@"%@\t\"%@\",\n", tab, result];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        (i == (self.count - 1)) ? [desc appendFormat:@"%@\t\"%@\"\n", tab, str] : [desc appendFormat:@"%@\t\"%@\",\n", tab, str];
                    } else {
                        (i == (self.count - 1)) ? [desc appendFormat:@"%@\t%@\n", tab, obj] : [desc appendFormat:@"%@\t%@,\n", tab, obj];
                    }
                } @catch (NSException *exception) {
                    (i == (self.count - 1)) ? [desc appendFormat:@"%@\t%@\n", tab, obj] : [desc appendFormat:@"%@\t%@,\n", tab, obj];
                }
            }
        } else {
            (i == (self.count - 1)) ? [desc appendFormat:@"%@\t%@\n", tab, obj] : [desc appendFormat:@"%@\t%@,\n", tab, obj];
        }
    }
    
    [desc appendFormat:@"%@)", tab];
    
    return desc;
}


@end

@implementation NSDictionary (KJChinaLog)
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level{
    NSMutableString *desc = [NSMutableString string];
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"\t"];
    }
    
    NSString *tab = (level > 0) ? tabString : @"";
    
    [desc appendString:@"{\n"];
    
    NSArray *allKeys = [self allKeys];
    for (int i = 0; i < allKeys.count; i++) {
        id key = allKeys[i];
        id obj = [self objectForKey:key];
        if ([obj isKindOfClass:[NSString class]]) {
            (i == (allKeys.count-1)) ? [desc appendFormat:@"%@\t%@ = \"%@\"\n", tab, key, obj] : [desc appendFormat:@"%@\t%@ = \"%@\",\n", tab, key, obj];
        }else if ([obj isKindOfClass:[NSArray class]] ||
                 [obj isKindOfClass:[NSDictionary class]] ||
                 [obj isKindOfClass:[NSSet class]]) {
            (i == (allKeys.count-1)) ?
            [desc appendFormat:@"%@\t%@ = %@\n", tab, key, [obj descriptionWithLocale:locale indent:level + 1]] :
            [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, [obj descriptionWithLocale:locale indent:level + 1]];
        }else if ([obj isKindOfClass:[NSData class]]) {
            // 如果是NSData类型，尝试去解析结果，以打印出可阅读的数据
            NSError *error = nil;
            NSObject *result = [NSJSONSerialization JSONObjectWithData:obj
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
            // 解析成功
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]]
                    || [result isKindOfClass:[NSArray class]]
                    || [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) descriptionWithLocale:locale indent:level + 1];
                    (i == (allKeys.count-1)) ? [desc appendFormat:@"%@\t%@ = %@\n", tab, key, str] : [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, str];
                }else if ([obj isKindOfClass:[NSString class]]) {
                    (i == (allKeys.count-1)) ? [desc appendFormat:@"%@\t%@ = \"%@\"\n", tab, key, result] : [desc appendFormat:@"%@\t%@ = \"%@\",\n", tab, key, result];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        (i == (allKeys.count-1)) ? [desc appendFormat:@"%@\t%@ = \"%@\"\n", tab, key, str] : [desc appendFormat:@"%@\t%@ = \"%@\",\n", tab, key, str];
                    } else {
                        (i == (allKeys.count-1)) ? [desc appendFormat:@"%@\t%@ = %@\n", tab, key, obj] : [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, obj];
                    }
                } @catch (NSException *exception) {
                    (i == (allKeys.count-1)) ? [desc appendFormat:@"%@\t%@ = %@\n", tab, key, obj] : [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, obj];
                }
            }
        } else {
            (i == (allKeys.count-1)) ? [desc appendFormat:@"%@\t%@ = %@\n", tab, key, obj] : [desc appendFormat:@"%@\t%@ = %@,\n", tab, key, obj];
        }
    }
    
    [desc appendFormat:@"%@}", tab];
    
    return desc;
}

@end

#endif
