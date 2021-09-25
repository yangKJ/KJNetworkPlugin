//
//  KJNetworkRefreshPlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/9/25.
//  https://github.com/yangKJ/KJNetworkPlugin
//  刷新插件

#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN

/// 刷新加载类型
typedef NS_ENUM(NSUInteger, KJNetworkRefreshMethod) {
    KJNetworkRefreshMethodRefresh,// 下拉刷新
    KJNetworkRefreshMethodAddmore,// 加载更多
};
/// 分页参数类型
typedef NS_OPTIONS(NSUInteger, KJNetworkRefreshPageType) {
    KJNetworkRefreshPageTypeString = 1 << 1,// 字符串
    KJNetworkRefreshPageTypeNumber = 1 << 2,// 对象
};
/// 下拉刷新和加载更多插件
@interface KJNetworkRefreshPlugin : KJNetworkBasePlugin

/// 刷新类型，默认 KJNetworkRefreshMethodRefresh
@property (nonatomic, assign) KJNetworkRefreshMethod refreshMethod;
/// 分页参数类型，默认 KJNetworkRefreshPageTypeString
@property (nonatomic, assign) KJNetworkRefreshPageType pageType;
/// 分页起始值，默认为零
@property (nonatomic, assign) NSInteger startPage;
/// 每页个数，默认 20 条
@property (nonatomic, assign) NSInteger pageSize;
/// 每页参数名，默认 `pageSize`
/// 该参数会加入至请求参数之中，因此网络调用时可不传入该参数
@property (nonatomic, strong) NSString *pageSizeParameterName;
/// 分页参数名，默认 `page`
/// 该参数会加入至请求参数之中，因此网络调用时可不传入该参数
@property (nonatomic, strong) NSString *pageParameterName;

/// 解析数据条数
@property (nonatomic, copy, readwrite) NSInteger(^kAnslysisDataCount)(id responseObject);
/// 请求全部数据回调
@property (nonatomic, copy, readwrite) void(^kRequestDatasComplete)(BOOL requestAll);

@end

NS_ASSUME_NONNULL_END
