//
//  HomeViewController.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

//  ****************************************************
//  更多插件使用技巧，请查看测试用例 `KJNetworkPluginTests`
//  ****************************************************

#import "HomeViewController.h"
#import "KJNetworkPluginManager.h"
#import "KJNetworkLoadingPlugin.h"
#import "KJNetworkManager.h"
#import "KJNetworkThiefPlugin.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self testLoadingAndThief];
}

/// 测试加载插件和修改器插件
- (void)testLoadingAndThief{
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.test.com";
    request.path = @"/ip";
    request.responseSerializer = KJSerializerJSON;
    
    KJNetworkLoadingPlugin * plugin = [[KJNetworkLoadingPlugin alloc] init];
    plugin.displayLoading = YES;
    plugin.displayErrorMessage = YES;
    plugin.delayHiddenLoading = 2.5;
    plugin.displayInWindow = NO;
    
    KJNetworkThiefPlugin * thiefPlugin = [[KJNetworkThiefPlugin alloc] init];
    thiefPlugin.maxAgainRequestCount = 2;
    thiefPlugin.againRequest = YES;
    thiefPlugin.kChangeRequest = ^(KJNetworkingRequest * _Nonnull request) {
        if (request.opportunity == KJRequestOpportunityFailure) {
            request.ip = @"https://www.httpbin.org";
        }
    };
    thiefPlugin.kGetResponse = ^(KJNetworkingResponse * _Nonnull response) {
        
    };
    
    request.plugins = @[plugin, thiefPlugin];

    KJNetworkConfiguration * configuration = [KJNetworkConfiguration defaultConfiguration];
    configuration.openCapture = YES;
    
    [KJNetworkManager HTTPRequest:request configuration:configuration success:^(KJNetworkComplete * complete) {
        
    } failure:^(KJNetworkComplete * _Nonnull complete) {
        
    }];
}

@end
