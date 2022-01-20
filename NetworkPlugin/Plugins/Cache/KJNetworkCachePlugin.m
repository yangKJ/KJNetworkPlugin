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

/// 开始准备网络请求
/// @param request 请求相关数据
/// @param response 响应数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回缓存数据，successResponse 不为空表示存在缓存数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                  endRequest:(BOOL *)endRequest{
    
    switch (self.cachePolicy) {
        case KJNetworkCachePolicyCacheOnly:{// 只从缓存读数据
            id _response = [self cacheDataWithRequest:request];
            if (_response) {
                [request setValue:@(YES) forKey:@"cacheData"];
                [response setValue:_response forKey:@"prepareResponse"];
            } else {
                NSError *error = [NSError errorWithDomain:@"kj.cache.plugin"
                                                     code:-200
                                                 userInfo:@{NSLocalizedDescriptionKey: @"No local cache"}];
                [response setValue:error forKey:@"error"];
            }
            * endRequest = YES;
        } break;
        case KJNetworkCachePolicyCacheElseNetwork:{// 先从缓存读取，没有再从网络获取
            id _response = [self cacheDataWithRequest:request];
            if (_response) {
                [request setValue:@(YES) forKey:@"cacheData"];
                [response setValue:_response forKey:@"prepareResponse"];
                * endRequest = YES;
            }
        } break;
        case KJNetworkCachePolicyCacheThenNetwork:{// 先从缓存读取，再从网络获取并且缓存，这种情况下，Block将产生两次调用
            id _response = [self cacheDataWithRequest:request];
            if (_response) {
                [request setValue:@(YES) forKey:@"cacheData"];
                [response setValue:_response forKey:@"prepareResponse"];
                [response setValue:@(YES) forKey:@"cacheCastLocalResponse"];
            }
        } break;
        default:break;
    }
    
    return response;
}

/// 成功接收数据
/// @param request  接收成功数据
/// @param response 响应数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                againRequest:(BOOL *)againRequest{
    
    switch (self.cachePolicy) {
        case KJNetworkCachePolicyNetworkOnly:
        case KJNetworkCachePolicyCacheElseNetwork:
        case KJNetworkCachePolicyNetworkElseCache:
        case KJNetworkCachePolicyCacheThenNetwork:
            [self saveCacheResponseObject:response.responseObject request:request];
            break;
        default:break;
    }
    
    return response;
}

/// 失败处理
/// @param request  失败的网络活动
/// @param response 响应数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                againRequest:(BOOL *)againRequest{
    
    if (self.cachePolicy == KJNetworkCachePolicyNetworkElseCache) {
        id _response = [self cacheDataWithRequest:request];
        if (_response == nil) {
            return response;
        }
        [request setValue:@(YES) forKey:@"cacheData"];
        [response setValue:_response forKey:@"failureResponse"];
    }
    
    return response;
}

/// 同步方式读取缓存数据
- (id)cacheDataWithRequest:(KJNetworkingRequest *)request{
    return [self.dataCache objectForKey:kCacheKey(request.URLString, request.params)];
}
/// 存储网络数据
- (void)saveCacheResponseObject:(id)responseObject request:(KJNetworkingRequest *)request{
    if (responseObject == nil) return;
    @synchronized (self.dataCache) {
        [self.dataCache setObject:responseObject
                           forKey:kCacheKey(request.URLString, request.params)
                        withBlock:nil];
    }
}

#pragma mark - public method

/// 读取指定网络缓存
/// @param url 网络链接
/// @param parameters 参数
/// @return 返回网络缓存数据
+ (id)readCacheWithURL:(NSString *)url parameters:(NSDictionary *)parameters{
    if (url == nil) return nil;
    YYCache * __autoreleasing dataCache = [YYCache cacheWithName:kNetworkResponseCache];
    return [dataCache objectForKey:kCacheKey(url, parameters)];
}

/// 存储指定网络缓存数据
/// @param url 网络链接
/// @param parameters 参数
/// @param httpData 网络数据
+ (void)saveCacheWithURL:(NSString *)url
              parameters:(NSDictionary *)parameters
                httpData:(id)httpData{
    if (url == nil || httpData == nil) return;
    YYCache * __autoreleasing dataCache = [YYCache cacheWithName:kNetworkResponseCache];
    [dataCache setObject:httpData forKey:kCacheKey(url, parameters) withBlock:nil];
}

/// 清除全部缓存
+ (void)removeAllCache{
    YYCache * __autoreleasing dataCache = [YYCache cacheWithName:kNetworkResponseCache];
    [dataCache removeAllObjects];
}

/// 清除指定网络缓存
/// @param url 网络链接
/// @param parameters 参数
+ (void)removeCacheWithURL:(NSString *)url parameters:(NSDictionary *)parameters{
    if (url == nil) return;
    YYCache * __autoreleasing dataCache = [YYCache cacheWithName:kNetworkResponseCache];
    [dataCache removeObjectForKey:kCacheKey(url, parameters)];
}

/// 获取网络缓存的总大小
/// @return 缓存大小，单位字节
+ (NSInteger)getCacheSize{
    YYCache * __autoreleasing dataCache = [YYCache cacheWithName:kNetworkResponseCache];
    return [dataCache.diskCache totalCost];
}

#pragma mark - private method

/// 缓存键
/// @param url 网络链接
/// @param parameters 参数
NS_INLINE NSString * kCacheKey(NSString * url, NSDictionary * parameters){
    if (parameters == nil) return kCacheSHA512String(url);
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    return kCacheSHA512String([NSString stringWithFormat:@"%@%@",url,paraString]);
}

/// 加密
NS_INLINE NSString * kCacheSHA512String(NSString * string){
    const char * cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData * data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return [NSString stringWithString:output];
}

#pragma mark - lazy

- (YYCache *)dataCache{
    if (!_dataCache) {
        _dataCache = [YYCache cacheWithName:kNetworkResponseCache];
    }
    return _dataCache;
}

@end
