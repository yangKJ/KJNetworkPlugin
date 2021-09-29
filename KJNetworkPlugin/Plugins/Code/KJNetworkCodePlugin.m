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
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    [super failureWithRequest:request againRequest:againRequest];
    
    NSString * __autoreleasing string = KJHTTPCodeStatusStringMap[self.response.error.code];
    
    NSLog(@"\n🎷🎷🎷 错误Code信息 = %@", string);
    
    return self.response;
}

@end
