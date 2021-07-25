//
//  KJNetworkThiefPlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  修改 KJNetworkingRequest 和 获取 KJNetworkingResponse 插件
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN

/// 小偷插件使用文档：https://github.com/yangKJ/KJNetworkPlugin/wiki/KJNetworkThiefPlugin
@interface KJNetworkThiefPlugin : KJNetworkBasePlugin

/// 失败之后是否再次网络请求，默认NO
@property (nonatomic, assign) BOOL againRequest;
/// 修改请求体，会修改掉网络外界传入的请求体数据
@property (nonatomic,copy,readwrite) void(^kChangeRequest)(KJNetworkingRequest * request);
/// 获取对应的响应结果
@property (nonatomic,copy,readwrite) void(^kGetResponse)(KJNetworkingResponse * response);

@end

NS_ASSUME_NONNULL_END
