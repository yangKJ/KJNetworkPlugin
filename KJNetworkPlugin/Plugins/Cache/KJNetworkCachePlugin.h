//
//  KJNetworkCachePlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  网络缓存相关插件
//  https://github.com/yangKJ/KJNetworkPlugin

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
/// 缓存文件名加密方式
typedef NS_ENUM(NSUInteger, KJNetworkCacheNameEncryptType){
    KJNetworkCacheNameEncryptTypeMD5,
    KJNetworkCacheNameEncryptTypeSHA256,
};
@class YYCache;
@interface KJNetworkCachePlugin : KJNetworkBasePlugin

/// 缓存文件名加密方式，默认 KJNetworkCacheNameSercetTypeSHA256
@property (nonatomic, assign) KJNetworkCacheNameEncryptType nameEncryptType;
/// 缓存方式，默认 KJNetworkCacheMethodNone
@property (nonatomic, assign) KJNetworkCachePolicy cachePolicy;
/// 缓存相关
@property (nonatomic, strong, readonly) YYCache *dataCache;

@end

NS_ASSUME_NONNULL_END
