//
//  KJNetworkPluginTests.m
//  KJNetworkPluginTests
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import <XCTest/XCTest.h>
#import "KJNetworkPluginManager.h"
#import <MJExtension/MJExtension.h>

@interface KJNetworkPluginTests : XCTestCase

@end

@implementation KJNetworkPluginTests

- (void)setUp {
    KJBaseNetworking.openLog = NO;
    KJBaseNetworking.baseURL = @"https://www.httpbin.org";
    KJBaseNetworking.baseParameters = @{
        @"param1":@"value1",
        @"param2":@"value2"
    };
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testGet{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Post request"];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.path = @"/ip";
    request.responseSerializer = KJSerializerJSON;
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
        XCTAssertNotNil(responseObject, @"data should not be nil");
        
        NSString *origin = responseObject[@"origin"];
        XCTAssertNotNil(origin);
        
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        XCTAssertNil(error, @"error should be nil");
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:30];

}

- (void)testPost{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Post request"];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodPOST;
    request.path = @"/post";
    request.params = @{@"param1":@"value1"};
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
        XCTAssertNotNil(responseObject, @"data should not be nil");
        
        NSDictionary *dic = [responseObject mj_JSONObject];
        XCTAssertNotNil(dic, @"data should parse to dictionary success");
        
        NSDictionary *args = dic[@"form"];
        XCTAssertNotNil(args);
        
        NSString *value1 = args[@"param1"];
        XCTAssertEqualObjects(value1, @"value1");
        
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        XCTAssertNil(error, @"error should be nil");
        [expectation fulfill];
    }];
    [self waitForExpectations:@[expectation] timeout:30];
}

@end
