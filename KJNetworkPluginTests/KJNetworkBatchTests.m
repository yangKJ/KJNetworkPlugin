//
//  KJNetworkBatchTests.m
//  KJNetworkPluginTests
//
//  Created by 77。 on 2021/8/3.
//

#import <XCTest/XCTest.h>
#import "KJNetworkBatchManager.h"

@interface KJNetworkBatchTests : XCTestCase

@end

@implementation KJNetworkBatchTests

- (void)setUp {
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

// 测试批量网络请求
- (void)testBatchNetworking{
    XCTestExpectation * expectation = [self expectationWithDescription:@"test batch."];
    
    NSMutableArray * array = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.ip = @"https://www.douban.com";
        request.path = @"/j/app/radio/channels";
        request.responseSerializer = KJSerializerJSON;
        [array addObject:request];
    }
    
    KJBatchConfiguration * configuration = [KJBatchConfiguration sharedBatch];
    configuration.maxQueue = 5;
    configuration.requestArray = array.mutableCopy;
    
    [KJNetworkBatchManager HTTPBatchRequestConfiguration:configuration reconnect:^BOOL(NSArray<KJNetworkingRequest *> * _Nonnull reconnectArray) {
        return YES;
    } complete:^(NSArray<KJBatchResponse *> * _Nonnull result) {
        NSLog(@"----%@",result);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:300 handler:nil];
}

@end
