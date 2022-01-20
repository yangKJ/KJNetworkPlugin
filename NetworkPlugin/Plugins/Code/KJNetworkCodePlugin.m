//
//  KJNetworkCodePlugin.m
//  KJNetworkPlugin
//
//  Created by yangkejun on 2021/9/29.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkCodePlugin.h"

@implementation KJNetworkCodePlugin

/// 失败处理
/// @param request  失败的网络活动
/// @param response 响应数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                againRequest:(BOOL *)againRequest{
    
    NSString * __autoreleasing string = KJHTTPCodeStatusStringMap[response.error.code];
    
    NSLog(@"\n🎷🎷🎷 错误Code信息 = %@", string);
    
    return response;
}

/// 获取服务器Code信息
/// @param error 错误
+ (NSString *)errorCodeString:(NSError *)error{
    if (error == nil) {
        return @"";
    }
    return KJHTTPCodeStatusStringMap[error.code];
}

@end
