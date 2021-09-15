//
//  KJNetworkCapturePlugin.m
//  KJNetworkPlugin
//
//  Created by yangkejun on 2021/8/31.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkCapturePlugin.h"
#import <MJExtension/MJExtension.h>
#import <CommonCrypto/CommonDigest.h>

#ifdef DEBUG
#define KJCaptureLog(FORMAT, ...) fprintf(stderr,"%s", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#else
#define KJCaptureLog(FORMAT, ...) nil
#endif

@interface KJNetworkCapturePlugin ()

@property (nonatomic, strong) NSURLSessionTask * task;
@property (nonatomic, strong) NSMutableDictionary<NSString *, KJCaptureResponse *> * responseDict;
@property (nonatomic, strong) dispatch_queue_t currentQueue;

@end

@implementation KJNetworkCapturePlugin

+ (instancetype)sharedInstance{
    static KJNetworkCapturePlugin * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
#ifdef DEBUG
        self.openLog = YES;
#else
        self.openLog = NO;
#endif
    }
    return self;
}

/// 网络请求开始时刻请求
/// @param request 请求相关数据
/// @param stopRequest 是否停止网络请求
/// @return 返回网络请求开始时刻插件处理后的数据
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request stopRequest:(BOOL *)stopRequest{
    [super willSendWithRequest:request stopRequest:stopRequest];
    
    self.task = self.response.task;
    if (self.openLog) {
        KJCaptureLog(@">>>>>>>>>>>>>>>>>>>>>🎷🎷🎷 网络抓包 🎷🎷🎷>>>>>>>>>>>>>>>>>>>>>>>>>>  \
                     \n请求方式 = %@\n请求地址 = %@\n请求路径 = %@\n请求链接 = %@\n请求参数 = %@\n请求头 = %@  \
                     \n<<<<<<<<<<<<<<<<<<<<<🎷🎷🎷 网络抓包 🎷🎷🎷<<<<<<<<<<<<<<<<<<<<<<<<<<\n",
                     KJNetworkRequestMethodStringMap[request.method], request.ip, request.path ?: @"空",
                     [KJNetworkCapturePlugin kIntactURLWithRequest:request header:self.task.currentRequest.allHTTPHeaderFields],
                     [KJNetworkCapturePlugin kHTTPParametersToString:request.params],
                     [KJNetworkCapturePlugin kHTTPParametersToString:self.task.currentRequest.allHTTPHeaderFields]);
    }
    
    return self.response;
}

/// 成功接收数据
/// @param request  接收成功数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    [super succeedWithRequest:request againRequest:againRequest];
    
    [self saveSuccessWithRequest:request responseObject:self.response.responseObject];
    
    return self.response;
}

/// 失败处理
/// @param request  失败的网络活动
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    [super failureWithRequest:request againRequest:againRequest];
    
    KJCaptureLog(@">>>>>>>>>>>>>>>>>>>>> 🥁🥁🥁 网络抓包请求结果失败 🥁🥁🥁 >>>>>>>>>>>>>>>>>>>>>>>>>>  \
                 \n错误编码 = %ld\n错误信息 = %@\n错误详情 = %@ \
                 \n<<<<<<<<<<<<<<<<<<<<< 🥁🥁🥁 网络抓包请求结果失败 🥁🥁🥁 <<<<<<<<<<<<<<<<<<<<<<<<<<\n",
                 (long)self.response.error.code, self.response.error.localizedDescription, self.response.error.userInfo);
    
    return self.response;
}

#pragma mark - public method

/// 读取全部日志
/// @param complete 读取回调
+ (void)readAllLogComplete:(void(^)(NSArray<KJCaptureResponse *> * logs))complete{
    // 异步多读单写
    dispatch_sync([KJNetworkCapturePlugin sharedInstance].currentQueue, ^{
        NSArray * temps = [KJNetworkCapturePlugin sharedInstance].responseDict.allValues;
        complete ? complete(temps) : nil;
    });
}

