//
//  KJNetworkingRequest+KJCertificate.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin
//  配置自建证书专属请求体

#import "KJNetworkingRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 配置自建证书专属请求体
@interface KJNetworkingRequest (KJCertificate)

/// 自建https证书路径，该字段为空时会强制抛异常
@property (nonatomic, strong) NSString *certificatePath;
/// 是否验证域名，默认yes
@property (nonatomic, assign) BOOL validatesDomainName;

@end

NS_ASSUME_NONNULL_END
