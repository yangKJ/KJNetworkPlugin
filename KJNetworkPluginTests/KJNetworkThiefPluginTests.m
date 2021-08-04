//
//  KJNetworkThiefPluginTests.m
//  KJNetworkPluginTests
//
//  Created by 77。 on 2021/8/4.
//

#import <XCTest/XCTest.h>
#import "KJNetworkPluginManager.h"
#import "KJNetworkThiefPlugin.h"

@interface KJNetworkThiefPluginTests : XCTestCase

@end

@implementation KJNetworkThiefPluginTests

- (void)setUp {
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
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
    request.ip = @"https://www.xxx";
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
    
    [self waitForExpectationsWithTimeout:300 handler:nil];
}


@end