/// 读取指定网络日志
/// @param ip 根路径地址
/// @param path 网络请求路径
/// @param params 请求参数
/// @param complete 读取回调
+ (void)readLogWithIp:(NSString *)ip path:(NSString *)path params:(nullable id)params complete:(void(^)(KJCaptureResponse * response))complete{
    // 异步多读单写
    dispatch_sync([KJNetworkCapturePlugin sharedInstance].currentQueue, ^{
        NSCharacterSet *character = [NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<>+"].invertedSet;
        NSString * tempPath = path;
        if (tempPath && tempPath.length > 0 && ![tempPath hasPrefix:@"/"]) {
            tempPath = [NSString stringWithFormat:@"/%@", tempPath];
        }
        NSString * URLString = [[ip stringByAppendingString:tempPath ? tempPath : @""] stringByAddingPercentEncodingWithAllowedCharacters:character];
        NSString * string = [URLString stringByAppendingFormat:@"?%@", [KJNetworkCapturePlugin kHTTPParametersToString:params]];
        NSString * key = [KJNetworkCapturePlugin SHA512String:string];
        KJCaptureResponse * response = [KJNetworkCapturePlugin sharedInstance].responseDict[key];
        complete ? complete(response) : nil;
    });
}

#pragma mark - private method

/// 存储成功信息
/// @param request 请求体
/// @param responseObject 成功数据
- (void)saveSuccessWithRequest:(__kindof KJNetworkingRequest *)request responseObject:(id)responseObject{
    // 异步栅栏多读单写
    __weak __typeof(&*self) weakSelf = self;
    dispatch_barrier_async(self.currentQueue, ^{
        KJCaptureResponse * capture = [[KJCaptureResponse alloc] init];
        capture.methodString = KJNetworkRequestMethodStringMap[request.method];
        capture.ip = request.ip;
        capture.path = request.path;
        capture.paramsJSONString = [KJNetworkCapturePlugin kHTTPParametersToString:request.params];
        capture.headerJSONString = [KJNetworkCapturePlugin kHTTPParametersToString:weakSelf.task.currentRequest.allHTTPHeaderFields];
        capture.responseJSONString = [responseObject mj_JSONString];
        NSString * __autoreleasing string = [request.URLString stringByAppendingFormat:@"?%@", capture.paramsJSONString];
        NSString * __autoreleasing key = [KJNetworkCapturePlugin SHA512String:string];
        [weakSelf.responseDict setValue:capture forKey:key];
        if (weakSelf.openLog) {
            KJCaptureLog(@"🎷🎷🎷网络抓包请求结果 = %@\n", [KJNetworkCapturePlugin kAnslysisJSON:responseObject]);
        }
    });
}

/// 请求参数转字符串
+ (NSString *)kHTTPParametersToString:(NSDictionary *)parameters{
    if (parameters == nil || parameters.count == 0) return @"空";
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

// SHA512加密
+ (NSString *)SHA512String:(NSString *)string{
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    return [NSString stringWithString:output];
}

/// 解析JSON数据
+ (id)kAnslysisJSON:(id)json{
    if (json == nil || json == (id)kCFNull) return nil;
    id responseObject = nil;
    NSData * jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]] || [json isKindOfClass:[NSArray class]]) {
        responseObject = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    if (jsonData) {
        responseObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (responseObject) {
            responseObject = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        }
    }
    return responseObject;
}

/// 完整的链接地址，可直接在网站打开调用
/// @param request 请求体
/// @param header 请求头
+ (NSString *)kIntactURLWithRequest:(KJNetworkingRequest *)request header:(NSDictionary *)header{
    NSMutableArray *parts = [NSMutableArray array];
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:header];
    /// 排除默认的三个参数
    if (parameters.count <= 2) {
        [parameters removeAllObjects];
    } else {
        [parameters removeObjectForKey:@"User-Agent"];
        [parameters removeObjectForKey:@"Accept-Language"];
    }
    if (request.params) {
        [parameters addEntriesFromDictionary:request.params];
    }
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        key = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        obj = [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *part = [NSString stringWithFormat:@"%@=%@", key, obj];
        [parts addObject:part];
    }];
    if (parts.count == 0) {
        return request.URLString;
    }
    NSString *queryString = [parts componentsJoinedByString:@"&"];
    queryString = queryString ? [NSString stringWithFormat:@"?%@", queryString] : @"";
    return [NSString stringWithFormat:@"%@%@", request.URLString, queryString];
}

#pragma mark - lazy

- (NSMutableDictionary<NSString *,KJCaptureResponse *> *)responseDict{
    if (!_responseDict) {
        _responseDict = [NSMutableDictionary dictionary];
    }
    return _responseDict;
}

- (dispatch_queue_t)currentQueue{
    if (!_currentQueue) {
        _currentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _currentQueue;
}

@end
