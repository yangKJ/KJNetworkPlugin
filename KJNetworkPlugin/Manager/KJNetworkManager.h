//
//  KJNetworkManager.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/8/29.
//  https://github.com/yangKJ/KJNetworkPlugin
//  网络管理器，二次封装插件版网络，支持上传资源和下载资源文件

#import <Foundation/Foundation.h>
#import "KJNetworkConfiguration.h"
#import "KJNetworkingRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 网络管理器
@interface KJNetworkManager : NSObject

/// 二次封装插件版网络请求
/// @param request 请求体
/// @param configuration 配置信息
/// @param success 成功回调
/// @param failure 失败回调
+ (nullable NSURLSessionTask *)HTTPRequest:(__kindof KJNetworkingRequest *)request
                             configuration:(KJNetworkConfiguration * _Nullable)configuration
                                   success:(void(^_Nullable)(id responseObject))success
                                   failure:(void(^_Nullable)(NSError * error))failure;

/// 取消网络请求，
+ (void)cancelRequestWithTask:(NSURLSessionTask *)task;

@end

NS_ASSUME_NONNULL_END
