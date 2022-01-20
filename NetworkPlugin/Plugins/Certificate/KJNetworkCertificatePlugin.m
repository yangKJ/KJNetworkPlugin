//
//  KJNetworkCertificatePlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkCertificatePlugin.h"
#import "KJNetworkingRequest+KJCertificate.h"

@implementation KJNetworkCertificatePlugin

- (instancetype)init{
    if (self = [super init]) {
        self.validatesDomainName = YES;
    }
    return self;
}

/// 开始准备网络请求
/// @param request 请求相关数据
/// @param response 响应数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回缓存数据，successResponse 不为空表示存在缓存数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                  endRequest:(BOOL *)endRequest{
    
    if (self.certificatePath == nil) {
        NSExpression * expression = [NSExpression expressionWithFormat:@"Certificate Plugin `certificatePath` is nil."];
        @throw expression;
    } else {
        request.certificatePath = self.certificatePath;
        request.validatesDomainName = self.validatesDomainName;
    }
    
    return response;
}

@end
