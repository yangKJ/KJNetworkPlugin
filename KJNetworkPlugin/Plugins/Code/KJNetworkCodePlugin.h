//
//  KJNetworkCodePlugin.h
//  KJNetworkPlugin
//
//  Created by yangkejun on 2021/9/29.
//  https://github.com/yangKJ/KJNetworkPlugin
//  HTTP状态码处理

#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN

/// 状态码
typedef NS_ENUM(NSUInteger, KJHTTPCodeStatus){
    KJHTTPCodeStatusUnknown,
    /* 400 系列 */
    KJHTTPCodeStatusBadRequest = 400,
    KJHTTPCodeStatusUnauthorized = 401,
    KJHTTPCodeStatusPaymentRequired = 402,
    KJHTTPCodeStatusForbidden = 403,
    KJHTTPCodeStatusNotFound = 404,
    KJHTTPCodeStatusMethodNotAllowed = 405,
    KJHTTPCodeStatusNotAcceptable = 406,
    KJHTTPCodeStatusProxyAuthenticationRequired = 407,
    KJHTTPCodeStatusRequestTimeOut = 408,
    KJHTTPCodeStatusConflict = 409,
    KJHTTPCodeStatusGone = 410,
    KJHTTPCodeStatusLengthRequired = 411,
    KJHTTPCodeStatusPreconditionFailed = 412,
    KJHTTPCodeStatusRequestEntityTooLarge = 413,
    KJHTTPCodeStatusRequestURITooLarge = 414,
    KJHTTPCodeStatusUnsupportedMediaType = 415,
    KJHTTPCodeStatusRequestedRangeNotSatisfiable = 416,
    KJHTTPCodeStatusExpectationFailed = 417,
    
    /* 500 系列 */
    KJHTTPCodeStatusInternalServerError = 500,
    KJHTTPCodeStatusNotImplemented = 501,
    KJHTTPCodeStatusBadGateway = 502,
    KJHTTPCodeStatusServiceUnavailable = 503,
    KJHTTPCodeStatusGatewayTimeOut = 504,
    KJHTTPCodeStatusHTTPVersionNotSupported = 505,
};
static NSString * const _Nonnull KJHTTPCodeStatusStringMap[] = {
    [KJHTTPCodeStatusUnknown] = @"未知编码",
    [KJHTTPCodeStatusBadRequest] = @"客户端请求的语法错误，服务器无法理解",
    [KJHTTPCodeStatusUnauthorized] = @"请求要求用户的身份认证",
    [KJHTTPCodeStatusPaymentRequired] = @"保留，将来使用",
    [KJHTTPCodeStatusForbidden] = @"服务器理解请求客户端的请求，但是拒绝执行此请求",
    [KJHTTPCodeStatusNotFound] = @"服务器无法根据客户端的请求找到资源",
    [KJHTTPCodeStatusMethodNotAllowed] = @"客户端请求中的方法被禁止",
    [KJHTTPCodeStatusNotAcceptable] = @"服务器无法根据客户端请求的内容特性完成请求",
    [KJHTTPCodeStatusProxyAuthenticationRequired] = @"请求要求代理的身份认证，请求者应当使用代理进行授权",
    [KJHTTPCodeStatusRequestTimeOut] = @"服务器等待客户端发送的请求时间过长，超时",
    [KJHTTPCodeStatusConflict] = @"服务器完成客户端请求时可能返回此代码，服务器处理请求时发生了冲突",
    [KJHTTPCodeStatusGone] = @"客户端请求的资源已经不存在",
    [KJHTTPCodeStatusLengthRequired] = @"服务器无法处理客户端发送的不带Content-Length的请求信息",
    [KJHTTPCodeStatusPreconditionFailed] = @"客户端请求信息的先决条件错误",
    [KJHTTPCodeStatusRequestEntityTooLarge] = @"由于请求的实体过大，服务器无法处理",
    [KJHTTPCodeStatusRequestURITooLarge] = @"请求的URI过长，服务器无法处理",
    [KJHTTPCodeStatusUnsupportedMediaType] = @"服务器无法处理请求附带的媒体格式",
    [KJHTTPCodeStatusRequestedRangeNotSatisfiable] = @"客户端请求的范围无效",
    [KJHTTPCodeStatusExpectationFailed] = @"服务器无法满足Expect的请求头信息",
    [KJHTTPCodeStatusInternalServerError] = @"服务器内部错误，无法完成请求",
    [KJHTTPCodeStatusNotImplemented] = @"服务器不支持请求的功能，无法完成请求",
    [KJHTTPCodeStatusBadGateway] = @"服务器作为网关需要得到一个处理这个请求的响应，得到一个错误的响应",
    [KJHTTPCodeStatusServiceUnavailable] = @"由于超载或系统维护，服务器暂时的无法处理客户端的请求",
    [KJHTTPCodeStatusGatewayTimeOut] = @"充当网关或代理的服务器，未及时从远端服务器获取请求",
    [KJHTTPCodeStatusHTTPVersionNotSupported] = @"服务器不支持请求的HTTP协议的版本",
};
/// HTTP状态码处理，https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Status
@interface KJNetworkCodePlugin : KJNetworkBasePlugin

/// 获取服务器Code信息
/// @param error 错误
+ (NSString *)errorCodeString:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
