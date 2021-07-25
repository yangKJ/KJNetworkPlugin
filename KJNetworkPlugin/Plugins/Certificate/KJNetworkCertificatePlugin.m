//
//  KJNetworkCertificatePlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkCertificatePlugin.h"

@implementation KJNetworkCertificatePlugin

- (instancetype)init{
    if (self = [super init]) {
        self.validatesDomainName = YES;
    }
    return self;
}

/// 开始准备网络请求
/// @param request 请求相关数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回准备插件处理后的数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request endRequest:(BOOL *)endRequest{
    [super prepareWithRequest:request endRequest:endRequest];
    
    if (self.certificatePath == nil) {
        * endRequest = YES;
    } else {
        [request setValue:self.certificatePath forKey:@"certificatePath"];
        [request setValue:@(self.validatesDomainName) forKey:@"validatesDomainName"];
    }
    
    return self.response;
}

@end