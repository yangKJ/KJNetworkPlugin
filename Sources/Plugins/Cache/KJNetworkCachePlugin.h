//
//  KJNetworkCachePlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin
//  网络缓存相关插件

#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN
/// 缓存方式
typedef NS_ENUM(NSUInteger, KJNetworkCachePolicy){
    /**只从网络获取数据，且数据不会缓存在本地*/
    KJNetworkCachePolicyIgnoreCache = 0,
    /**只从缓存读数据，如果缓存没有数据，返回一个空*/
    KJNetworkCachePolicyCacheOnly = 1,
    /**先从网络获取数据，同时会在本地缓存数据*/
    KJNetworkCachePolicyNetworkOnly = 2,
    /**先从缓存读取数据，如果没有再从网络获取*/
    KJNetworkCachePolicyCacheElseNetwork = 3,
    /**先从网络获取数据，如果没有在从缓存获取，此处的没有可以理解为访问网络失败，再从缓存读取*/
    KJNetworkCachePolicyNetworkElseCache = 4,
    /**先从缓存读取数据，然后在从网络获取并且缓存，在这种情况下，Block将产生两次调用*/
    KJNetworkCachePolicyCacheThenNetwork = 5
};

@class YYCache;
/// 网络缓存相关插件
@interface KJNetworkCachePlugin : KJNetworkBasePlugin

/// 缓存方式，默认 KJNetworkCacheMethodNone
@property (nonatomic, assign) KJNetworkCachePolicy cachePolicy;
/// 缓存相关
@property (nonatomic, strong, readonly) YYCache *dataCache;

/// 读取指定网络缓存
/// @param url 网络链接
/// @param parameters 参数
/// @return 返回网络缓存数据
+ (id)readCacheWithURL:(NSString *)url parameters:(nullable NSDictionary *)parameters;

/// 存储指定网络缓存数据
/// @param url 网络链接
/// @param parameters 参数
/// @param httpData 网络数据
+ (void)saveCacheWithURL:(NSString *)url
              parameters:(NSDictionary * _Nullable)parameters
                httpData:(id)httpData;

/// 清除全部缓存
+ (void)removeAllCache;

/// 清除指定网络缓存
/// @param url 网络链接
/// @param parameters 参数
+ (void)removeCacheWithURL:(NSString *)url parameters:(nullable NSDictionary *)parameters;

/// 获取网络缓存的总大小
/// @return 缓存大小，单位字节
+ (NSInteger)getCacheSize;

@end

NS_ASSUME_NONNULL_END
