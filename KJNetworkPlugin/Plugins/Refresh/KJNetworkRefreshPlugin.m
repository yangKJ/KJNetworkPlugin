//
//  KJNetworkRefreshPlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/9/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkRefreshPlugin.h"
#import <CommonCrypto/CommonDigest.h>

@interface KJNetworkRefreshPlugin ()

/// 存储网络请求对应PAGE
@property (nonatomic, strong, class) NSMutableDictionary *pageDictionary;

@end

@implementation KJNetworkRefreshPlugin

- (instancetype)init{
    if (self = [super init]) {
        self.refreshMethod = KJNetworkRefreshMethodRefresh;
        self.startPage = 0;
        self.pageSize = 20;
        self.pageSizeParameterName = @"pageSize";
        self.pageParameterName = @"page";
    }
    return self;
}

/// 开始准备网络请求
/// @param request 请求相关数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回准备插件处理后的数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request endRequest:(BOOL *)endRequest{
    [super prepareWithRequest:request endRequest:endRequest];
    
    NSMutableDictionary * param = [NSMutableDictionary dictionaryWithDictionary:request.params];
    if (self.refreshMethod == KJNetworkRefreshMethodRefresh) {
        param = [self setParams:param key:self.pageParameterName value:self.startPage];
    } else if (self.refreshMethod == KJNetworkRefreshMethodAddmore) {
        NSString * key = kRefreshSHA512String(request.URLString);
        if (kRefreshDictionaryContainsKey(_pageDictionary, key)) {
            NSInteger page = [_pageDictionary[key] integerValue];
            param = [self setParams:param key:self.pageParameterName value:page];
        }
    }
    param = [self setParams:param key:self.pageSizeParameterName value:self.pageSize];
    request.params = [param mutableCopy];
    
    return self.response;
}


/// 准备返回给业务逻辑时刻调用
/// @param request 请求相关数据
/// @param error 错误信息
/// @return 返回最终加工之后的数据
- (KJNetworkingResponse *)processSuccessResponseWithRequest:(KJNetworkingRequest *)request error:(NSError **)error{
    [super processSuccessResponseWithRequest:request error:error];
    
    NSString * key = kRefreshSHA512String(request.URLString);
    NSInteger page = [KJNetworkRefreshPlugin.pageDictionary[key] integerValue];
    
    if (self.refreshMethod == KJNetworkRefreshMethodRefresh) {
        page = self.startPage;
    } else if (self.refreshMethod == KJNetworkRefreshMethodAddmore) {
        page += 1;
    }
    [KJNetworkRefreshPlugin.pageDictionary setValue:@(page) forKey:key];
    
    if (self.kAnslysisDataCount) {
        NSInteger count = self.kAnslysisDataCount(self.response.processResponse);
        self.kRequestDatasComplete ? self.kRequestDatasComplete(count < self.pageSize) : nil;
    }
    
    return self.response;
}

#pragma mark - private method

/// 加密
NS_INLINE NSString * kRefreshSHA512String(NSString * string){
    const char * cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData * data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    return [NSString stringWithString:output];
}
/// 字典是否包含某个键
NS_INLINE BOOL kRefreshDictionaryContainsKey(NSDictionary * dict, NSString * key){
    if (!key) return NO;
    return [dict.allKeys containsObject:key];
}

/// 设置分页字段数据
/// @param params 参数
/// @param key 字段名
/// @param value 对应值
- (NSMutableDictionary *)setParams:(NSMutableDictionary *)params key:(NSString *)key value:(NSInteger)value{
    if (!kRefreshDictionaryContainsKey(params, key)) {
        BOOL set = NO;
        if (self.pageType == 1 || (self.pageType & KJNetworkRefreshPageTypeString)) {
            set = YES;
            [params setValue:[NSString stringWithFormat:@"%ld",value] forKey:key];
        }
        if (set == NO) {
            if (self.pageType == 2 || (self.pageType & KJNetworkRefreshPageTypeNumber)) {
                [params setValue:@(value) forKey:key];
            }
        }
    }
    return params;
}

#pragma mark - lazy

static NSMutableDictionary * _pageDictionary = nil;
+ (NSMutableDictionary *)pageDictionary{
    if (!_pageDictionary) {
        _pageDictionary = [NSMutableDictionary dictionary];
    }
    return _pageDictionary;
}
+ (void)setPageDictionary:(NSMutableDictionary *)pageDictionary{
    _pageDictionary = pageDictionary;
}

@end
