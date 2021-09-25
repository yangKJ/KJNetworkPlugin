//
//  KJBaseNetworking.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin
//  网络请求基类，基于 AFNetworking 封装使用

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "KJNetworkingType.h"

NS_ASSUME_NONNULL_BEGIN

/// App初始化配置信息
@interface KJBaseSuperNetworking : NSObject

/// 存储网络请求
@property (nonatomic, strong, class) NSMutableArray<NSURLSessionTask *> *sessionTaskDatas;
/// 根路径地址
@property (nonatomic, strong, class) NSString *baseURL;
/// 基本参数，类似：userID，token等
@property (nonatomic, strong, class) NSDictionary *baseParameters;
/// 是否开启打印日志，默认yes
@property (nonatomic, assign, class) BOOL openLog;

/// 更新默认基本参数
/// @param value 更新值
/// @param key 更新键
+ (void)updateBaseParametersWithValue:(id)value key:(NSString *)key;

/// 是否打开网络加载菊花，默认打开
+ (void)openNetworkActivityIndicator:(BOOL)open;

/// 实时获取网络状态
+ (void)getNetworkStatusWithBlock:(void(^)(KJNetworkStatusType status))block;

/// 判断是否有网
+ (BOOL)isNetwork;

/// 是否是手机网络
+ (BOOL)isWWANNetwork;

/// 是否是WiFi网络
+ (BOOL)isWiFiNetwork;

/// 取消所有Http请求
+ (void)cancelRequests;

/// 取消指定URL的Http请求
+ (void)cancelRequestWithURL:(NSString *)url;

/// 获取指定task
+ (NSURLSessionTask *)appointTaskWithTaskIdentifier:(NSUInteger)taskIdentifier;

@end

/// 网络请求基类
@interface KJBaseNetworking : KJBaseSuperNetworking

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/// 默认初始化方法
+ (instancetype)sharedDefault;

#pragma mark - network

/// 网络请求处理
/// @param method 请求方式
/// @param url 请求地址
/// @param parameters 请求参数
/// @param success 成功回调
/// @param failure 失败回调
- (NSURLSessionTask *)HTTPWithMethod:(KJNetworkRequestMethod)method
                                 url:(NSString *)url
                          parameters:(NSDictionary * _Nullable)parameters
                             success:(KJNetworkSuccess)success
                             failure:(KJNetworkFailure)failure;

#pragma mark - upload

/// 上传资源
/// @param url 请求地址
/// @param params 请求参数
/// @param block 图片处理回调
/// @param progress 上传进度
/// @param success 成功回调
/// @param failure 失败回调
- (NSURLSessionTask *)postMultipartFormDataWithURL:(NSString *)url
                                            params:(NSDictionary * _Nullable)params
                         constructingBodyWithBlock:(KJNetworkConstructingBody)block
                                          progress:(KJNetworkProgress)progress
                                           success:(KJNetworkSuccess)success
                                           failure:(KJNetworkFailure)failure;

#pragma mark - download

/// 下载文件
/// @param url 请求地址
/// @param destination 下载文件的目的地回调
/// @param progress 文件下载的进度信息
/// @param success 成功回调
/// @param failure 失败回调
- (NSURLSessionTask *)downloadWithURL:(NSString *)url
                          destination:(KJNetworkDestination)destination
                             progress:(KJNetworkProgress)progress
                              success:(KJNetworkSuccess)success
                              failure:(KJNetworkFailure)failure;


#pragma mark - 重置 AFHTTPSessionManager 相关属性

/// 获取AFHTTPSessionManager对象
@property (nonatomic, strong, readonly) AFHTTPSessionManager *sessionManager;

/// 设置网络请求参数的格式，默认为JSON格式
/// @param requestSerializer 参数格式
- (void)setRequestSerializer:(KJSerializer)requestSerializer;

/// 设置服务器响应数据格式，默认为JSON格式
/// @param responseSerializer 服务器数据格式
- (void)setResponseSerializer:(KJSerializer)responseSerializer;

/// 设置请求超时时间，默认30秒
/// @param timeoutInterval 超时时间
- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

/// 设置请求头
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/// 配置自建证书的Https请求，参考链接：http://blog.csdn.net/syg90178aw/article/details/52839103
/// @param cerPath 自建https证书路径
/// @param validatesDomainName 是否验证域名，默认YES，如果证书的域名与请求的域名不一致，需设置为NO
/// 服务器使用其他信任机构颁发的证书也可以建立连接，但这个非常危险，建议打开 validatesDomainName = NO
/// 主要用于这种情况：客户端请求的是子域名，而证书上是另外一个域名。因为SSL证书上的域名是独立的
/// Example：证书注册的域名是www.baidu.com，那么mail.baidu.com是无法验证通过的
- (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;

@end

NS_ASSUME_NONNULL_END
