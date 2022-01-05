//
//  KJNetworkCapturePlugin.h
//  KJNetworkPlugin
//
//  Created by yangkejun on 2021/8/31.
//  https://github.com/yangKJ/KJNetworkPlugin
//  网络日志抓包插件

#import "KJNetworkBasePlugin.h"
#import "KJCaptureResponse.h"

NS_ASSUME_NONNULL_BEGIN

/// 网络日志抓包插件
/// 网络日志只做临时存储，重启应用即清空数据
@interface KJNetworkCapturePlugin : KJNetworkBasePlugin

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/// 单例设计
+ (instancetype)sharedInstance;

/// Debug模式是否开启日志打印，默认开启
@property (nonatomic, assign) BOOL openLog;

/// 读取全部日志
/// @param complete 读取回调
+ (void)readAllLogComplete:(void(^)(NSArray<KJCaptureResponse *> * logs))complete;

/// 读取指定网络日志
/// @param ip 根路径地址
/// @param path 网络请求路径
/// @param params 请求参数
/// @param complete 读取回调
+ (void)readLogWithIp:(NSString *)ip
                 path:(NSString *)path
               params:(nullable id)params
             complete:(void(^)(KJCaptureResponse * response))complete;

@end

NS_ASSUME_NONNULL_END
