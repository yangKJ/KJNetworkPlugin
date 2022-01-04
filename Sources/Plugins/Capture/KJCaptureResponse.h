//
//  KJCaptureResponse.h
//  KJNetworkPlugin
//
//  Created by yangkejun on 2021/8/31.
//  https://github.com/yangKJ/KJNetworkPlugin
//  抓包日志模型

#import <Foundation/Foundation.h>
#import "KJNetworkingType.h"

NS_ASSUME_NONNULL_BEGIN

/// 抓包日志模型
@interface KJCaptureResponse : NSObject

/// 请求类型
@property (nonatomic, strong) NSString *methodString;
/// 根路径地址
@property (nonatomic, strong) NSString *ip;
/// 网络请求路径
@property (nonatomic, strong) NSString *path;
/// 网址请求地址
@property (nonatomic, strong, readonly) NSString *URLString;
/// 请求参数
@property (nonatomic, strong) NSString *paramsJSONString;
/// 默认请求头
@property (nonatomic, strong) NSString *headerJSONString;

/// 成功数据
@property (nonatomic, strong) NSString *responseJSONString;

@end

NS_ASSUME_NONNULL_END
