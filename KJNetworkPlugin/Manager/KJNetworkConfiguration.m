//
//  KJNetworkConfiguration.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/8/29.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkConfiguration.h"

@implementation KJNetworkConfiguration

/// 默认初始化方法
+ (instancetype)defaultConfiguration{
    KJNetworkConfiguration *configuration = [[KJNetworkConfiguration alloc] init];
    configuration.analysisResponseObject = YES;
    configuration.successCode = 1000;
    configuration.errorKeyName = @"message";
    return configuration;
}

@end

@implementation KJConstructingBody

@end

@implementation KJDownloadBody

@end
