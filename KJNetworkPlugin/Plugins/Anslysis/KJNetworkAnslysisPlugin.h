//
//  KJNetworkAnslysisPlugin.h
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  解析插件
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkBasePlugin.h"

NS_ASSUME_NONNULL_BEGIN
/// 最终结果类型
typedef NS_ENUM(NSUInteger, KJNetworkAnslysisResult) {
    KJNetworkAnslysisResultObject,// 对象
    KJNetworkAnslysisResultArray, // 数组
};
@interface KJNetworkAnslysisPlugin<T: NSObject *> : KJNetworkBasePlugin

/// 模型类型，默认 [NSString class]
@property (nonatomic, strong) T clazz;
/// 验证正确code，默认1000
@property (nonatomic, assign) NSInteger code;
/// 错误消息字段名，默认 [@"message",@"msg"] 这两种
@property (nonatomic, strong) NSArray<NSString *> *errorMessage;
/// 解析出来的结果类型，默认对象 KJNetworkAnslysisResultObject
@property (nonatomic, assign) KJNetworkAnslysisResult resultType;

/// 验证结果是否正确，默认解析code属性
@property (nonatomic, copy, readonly) KJNetworkAnslysisPlugin * (^verifyCode)(BOOL(^)(id responseObject));
/// 解析出数据，默认解析出 `data`
@property (nonatomic, copy, readonly) KJNetworkAnslysisPlugin * (^anslysisJSON)(id(^)(id responseObject));

/// 映射解析数组
@property (nonatomic, copy, readonly) void(^mapArray)(void(^)(NSArray<T> * responseArray));
/// 映射解析对象，和上面映射解析数组互斥
@property (nonatomic, copy, readonly) void(^mapObject)(void(^)(T responseObject));

@end

NS_ASSUME_NONNULL_END
