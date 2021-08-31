//
//  KJCaptureResponse.m
//  KJNetworkPlugin
//
//  Created by yangkejun on 2021/8/31.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJCaptureResponse.h"

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

@end
