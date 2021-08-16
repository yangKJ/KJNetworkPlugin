//
//  KJNetworkBasePlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin
//  插件公共类，插件父类

#import <Foundation/Foundation.h>
#import "KJNetworkingDelegate.h"
#import "KJNetworkingRequest.h"
#import "KJNetworkingResponse.h"

NS_ASSUME_NONNULL_BEGIN

/// 插件基类
@interface KJNetworkBasePlugin : NSObject <KJNetworkDelegate>

/// 备注提示：关于插件基类
/// 此插件为所以子插件父类，内部已实现全部协议，子类可根据需要来重载协议
/// 重载之时，必须调用父类方法，否则可能会出现未解之谜，切记切记
/// 子插件请保持功能单一性原则，可参考文档来设计属于您的专属插件
/// 专属插件设计文档：

@property (nonatomic, strong, readonly) KJNetworkingRequest *request;
@property (nonatomic, strong, readonly) KJNetworkingResponse *response;

@end

NS_ASSUME_NONNULL_END
