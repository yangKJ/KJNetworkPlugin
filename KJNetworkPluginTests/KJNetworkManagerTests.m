//
//  KJNetworkManagerTests.m
//  KJNetworkPluginTests
//
//  Created by 77。 on 2021/8/30.
//  https://github.com/yangKJ/KJNetworkPlugin

#import <XCTest/XCTest.h>
#import "KJNetworkManager.h"

@interface KJNetworkManagerTests : XCTestCase

@end

@implementation KJNetworkManagerTests

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

// 测试下载文件资源
- (void)testDownload{
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"test download."];
    
    KJNetworkingRequest *request = [[KJNetworkingRequest alloc] init];
    request.ip = @"https://mp4.vjshi.com";
    request.path = @"/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4";
    
    KJDownloadBody *downloadBody = [[KJDownloadBody alloc] init];
    downloadBody.destination = ^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];        
        return [downloadURL URLByAppendingPathComponent:response.suggestedFilename];
    };
    downloadBody.downloadProgressWithBlock = ^(NSProgress * _Nonnull progress) {
        XCTAssertTrue(progress.completedUnitCount > 0);
        NSLog(@"Downloading: %lld / %lld -- %.2f", progress.completedUnitCount, progress.totalUnitCount, progress.completedUnitCount / (double)progress.totalUnitCount * 100);
    };
    
    KJNetworkConfiguration *configuration = [KJNetworkConfiguration defaultConfiguration];
    configuration.downloadBody = downloadBody;
    
    [KJNetworkManager HTTPRequest:request configuration:configuration success:^(id  _Nonnull responseObject) {
        NSLog(@"🎷🎷---%@",responseObject);
        [expectation fulfill];
    } failure:^(NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    }];
    
    [self waitForExpectationsWithTimeout:300 handler:nil];
}

@end
