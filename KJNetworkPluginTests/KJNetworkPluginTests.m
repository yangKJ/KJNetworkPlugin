//
//  KJNetworkPluginTests.m
//  KJNetworkPluginTests
//
//  Created by 77。 on 2021/7/24.
//

#import <XCTest/XCTest.h>
#import "KJNetworkPluginManager.h"
#import "KJNetworkThiefPlugin.h"

@interface KJNetworkPluginTests : XCTestCase

@end

@implementation KJNetworkPluginTests

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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testThiefPlugin{
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"test thief plugin."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.douban.com";
    request.path = @"/j/app/radio/channels";
    request.responseSerializer = KJSerializerJSON;
    
    KJNetworkThiefPlugin * plugin = [[KJNetworkThiefPlugin alloc] init];
    plugin.kGetResponse = ^(KJNetworkingResponse * _Nonnull response) {
        // 这里可以拿到网络请求返回的原始数据
        NSLog(@"🎷🎷🎷原汁原味的数据 = %@", response.responseObject);
    };
    request.plugins = @[plugin];
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

// 测试修改域名
- (void)testChangeIp{
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"test change ip."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.xxx.com";
    request.path = @"/j/app/radio/channels";
    request.responseSerializer = KJSerializerJSON;
    
    KJNetworkThiefPlugin * plugin = [[KJNetworkThiefPlugin alloc] init];
    plugin.againRequest = YES;
    plugin.kChangeRequest = ^(KJNetworkingRequest * _Nonnull request) {
        if (request.opportunity == KJRequestOpportunityFailure) {
            request.ip = @"https://www.douban.com";
        }
    };
    request.plugins = @[plugin];
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}


@end
