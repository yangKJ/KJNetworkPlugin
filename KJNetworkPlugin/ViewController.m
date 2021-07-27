//
//  ViewController.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//

#import "ViewController.h"
#import "KJNetworkPluginManager.h"
#import "KJNetworkLoadingPlugin.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.douban.com";
    request.responseSerializer = KJResponseSerializerJSON;
    
    KJNetworkLoadingPlugin * plugin = [[KJNetworkLoadingPlugin alloc] init];
    plugin.displayLoading = YES;
    plugin.displayErrorMessage = YES;
    request.plugins = @[plugin];
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
        
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        
    }];

}


@end
