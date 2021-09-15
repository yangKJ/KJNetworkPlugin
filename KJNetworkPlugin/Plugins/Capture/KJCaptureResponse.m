//
//  KJCaptureResponse.m
//  KJNetworkPlugin
//
//  Created by yangkejun on 2021/8/31.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJCaptureResponse.h"
#import <objc/runtime.h>

@implementation KJCaptureResponse

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
