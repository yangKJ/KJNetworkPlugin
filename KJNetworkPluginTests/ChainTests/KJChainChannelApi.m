//
//  KJChainChannelApi.m
//  KJNetworkPlugin
//
//  Created by yangkejun on 2021/9/9.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJChainChannelApi.h"

@implementation KJChainChannelApi

- (instancetype)initWithResponseObject:(id)responseObject{
    if (self = [super init]) {
        NSArray * array = responseObject[@"channels"];
        NSDictionary * dict = array[arc4random() % array.count];
        self.method = KJNetworkRequestMethodGET;
        self.ip = @"https://www.douban.com";
        self.path = [@"/j/app/radio/channels?id=" stringByAppendingFormat:@"%@",dict[@"channel_id"]];
        self.responseSerializer = KJSerializerJSON;
    }
    return self;
}

@end
