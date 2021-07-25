//
//  KJNetworkCachePlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkCachePlugin.h"
#import <CommonCrypto/CommonDigest.h>
#import <YYCache/YYCache.h>

static NSString * const _Nonnull kNetworkResponseCache = @"kNetworkResponseCache";

@interface KJNetworkCachePlugin ()

@property (nonatomic,strong) YYCache *dataCache;

@end

@implementation KJNetworkCachePlugin

- (instancetype)init{
    if (self = [super init]) {
        self.nameEncryptType = KJNetworkCacheNameEncryptTypeSHA256;
    }
    return self;
}

/// 开始准备网络请求
/// @param request 请求相关数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回准备插件处理后的数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request endRequest:(BOOL *)endRequest{
    [super prepareWithRequest:request endRequest:endRequest];
    if (self.cachePolicy == KJNetworkCachePolicyCacheOnly ||
        self.cachePolicy == KJNetworkCachePolicyCacheElseNetwork ||
        self.cachePolicy == KJNetworkCachePolicyCacheThenNetwork) {
        id response = [self cacheData];
        if (response) {
            if (self.cachePolicy == KJNetworkCachePolicyCacheElseNetwork) {
                * endRequest = YES;
            }
            [self.response setValue:response forKey:@"prepareResponse"];
        } else {
            NSError *error = [NSError errorWithDomain:@"kj.cache.plugin"
                                                 code:-200
                                             userInfo:@{NSLocalizedDescriptionKey: @"No local cache"}];
            [self.response setValue:error forKey:@"error"];
            if (self.cachePolicy == KJNetworkCachePolicyCacheOnly) {
                * endRequest = YES;
            }
        }
    }
    return self.response;
}

/// 成功接收数据
/// @param request  接收成功数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    [super succeedWithRequest:request againRequest:againRequest];
    if (self.cachePolicy == KJNetworkCachePolicyNetworkOnly ||
        self.cachePolicy == KJNetworkCachePolicyCacheElseNetwork ||
        self.cachePolicy == KJNetworkCachePolicyNetworkElseCache ||
        self.cachePolicy == KJNetworkCachePolicyCacheThenNetwork) {
        [self saveCacheResponseObject:self.response.responseObject];
    }
    return self.response;
}

/// 失败处理
/// @param request  失败的网络活动
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    [super failureWithRequest:request againRequest:againRequest];
    if (self.cachePolicy == KJNetworkCachePolicyNetworkElseCache) {
        id response = [self cacheData];
        if (response == nil) {
            NSError *error = [NSError errorWithDomain:@"kj.cache.plugin"
                                                 code:-200
                                             userInfo:@{NSLocalizedDescriptionKey: @"No local cache"}];
            [self.response setValue:error forKey:@"error"];
        }
        [self.response setValue:response forKey:@"failureResponse"];
    }
    return self.response;
}

#pragma mark - 网络缓存

- (YYCache *)dataCache{
    if (!_dataCache) {
        _dataCache = [YYCache cacheWithName:kNetworkResponseCache];
    }
    return _dataCache;
}
/// 同步方式读取缓存数据
- (id)cacheData{
    NSString *cacheKey = [self cacheKeyWithURL:self.request.URLString parameters:self.request.params];
    return [self.dataCache objectForKey:cacheKey];
}
/// 存储网络数据
- (void)saveCacheResponseObject:(id)responseObject{
    if (responseObject) {
        NSString *cacheKey = [self cacheKeyWithURL:self.request.URLString parameters:self.request.params];
        @synchronized (self.dataCache) {
            [self.dataCache setObject:responseObject forKey:cacheKey withBlock:nil];
        }
    }
}
/// 缓存数据
- (NSString *)cacheKeyWithURL:(NSString *)url parameters:(NSDictionary *)parameters{
    if (parameters == nil) return url;
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    // 将URL与转换好的参数字符串拼接在一起,成为最终存储的KEY值
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",url,paraString];
    return [self kj_cacheNameEncryptWithKey:cacheKey];
}

/// 加密
- (NSString *)kj_cacheNameEncryptWithKey:(NSString *)key{
    if (self.nameEncryptType == KJNetworkCacheNameEncryptTypeMD5) {
        const char *value = [key UTF8String];
        unsigned char buffer[CC_MD5_DIGEST_LENGTH];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CC_MD5(value, (CC_LONG)strlen(value), buffer);
#pragma clang diagnostic pop
        NSMutableString * outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
            [outputString appendFormat:@"%02x",buffer[count]];
        }
        return outputString.mutableCopy;
    } else if (self.nameEncryptType == KJNetworkCacheNameEncryptTypeSHA256) {
        const char * data = [key cStringUsingEncoding:NSASCIIStringEncoding];
        NSData * keyData = [NSData dataWithBytes:data length:strlen(data)];
        uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
        CC_SHA256(keyData.bytes, (CC_LONG)keyData.length, digest);
        NSData * outData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
        NSString * outputString = [outData description];
        outputString = [outputString stringByReplacingOccurrencesOfString:@" " withString:@""];
        outputString = [outputString stringByReplacingOccurrencesOfString:@"<" withString:@""];
        outputString = [outputString stringByReplacingOccurrencesOfString:@">" withString:@""];
        return outputString;
    } else {
        return key;
    }
}

@end
