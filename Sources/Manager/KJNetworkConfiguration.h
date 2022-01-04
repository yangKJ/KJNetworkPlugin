//
//  KJNetworkConfiguration.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/8/29.
//  https://github.com/yangKJ/KJNetworkPlugin
//  网络配置信息

#import <Foundation/Foundation.h>
#import "KJNetworkingType.h"

NS_ASSUME_NONNULL_BEGIN

@class KJConstructingBody;
@class KJDownloadBody;
/// 网络配置信息
@interface KJNetworkConfiguration : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/// 默认初始化方法
+ (instancetype)defaultConfiguration;

/// 是否解析返回结果数据，默认yes
/// 三方接口不需要解析，自己服务器可解析数据
@property (nonatomic, assign) BOOL analysisResponseObject;
/// 正确Code编码，默认1000
@property (nonatomic, assign) NSInteger successCode;
/// 状态名字段名，默认 `code`
@property (nonatomic, strong) NSString *codeKeyName;
/// 错误信息字段名，默认 `message`
@property (nonatomic, strong) NSString *errorKeyName;

/// 是否开启抓包插件，默认开启
/// 需要配合 `Capture` 模块才能使用
@property (nonatomic, assign) BOOL openCapture;

/// 上传资源文件，需要使用时刻需要实例化该对象
@property (nonatomic, strong, nullable) KJConstructingBody *constructingBody;

/// 下载文件，需要使用时刻需要实例化该对象
@property (nonatomic, strong, nullable) KJDownloadBody *downloadBody;

@end

/// 上传资源文件操作
@interface KJConstructingBody : NSObject

/// 上传资源，必须实现
@property (nonatomic, copy, readwrite) void(^constructingBodyWithBlock)(id<AFMultipartFormData> formData);
/// 上传进度
@property (nonatomic, copy, readwrite) void(^uploadProgressWithBlock)(NSProgress * progress);

@end

/// 下载文件操作
@interface KJDownloadBody : NSObject

/// 文件下载路径，必须实现
@property (nonatomic, copy, readwrite) NSURL * (^destination)(NSURL *targetPath, NSURLResponse *response);
/// 下载进度
@property (nonatomic, copy, readwrite) void(^downloadProgressWithBlock)(NSProgress * progress);

@end

NS_ASSUME_NONNULL_END
