//
//  KJNetworkBasePlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkBasePlugin.h"

@interface KJNetworkBasePlugin ()

@property (nonatomic, strong) KJNetworkingRequest *request;
@property (nonatomic, strong) KJNetworkingResponse *response;

@end

@implementation KJNetworkBasePlugin

/// 开始准备网络请求
/// @param request 请求相关数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回缓存数据，successResponse 不为空表示存在缓存数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request endRequest:(BOOL *)endRequest{
    self.request = request;
    self.response.opportunity = KJNetworkingRequestOpportunityPrepare;
    return self.response;
}

/// 网络请求开始时刻请求
/// @param request 请求相关数据
/// @param stopRequest 是否停止网络请求
/// @return 返回网络请求开始时刻插件处理后的数据
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request stopRequest:(BOOL *)stopRequest{
    self.request = request;
    self.response.opportunity = KJNetworkingRequestOpportunityWillSend;
    return self.response;
}

/// 成功接收数据
/// @param request  接收成功数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    self.request = request;
    self.response.opportunity = KJNetworkingRequestOpportunitySuccess;
    return self.response;
}

/// 失败处理
/// @param request  失败的网络活动
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest{
    self.request = request;
    self.response.opportunity = KJNetworkingRequestOpportunityFailure;
    return self.response;
}

/// 准备返回给业务逻辑时刻调用
/// @param request 请求相关数据
/// @param error 错误信息
/// @return 返回最终加工之后的数据
- (KJNetworkingResponse *)processSuccessResponseWithRequest:(KJNetworkingRequest *)request error:(NSError **)error{
    self.request = request;
    self.response.opportunity = KJNetworkingRequestOpportunityProcess;
    return self.response;
}

#pragma mark - lazy

- (KJNetworkingResponse *)response{
    @synchronized (self) {
        if (!_response) {
            _response = [[KJNetworkingResponse alloc] init];
        }
        return _response;
    }
}

@end
