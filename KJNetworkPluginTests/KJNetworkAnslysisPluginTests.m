//
//  KJNetworkAnslysisPluginTests.m
//  KJNetworkPluginTests
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import <XCTest/XCTest.h>
#import "KJNetworkPluginManager.h"
#import "KJNetworkAnslysisPlugin.h"
#import "KJAnslysisModel.h"

@interface KJNetworkAnslysisPluginTests : XCTestCase

@end

@implementation KJNetworkAnslysisPluginTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

// 测试解析插件
- (void)testAnslysisPlugin{
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"test anslysis plugin."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.douban.com";
    request.path = @"/j/app/radio/channels";
    request.responseSerializer = KJSerializerJSON;
    
    KJNetworkAnslysisPlugin * plugin = [[KJNetworkAnslysisPlugin alloc] init];
    plugin.clazz = [[KJAnslysisModel alloc] init];
//    plugin.resultType = KJNetworkAnslysisResultArray;
    plugin.verifyCode(^BOOL(id  _Nonnull responseObject) {
        return [responseObject[@"channels"] count] ? YES : NO;
    }).anslysisJSON(^id _Nonnull(id  _Nonnull responseObject) {
        return responseObject[@"channels"];
    }).mapArray(^(NSArray<KJAnslysisModel *> * _Nonnull responseArray) {
        NSLog(@"\n🎷🎷🎷----%@",responseArray);
    });
    
    request.plugins = @[plugin];
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];

}

@end
