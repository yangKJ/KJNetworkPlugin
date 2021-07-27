//
//  KJNetworkingType.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  汇总所有枚举和回调声明
//  https://github.com/yangKJ/KJNetworkPlugin

#ifndef KJNetworkingType_h
#define KJNetworkingType_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 请求方式
typedef NS_ENUM(NSUInteger, KJNetworkRequestMethod){
    /**GET请求方式*/
    KJNetworkRequestMethodGET = 0,
    /**POST请求方式*/
    KJNetworkRequestMethodPOST,
    /**HEAD请求方式*/
    KJNetworkRequestMethodHEAD,
    /**PUT请求方式*/
    KJNetworkRequestMethodPUT,
    /**PATCH请求方式*/
    KJNetworkRequestMethodPATCH,
    /**DELETE请求方式*/
    KJNetworkRequestMethodDELETE
};

/// 网络状态
typedef NS_ENUM(NSUInteger, KJNetworkStatusType){
    /**未知网络*/
    KJNetworkStatusUnknown,
    /**无网路*/
    KJNetworkStatusNotReachable,
    /**手机网络*/
    KJNetworkStatusReachablePhone,
    /**WiFi网络*/
    KJNetworkStatusReachableWiFi
};

/// 请求格式 和 返回数据响应格式
typedef NS_ENUM(NSUInteger, KJSerializer){
    KJSerializerHTTP = 0, /// 二进制文件，NSData
    KJSerializerJSON = 1, /// JSON
};

/// 插件请求时机
typedef NS_ENUM(NSUInteger, KJRequestOpportunity) {
    KJRequestOpportunityPrepare, /// 开始准备网络请求
    KJRequestOpportunityWillSend,/// 网络请求开始时刻请求
    KJRequestOpportunitySuccess, /// 成功
    KJRequestOpportunityFailure, /// 失败
    KJRequestOpportunityProcess  /// 最终处理时刻
};

@protocol AFMultipartFormData;
/// 成功回调
typedef void(^_Nullable KJNetworkSuccess)(NSURLSessionDataTask * _Nullable task, id responseObject);
/// 失败回调
typedef void(^_Nullable KJNetworkFailure)(NSURLSessionDataTask * _Nullable task, NSError * error);
/// 上传或者下载的进度
typedef void(^_Nullable KJNetworkProgress)(NSProgress * progress);
/// 上传资源回调
typedef void(^_Nullable KJNetworkConstructingBody)(id<AFMultipartFormData> formData);
/// 下载文件回调
typedef NSURL * _Nonnull(^_Nullable KJNetworkDestination)(NSURL * targetPath, NSURLResponse * response);

@class KJNetworkingRequest;
/// 插件成功回调
typedef void(^_Nullable KJNetworkPluginSuccess)(KJNetworkingRequest * request, id responseObject);
/// 插件失败回调
typedef void(^_Nullable KJNetworkPluginFailure)(KJNetworkingRequest * request, NSError * error);

NS_ASSUME_NONNULL_END

#endif /* KJNetworkingType_h */
