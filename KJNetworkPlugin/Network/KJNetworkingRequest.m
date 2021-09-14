//
//  KJNetworkingRequest.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkingRequest.h"
#import <objc/runtime.h>
#import "KJBaseNetworking.h"

@interface KJNetworkingRequest ()

//******************* 名字不能更改，内部kvc有使用 *******************
/// 加密参数
@property (nonatomic, strong) id secretParams;
/// 是否使用信号量，内部链式和批量使用该字段
@property (nonatomic, assign) BOOL useSemaphore;
/// 网络请求插件时机，配合小偷插件使用效果极佳
@property (nonatomic, assign) KJRequestOpportunity opportunity;

@end

@implementation KJNetworkingRequest

- (instancetype)init{
    if (self = [super init]) {
        self.ip = [KJBaseNetworking baseURL];
        self.requestSerializer = KJSerializerHTTP;
        self.responseSerializer = KJSerializerHTTP;
        self.timeoutInterval = 30.f;
        self.method = KJNetworkRequestMethodPOST;
    }
    return self;
}

- (void)setParams:(NSDictionary *)params{
    _params = params;
    self.secretParams = params;
}

- (NSString *)URLString{
    // 拼接完整路径
    NSCharacterSet *character = [NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<>+"].invertedSet;
    if (self.path && self.path.length > 0) {
        if (![self.path hasPrefix:@"/"]) {
            self.path = [NSString stringWithFormat:@"/%@", self.path];
        }
    }
    return [[self.ip stringByAppendingString:self.path ? self.path : @""] stringByAddingPercentEncodingWithAllowedCharacters:character];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    unsigned int count = 0;
    Ivar * ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        const char *name = ivar_getName(ivars[i]);
        NSString * key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(ivars);
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar * ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            const char * name = ivar_getName(ivars[i]);
            NSString * key = [NSString stringWithUTF8String:name];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivars);
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    id instance = [[[self class] allocWithZone:zone] init];
    [self kj_copyingObject:instance];
    return instance;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    id instance = [[[self class] allocWithZone:zone] init];
    [self kj_copyingObject:instance];
    return instance;
}

/// 拷贝obj属性
- (void)kj_copyingObject:(id)obj{
    unsigned int count = 0;
    Ivar * ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++){
        const char * name = ivar_getName(ivars[i]);
        NSString * key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        if ([value respondsToSelector:@selector(copyWithZone:)]) {
            [obj setValue:[value copy] forKey:key];
        }else{
            [obj setValue:value forKey:key];
        }
    }
    free(ivars);
}

@end
