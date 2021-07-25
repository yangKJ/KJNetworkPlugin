//
//  KJNetworkCertificatePlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  配置自建证书插件
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJNetworkCertificatePlugin : KJNetworkBasePlugin

/// 配置自建证书的Https请求，参考链接：https://juejin.cn/post/6844903545464963085
/// 服务器使用其他信任机构颁发的证书也可以建立连接，但这个非常危险，建议打开 validatesDomainName = NO
/// 主要用于这种情况：客户端请求的是子域名，而证书上是另外一个域名。因为SSL证书上的域名是独立的
/// Example：证书注册的域名是www.baidu.com，那么mail.baidu.com是无法验证通过的

/// 自建https证书路径
@property (nonatomic, strong) NSString *certificatePath;

/// 是否验证域名，默认yes
/// 如果证书的域名与请求的域名不一致，需设置为NO
@property (nonatomic, assign) BOOL validatesDomainName;

@end

NS_ASSUME_NONNULL_END
