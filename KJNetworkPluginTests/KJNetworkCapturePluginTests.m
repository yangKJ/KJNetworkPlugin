//
//  KJNetworkCapturePluginTests.m
//  KJNetworkPluginTests
//
//  Created by yangkejun on 2021/8/31.
//  https://github.com/yangKJ/KJNetworkPlugin

#import <XCTest/XCTest.h>
#import "KJNetworkManager.h"
#import "KJNetworkCapturePlugin.h"
#import "KJNetworkPluginManager.h"

@interface KJNetworkCapturePluginTests : XCTestCase

@end

@implementation KJNetworkCapturePluginTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    KJBaseNetworking.baseParameters = @{
        @"key" : @"value"
    };
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

// 测试抓包插件
- (void)testCapturePlugin{
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"test capture plugin."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.path = @"/ip";
    request.responseSerializer = KJSerializerJSON;
    
    KJNetworkCapturePlugin * plugin = [KJNetworkCapturePlugin sharedInstance];
    plugin.openLog = YES;
    request.plugins = @[plugin];
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * request, id responseObject) {
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
    
}

// 测试默认携带抓包插件
- (void)testDefaultCapturePlugin{
    XCTestExpectation * expectation = [self expectationWithDescription:@"test default capture plugin."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.path = @"/headers";
    request.responseSerializer = KJSerializerJSON;
    
    [KJNetworkManager HTTPRequest:request configuration:nil success:^(KJNetworkComplete * complete) {
        [expectation fulfill];
    } failure:^(KJNetworkComplete * _Nonnull complete) {
        XCTFail(@"%@", complete.error.localizedDescription);
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
    
}

// 读取抓包数据
- (void)testReadCapture{
    XCTestExpectation * expectation = [self expectationWithDescription:@"test read capture data."];
    
    [KJNetworkCapturePlugin readAllLogComplete:^(NSArray<KJCaptureResponse *> * _Nonnull logs) {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
