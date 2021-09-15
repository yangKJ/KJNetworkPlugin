//
//  ViewController.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "ViewController.h"
#import "KJNetworkPluginManager.h"
#import "KJNetworkLoadingPlugin.h"
#import "KJNetworkManager.h"
#import "KJNetworkThiefPlugin.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.test.com";
    request.path = @"/ip(null)";
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
            request.path = @"/ip";
        }
    };
    thiefPlugin.kGetResponse = ^(KJNetworkingResponse * _Nonnull response) {
        
    };
    
    request.plugins = @[plugin, thiefPlugin];

    KJNetworkConfiguration * configuration = [KJNetworkConfiguration defaultConfiguration];
    configuration.openCapture = YES;
    
    [KJNetworkManager HTTPRequest:request configuration:configuration success:^(id  _Nonnull responseObject) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];

}


@end
