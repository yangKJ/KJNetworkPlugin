//
//  KJNetworkThiefPlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkThiefPlugin.h"

@implementation KJNetworkThiefPlugin

/// 开始准备网络请求
/// @param request 请求相关数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回准备插件处理后的数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request endRequest:(BOOL *)endRequest{
    [super prepareWithRequest:request endRequest:endRequest];
    if (self.kChangeRequest) {
        self.kChangeRequest(request);
    }
    if (self.kGetResponse) {
        self.kGetResponse(self.response);
    }
    return self.response;
}

/// 网络请求开始时刻请求
/// @param request 请求相关数据
/// @param stopRequest 是否停止网络请求
/// @return 返回网络请求开始时刻插件处理后的数据
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request stopRequest:(BOOL *)stopRequest{
    [super willSendWithRequest:request stopRequest:stopRequest];
    if (self.kChangeRequest) {
        self.kChangeRequest(request);
    }
    if (self.kGetResponse) {
        self.kGetResponse(self.response);
    }
    return self.response;
}

/// 成功接收数据
/// @param request  接收成功数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    [super succeedWithRequest:request againRequest:againRequest];
    if (self.kChangeRequest) {
        self.kChangeRequest(request);
    }
    if (self.kGetResponse) {
        self.kGetResponse(self.response);
    }
    return self.response;
}

/// 失败处理
/// @param request  失败的网络活动
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    [super failureWithRequest:request againRequest:againRequest];
    * againRequest = self.againRequest;
    if (self.kChangeRequest) {
        self.kChangeRequest(request);
    }
    if (self.kGetResponse) {
        self.kGetResponse(self.response);
    }
    return self.response;
}

@end
