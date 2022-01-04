//
//  KJNetworkAnslysisPlugin.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkAnslysisPlugin.h"
#import <MJExtension/MJExtension.h>

@interface KJNetworkAnslysisPlugin ()

@property (nonatomic, strong) Class modelType;
@property (nonatomic, strong) NSArray<NSString *> *messages;
@property (nonatomic, copy, readwrite) BOOL(^verify)(id responseObject);
@property (nonatomic, copy, readwrite) id(^anslysis)(id responseObject);
@property (nonatomic, copy, readwrite) void(^mapArrayBlock)(NSArray<__kindof NSObject *> * responseArray);
@property (nonatomic, copy, readwrite) void(^mapObjectBlock)(__kindof NSObject * responseObject);

@end

@implementation KJNetworkAnslysisPlugin

- (instancetype)init{
    if (self = [super init]) {
        self.resultType = KJNetworkAnslysisResultObject;
        self.modelType = [NSString class];
        self.messages = @[@"message",@"msg"];
        self.code = 1000;
    }
    return self;
}

- (void)setClazz:(NSObject *)clazz{
    _clazz = clazz;
    self.modelType = [clazz class];
}

- (void)setErrorMessage:(NSArray<NSString *> *)errorMessage{
    _errorMessage = errorMessage;
    NSMutableSet * set = [NSMutableSet setWithArray:errorMessage];
    [set addObjectsFromArray:self.messages];
    self.messages = [set allObjects];
}

/// 准备返回给业务逻辑时刻调用
/// @param request 请求相关数据
/// @param error 错误信息
/// @return 返回最终加工之后的数据
- (KJNetworkingResponse *)processSuccessResponseWithRequest:(KJNetworkingRequest *)request error:(NSError **)error{
    [super processSuccessResponseWithRequest:request error:error];
    id result = [[self.response valueForKey:@"tempResponse"] mj_JSONObject];
    BOOL verify = NO;
    id data = [self anslysisDataWithresult:result verifyCode:&verify];
    if (verify) {
        id response = [self anslysisResultWithJson:data];
        [self.response setValue:response forKey:@"processResponse"];
    } else {
        NSString * description = @"code analysis error.";
        NSInteger code = -200;
        if ([result isKindOfClass:[NSDictionary class]]) {
            code = [result[@"code"] integerValue];
            for (NSString * key in self.messages) {
                if (kMapDictionaryContainsKey(result, key)) {
                    description = result[key];
                    break;
                }
            }
        } else {
            description = @"result not is dictionary.";
        }
        * error = [NSError errorWithDomain:@"kj.anslysis.plugin"
                                      code:code
                                  userInfo:@{NSLocalizedDescriptionKey: description}];
    }
    
    return self.response;
}

/// 判断是否有实现验证回调 和 解析回调
- (id)anslysisDataWithresult:(__unused id)result verifyCode:(BOOL *)verify{
    if (self.verify) { } else {
        self.verify = ^BOOL(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                int code = [[((NSDictionary *)responseObject) valueForKey:@"code"] intValue];
                return code == self.code ? YES : NO;
            }
            return NO;
        };
    }
    if (self.anslysis) { } else {
        self.anslysis = ^id(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                return [((NSDictionary *)responseObject) valueForKey:@"data"];
            }
            return responseObject;
        };
    }
    if (self.verify(result)) {
        * verify = YES;
        return self.anslysis(result);
    }
    return result;
}

/// 解析数据结果
- (id)anslysisResultWithJson:(__unused id)json{
    if (self.mapObjectBlock) {
        id response = [self.modelType mj_objectWithKeyValues:json];
        self.mapObjectBlock(response);
        return response;
    }
    if (self.mapArrayBlock) {
        id response = [self.modelType mj_objectArrayWithKeyValuesArray:json];
        self.mapArrayBlock(response);
        return response;
    }
    id result = nil;
    switch (self.resultType) {
        case KJNetworkAnslysisResultObject:
            result = [self.modelType mj_objectWithKeyValues:json];
            break;
        case KJNetworkAnslysisResultArray:
            result = [self.modelType mj_objectArrayWithKeyValuesArray:json];
            break;
        default:
            break;
    }
    return result;
}

/// 字典是否包含某个键
NS_INLINE BOOL kMapDictionaryContainsKey(NSDictionary * dict, NSString * key){
    if (!key) return NO;
    return [dict.allKeys containsObject:key];
}

#pragma mark - lazy

- (KJNetworkAnslysisPlugin * _Nonnull (^)(BOOL (^ _Nonnull)(id _Nonnull)))verifyCode{
    return ^(BOOL (^verify)(id _Nonnull)){
        self.verify = verify;
        return self;
    };
}

- (KJNetworkAnslysisPlugin * _Nonnull (^)(id  _Nonnull (^ _Nonnull)(id _Nonnull)))anslysisJSON{
    return ^(id  _Nonnull (^anslysis)(id _Nonnull)){
        self.anslysis = anslysis;
        return self;
    };
}

- (void (^)(void (^ _Nonnull)(NSArray<NSObject *> * _Nonnull)))mapArray{
    return ^(void (^block)(NSArray<NSObject *> * _Nonnull)){
        self.mapArrayBlock = block;
    };
}

- (void (^)(void (^ _Nonnull)(NSObject *)))mapObject{
    return ^(void (^block)(NSObject *)){
        self.mapObjectBlock = block;
    };
}

@end
