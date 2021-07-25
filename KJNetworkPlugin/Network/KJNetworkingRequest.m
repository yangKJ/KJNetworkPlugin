//
//  KJNetworkingRequest.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkingRequest.h"
#import "KJBaseNetworking.h"

@interface KJNetworkingRequest ()

//******************* 名字不能更改，内部kvc有使用 *******************
/// 加密参数
@property (nonatomic, strong) id secretParams;
/// 是否使用信号量，内部链式和批量使用该字段
@property (nonatomic, assign) BOOL useSemaphore;
/// 请求体标识符号，内部批量网络请求使用字段
@property (nonatomic, strong) NSString *requestIdentifier;
/// 网络请求插件时机，配合小偷插件使用效果极佳
@property (nonatomic, assign) KJNetworkingRequestOpportunity opportunity;

//*********************** 自建证书插件专属 *******************
/// 自建https证书路径
@property (nonatomic, strong) NSString *certificatePath;
/// 是否验证域名，默认yes
@property (nonatomic, assign) BOOL validatesDomainName;

//*********************** 自建证书插件专属 *******************

@end

@implementation KJNetworkingRequest

- (instancetype)init{
    if (self = [super init]) {
        self.ip = [KJBaseNetworking baseURL];
        self.requestSerializer = KJRequestSerializerHTTP;
        self.responseSerializer = KJResponseSerializerHTTP;
        self.timeoutInterval = 30.f;
        self.method = KJNetworkRequestMethodPOST;
    }
    return self;
}

- (void)setParams:(id)params{
    _params = params;
    self.secretParams = params;
}

- (NSString *)URLString{
    // 拼接完整路径
    NSCharacterSet *character = [NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<>+"].invertedSet;
    if (self.path && self.path.length > 0) {
        if (![self.path hasPrefix:@"/"]) {
            self.path = [NSString stringWithFormat:@"/%@", self.path];
        }
    }
    return [[self.ip stringByAppendingString:self.path ? self.path : @""] stringByAddingPercentEncodingWithAllowedCharacters:character];
}

@end

@implementation KJConstructingBody

@end

@implementation KJDownloadBody

@end
