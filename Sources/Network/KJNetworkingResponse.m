//
//  KJNetworkingResponse.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkingResponse.h"
#import <objc/runtime.h>

@interface KJNetworkingResponse ()

/// 原始网络成功返回数据
@property (nonatomic, strong) id responseObject;
/// 插件处理过成功数据，未处理时刻为空
@property (nonatomic, strong) id successResponse;
/// 插件处理过失败数据，未处理时刻为空
@property (nonatomic, strong) id failureResponse;
/// 准备插件处理的数据，未处理时刻为空
@property (nonatomic, strong) id prepareResponse;
/// 最终加工处理的数据，未处理时刻为空
@property (nonatomic, strong) id processResponse;
/// 网络请求task
@property (nonatomic, strong) NSURLSessionDataTask *task;
/// 失败
@property (nonatomic, strong) NSError *error;


//*************** 名字别改，内部机密数据，仅供内部使用 ***************
/// 临时数据，内部最终返回时刻处理插件使用
@property (nonatomic, strong) id tempResponse;
/// 缓存插件，STNetworkCachePolicyCacheThenNetwork 抛出本地数据
@property (nonatomic, assign) BOOL cacheCastLocalResponse;

@end

@implementation KJNetworkingResponse

#ifdef DEBUG
/// 格式化输出对象
- (NSString *)debugDescription{
    //判断是否时NSArray 或者NSDictionary NSNumber 如果是的话直接返回 debugDescription
    if ([self isKindOfClass:[NSArray class]] ||
        [self isKindOfClass:[NSDictionary class]] ||
        [self isKindOfClass:[NSString class]] ||
        [self isKindOfClass:[NSNumber class]]) {
        return [self debugDescription];
    }
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    uint count;
    objc_property_t * properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = @(property_getName(property));
        id value = [self valueForKey:name] ?: @"nil";
        [dictionary setObject:value forKey:name];
    }
    free(properties);
    return [NSString stringWithFormat:@"<%@: %p> -- %@", [self class], self, dictionary];
}
#endif

@end
