//
//  KJNetworkingRequest.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin
//  请求相关

#import <Foundation/Foundation.h>
#import "KJNetworkingType.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KJNetworkDelegate;
/// 请求相关
@interface KJNetworkingRequest : NSObject <NSCoding, NSCopying, NSMutableCopying>

/// 设置请求数据格式，默认 KJSerializerHTTP
@property (nonatomic, assign) KJSerializer requestSerializer;
/// 设置响应数据格式，默认 KJSerializerHTTP
@property (nonatomic, assign) KJSerializer responseSerializer;
/// 设置超时时间，默认30秒
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
/// 默认请求头
@property (nonatomic, strong) NSDictionary *header;
/// 插件数组，插件加入顺序会直接影响到每种插件的处理
/// 插件之间的数据会单线影响，前面的插件数据会被后面执行的插件所修改
/// 备注：在添加插件时刻需要注意添加顺序
@property (nonatomic, strong) NSArray<id<KJNetworkDelegate>>*plugins;
/// 请求类型，默认 KJNetworkRequestMethodPOST
@property (nonatomic, assign) KJNetworkRequestMethod method;
/// 根路径地址，默认 [KJBaseNetworking baseURL] 设置的根路径地址
@property (nonatomic, strong, nullable) NSString *ip;
/// 网络请求路径
@property (nonatomic, strong) NSString *path;
/// 请求参数
@property (nonatomic, strong, nullable) NSDictionary *params;
/// 加密参数，不涉及加密时刻该数据与上面一致
@property (nonatomic, strong, readonly) NSDictionary *secretParams;
/// 网址请求地址
@property (nonatomic, strong, readonly) NSString *URLString;

/// 网络请求插件时机，配合 `KJNetworkThiefPlugin` 插件使用效果极佳
@property (nonatomic, assign, readonly) KJRequestOpportunity opportunity;
/// 是否为缓存数据，配合 `KJNetworkCachePlugin` 插件使用
@property (nonatomic, assign, readonly) BOOL cacheData;

@end

NS_ASSUME_NONNULL_END
