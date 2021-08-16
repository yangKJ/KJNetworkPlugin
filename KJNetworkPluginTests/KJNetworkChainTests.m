//
//  KJNetworkChainTests.m
//  KJNetworkPluginTests
//
//  Created by 77。 on 2021/8/3.
//  https://github.com/yangKJ/KJNetworkPlugin

#import <XCTest/XCTest.h>
#import "KJNetworkChainManager.h"

@interface KJNetworkChainTests : XCTestCase

@end

@implementation KJNetworkChainTests

- (void)setUp {
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

// 测试链式网络请求
- (void)testChainNetworking{
    XCTestExpectation * expectation = [self expectationWithDescription:@"test chain."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.douban.com";
    request.path = @"/j/app/radio/channels";
    request.responseSerializer = KJSerializerJSON;
    
    [KJNetworkChainManager HTTPChainRequest:request failure:^(NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    }].chain(^__kindof KJNetworkingRequest * _Nullable(id  _Nonnull responseObject) {
        NSArray * array = responseObject[@"channels"];
        NSDictionary * dict = array[arc4random() % array.count];
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.ip = @"https://www.douban.com";
        request.path = [@"/j/app/radio/channels/channel_id=" stringByAppendingFormat:@"%@",dict[@"channel_id"]];
        request.responseSerializer = KJSerializerJSON;
        return request;
    }).lastChain(^(id  _Nonnull responseObject) {
        NSLog(@"----%@",responseObject);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:300 handler:nil];
}

// 测试不定参数方式链式网络请求
- (void)testMoreChainNetworking{
    XCTestExpectation * expectation = [self expectationWithDescription:@"test more chain."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.douban.com";
    request.path = @"/j/app/radio/channels";
    request.responseSerializer = KJSerializerJSON;
    
    [KJNetworkChainManager HTTPChainRequest:request success:^(NSArray<id> * _Nonnull responseArray) {
        NSLog(@"----%@",responseArray);
        [expectation fulfill];
    } failure:^(NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    } chain:^__kindof KJNetworkingRequest * _Nullable(id  _Nonnull responseObject) {
        NSArray * array = responseObject[@"channels"];
        NSDictionary * dict = array[arc4random() % array.count];
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.ip = @"https://www.douban.com";
        request.path = [@"/j/app/radio/channels/channel_id=" stringByAppendingFormat:@"%@",dict[@"channel_id"]];
        request.responseSerializer = KJSerializerJSON;
        return request;
    }, ^__kindof KJNetworkingRequest * _Nullable(id  _Nonnull responseObject) {
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.ip = @"https://www.douban.com";
        request.path = @"/j/app/radio/channels";
        request.responseSerializer = KJSerializerJSON;
        return request;
    }, ^__kindof KJNetworkingRequest * _Nullable(id  _Nonnull responseObject) {
        NSArray * array = responseObject[@"channels"];
        NSDictionary * dict = array[arc4random() % array.count];
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.ip = @"https://www.douban.com";
        request.path = [@"/j/app/radio/channels/channel_id=" stringByAppendingFormat:@"%@",dict[@"channel_id"]];
        request.responseSerializer = KJSerializerJSON;
        return request;
    }, nil];
    
    [self waitForExpectationsWithTimeout:300 handler:nil];
}

@end
