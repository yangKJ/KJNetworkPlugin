//
//  KJNetworkOtherTests.m
//  KJNetworkPluginTests
//
//  Created by yangkejun on 2021/8/16.
//  https://github.com/yangKJ/KJNetworkPlugin

#import <XCTest/XCTest.h>
#import "KJNetworkPluginManager.h"

@interface KJNetworkOtherTests : XCTestCase

@end

@implementation KJNetworkOtherTests

- (void)setUp {
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

/// 获取波场 `TRC20` 代币余额
- (void)testTronTRC20Amount{
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"TRON TRC20"];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.ip = @"https://api.trongrid.io";
    request.path = @"/wallet/triggersmartcontract";
    request.params = @{
        @"contract_address": @"",
        @"function_selector": @"",
        @"call_value": @(0),
        @"parameter": @"",
        @"fee_limit": @(0),
        @"owner_address": @"",
        @"visible": @(1)
    };
    request.requestSerializer = KJSerializerJSON;
    request.responseSerializer = KJSerializerJSON;
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * request, id responseObject) {
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        [expectation fulfill];
    }];
    
    [self waitForExpectations:@[expectation] timeout:300];
}

@end
