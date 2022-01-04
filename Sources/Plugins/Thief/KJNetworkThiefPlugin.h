//
//  KJNetworkThiefPlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin
//  修改 KJNetworkingRequest 和 获取 KJNetworkingResponse 插件

#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN

/// 小偷插件使用文档：
/// https://github.com/yangKJ/KJNetworkPlugin/wiki/%E6%8F%92%E4%BB%B6%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B
@interface KJNetworkThiefPlugin : KJNetworkBasePlugin

/// 失败之后是否再次网络请求，默认NO
@property (nonatomic, assign) BOOL againRequest;
/// 失败最大重连次数，默认3次
@property (nonatomic, assign) NSInteger maxAgainRequestCount;
/// 修改请求体，会修改掉网络外界传入的请求体数据
@property (nonatomic,copy,readwrite) void(^kChangeRequest)(KJNetworkingRequest * request);
/// 获取对应的响应结果
@property (nonatomic,copy,readwrite) void(^kGetResponse)(KJNetworkingResponse * response);

@end

NS_ASSUME_NONNULL_END
