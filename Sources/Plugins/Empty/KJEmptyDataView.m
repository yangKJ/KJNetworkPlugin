//
//  KJEmptyDataView.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/10/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJEmptyDataView.h"

@interface KJEmptyDataView ()

@property (nonatomic, strong) KJEmptyProvider *provider;
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *emptyTitleLabel;
@property (nonatomic, strong) UILabel *emptyDetailLabel;
@property (nonatomic, strong) UIButton *emptyRefreshButton;

@end

@implementation KJEmptyDataView

/// 初始化方法
/// @param frame 尺寸
/// @param provider 参数
- (instancetype)initWithFrame:(CGRect)frame provider:(KJEmptyProvider *)provider{
    if (self = [super initWithFrame:frame]) {
        id tagret = [provider valueForKey:@"tagret"];
        if (tagret) {
            [self.emptyRefreshButton addTarget:tagret action:provider.action
                              forControlEvents:(UIControlEventTouchUpInside)];
        } else if (provider.clickRefreshButton) {
            
        }
    }
    return self;
}

@end
