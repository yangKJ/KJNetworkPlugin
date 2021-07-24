//
//  KJNetworkBasePlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  插件公共类，插件父类
//  https://github.com/yangKJ/KJNetworkPlugin

#import <Foundation/Foundation.h>
#import "KJNetworkDelegate.h"
#import "KJNetworkingRequest.h"
#import "KJNetworkingResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJNetworkBasePlugin : NSObject <KJNetworkDelegate>

@property (nonatomic, strong, readonly) KJNetworkingRequest *request;
@property (nonatomic, strong, readonly) KJNetworkingResponse *response;

@end

NS_ASSUME_NONNULL_END
