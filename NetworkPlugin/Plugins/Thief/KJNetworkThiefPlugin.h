//
//  KJNetworkThiefPlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin
//  修改 KJNetworkingRequest 和 获取 KJNetworkingResponse 插件

#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN

/// 修改器插件，又名小偷插件
/// 使用文档：https://github.com/yangKJ/KJNetworkPlugin/blob/master/Docs/THIEF.md
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
