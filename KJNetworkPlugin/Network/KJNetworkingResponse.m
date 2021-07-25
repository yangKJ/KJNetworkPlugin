//
//  KJNetworkingResponse.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkingResponse.h"

@interface KJNetworkingResponse ()

/// 原始网络成功返回数据
@property (nonatomic, strong) id responseObject;
/// 插件处理过成功数据，未处理时刻为空
@property (nonatomic, strong) id successResponse;
/// 插件处理过失败数据，未处理时刻为空
@property (nonatomic, strong) id failureResponse;
/// 准备插件处理的数据，未处理时刻为空
@property (nonatomic, strong) id prepareResponse;
/// 最终加工处理的数据，未处理时刻为空
@property (nonatomic, strong) id processResponse;
/// 网络请求task
@property (nonatomic, strong) NSURLSessionDataTask *task;
/// 失败
@property (nonatomic, strong) NSError *error;


//*************** 名字别改，内部机密数据，仅供内部使用 ***************
/// 临时数据，内部最终返回时刻处理插件使用
@property (nonatomic, strong) id tempResponse;

@end

@implementation KJNetworkingResponse

@end
