//
//  KJNetworkCertificatePluginTests.m
//  KJNetworkPluginTests
//
//  Created by 77。 on 2021/7/25.
//

#import <XCTest/XCTest.h>
#import "KJNetworkPluginManager.h"
#import "KJNetworkCertificatePlugin.h"

@interface KJNetworkCertificatePluginTests : XCTestCase

@end

@implementation KJNetworkCertificatePluginTests

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

// 测试自建证书插件
- (void)testCertificatePlugin{
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"test certificate plugin."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.douban.com";
    request.path = @"/j/app/radio/channels";
    request.responseSerializer = KJSerializerJSON;
    
    KJNetworkCertificatePlugin * plugin = [[KJNetworkCertificatePlugin alloc] init];
    plugin.certificatePath = @"/test/path";
    request.plugins = @[plugin];
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    }];

    [self waitForExpectationsWithTimeout:300 handler:nil];
    
}

@end
