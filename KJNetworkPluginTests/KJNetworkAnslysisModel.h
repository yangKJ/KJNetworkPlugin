//
//  KJNetworkAnslysisModel.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJNetworkAnslysisModel : NSObject

@property (nonatomic, strong) NSString *channel_id;
@property (nonatomic, strong) NSString *abbr_en;
@property (nonatomic, strong) NSString *name_en;
@property (nonatomic, strong) NSString *seq_id;
@property (nonatomic, strong) NSString *name;

- (instancetype)initWithResponseObject:(id)responseObject;

@end

NS_ASSUME_NONNULL_END
