//
//  KJNetworkThiefPlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkThiefPlugin.h"

@interface KJNetworkThiefPlugin ()

@property (nonatomic, assign) NSInteger currentAgainRequestCount;

@end

@implementation KJNetworkThiefPlugin

- (instancetype)init{
    if (self = [super init]) {
        self.currentAgainRequestCount = 0;
        self.maxAgainRequestCount = 3;
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
    
    if (self.kChangeRequest) {
        self.kChangeRequest(request);
    }
    if (self.kGetResponse) {
        self.kGetResponse(response);
    }
    return response;
}

/// 网络请求开始时刻请求
/// @param request 请求相关数据
/// @param response 响应数据
/// @param stopRequest 是否停止网络请求
/// @return 返回网络请求开始时刻插件处理后的数据
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request
                                     response:(KJNetworkingResponse *)response
                                  stopRequest:(BOOL *)stopRequest{
    
    if (self.kChangeRequest) {
        self.kChangeRequest(request);
    }
    if (self.kGetResponse) {
        self.kGetResponse(response);
    }
    return response;
}

/// 成功接收数据
/// @param request  接收成功数据
/// @param response 响应数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                againRequest:(BOOL *)againRequest{
    
    self.currentAgainRequestCount = 0;
    if (self.kChangeRequest) {
        self.kChangeRequest(request);
    }
    if (self.kGetResponse) {
        self.kGetResponse(response);
    }
    return response;
}

/// 失败处理
/// @param request  失败的网络活动
/// @param response 响应数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request
                                    response:(KJNetworkingResponse *)response
                                againRequest:(BOOL *)againRequest{
    
    * againRequest = self.againRequest;
    if (++self.currentAgainRequestCount >= self.maxAgainRequestCount) {
        * againRequest = NO;
    }
    if (self.kChangeRequest) {
        self.kChangeRequest(request);
    }
    if (self.kGetResponse) {
        self.kGetResponse(response);
    }
    return response;
}

/// 准备返回给业务逻辑时刻调用
/// @param request 请求相关数据
/// @param response 响应数据
/// @param error 错误信息
/// @return 返回最终加工之后的数据
- (KJNetworkingResponse *)processSuccessResponseWithRequest:(KJNetworkingRequest *)request
                                                   response:(KJNetworkingResponse *)response
                                                      error:(NSError **)error{
    
    self.currentAgainRequestCount = 0;
    return response;
}

@end
