//
//  KJEmptyDataView.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/10/25.
//  https://github.com/yangKJ/KJNetworkPlugin
//  空数据展示控件

#import <UIKit/UIKit.h>
#import "KJEmptyProvider.h"

NS_ASSUME_NONNULL_BEGIN

/// 空数据展示控件
@interface KJEmptyDataView : UIView

/// 空数据图片控件
@property (nonatomic, strong, readonly) UIImageView *emptyImageView;
/// 空数据标题
@property (nonatomic, strong, readonly) UILabel *emptyTitleLabel;
/// 空数据详情信息
@property (nonatomic, strong, readonly) UILabel *emptyDetailLabel;
/// 是否再次刷新加载按钮
@property (nonatomic, strong, readonly) UIButton *emptyRefreshButton;

/// 初始化方法
/// @param frame 尺寸
/// @param provider 参数
- (instancetype)initWithFrame:(CGRect)frame provider:(KJEmptyProvider *)provider;

@end

NS_ASSUME_NONNULL_END
