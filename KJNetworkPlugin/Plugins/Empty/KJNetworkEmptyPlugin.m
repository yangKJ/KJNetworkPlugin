//
//  KJNetworkEmptyPlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/10/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkEmptyPlugin.h"
#import "KJEmptyDataView.h"

@implementation KJNetworkEmptyPlugin

/// 初始化
/// @param provider 需求参数
- (instancetype)initWithEmptyProvider:(nullable KJEmptyProvider *)provider{
    if (self = [super init]) {
        
    }
    return self;
}

/// 主动显示空数据页面，不受自动隐藏的限制
- (void)showEmptyView{
    
}

/// 主动隐藏空数据页面
- (void)hideEmptyView{
    
}

@end

