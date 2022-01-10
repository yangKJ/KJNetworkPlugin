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
#import "KJNetworkPlugin-Swift.h"

@interface HomeViewController ()

@property (nonatomic, strong) UILabel * IPLabel;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    [self testPlugins];
}

- (void)setupUI{
    [self.view addSubview:self.IPLabel];
}

/// 测试加载插件和修改器插件
- (void)testPlugins{
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.test.com";
    request.path = @"/ip";
    request.timeoutInterval = 10;
    request.responseSerializer = KJSerializerJSON;
    
    KJNetworkIndicatorPlugin * indicator = [[KJNetworkIndicatorPlugin alloc] init];
    
    KJNetworkLoadingPlugin * loading = [[KJNetworkLoadingPlugin alloc] init];
    loading.displayLoading = YES;
    loading.delayHiddenLoading = 1.;
    loading.displayInWindow = NO;
    
    KJNetworkThiefPlugin * thiefPlugin = [[KJNetworkThiefPlugin alloc] init];
    thiefPlugin.maxAgainRequestCount = 2;
    thiefPlugin.againRequest = YES;
    thiefPlugin.kChangeRequest = ^(KJNetworkingRequest * _Nonnull request) {
        if (request.opportunity == KJRequestOpportunityFailure) {
            request.ip = @"https://www.httpbin.org";
        }
    };
    
    request.plugins = @[indicator, loading, thiefPlugin];

    KJNetworkConfiguration * configuration = [KJNetworkConfiguration defaultConfiguration];
    configuration.openCapture = YES;
    
    [KJNetworkManager HTTPRequest:request configuration:configuration success:^(KJNetworkComplete * complete) {
        self.IPLabel.text =  [self.IPLabel.text stringByAppendingString:complete.responseObject[@"origin"]];
    } failure:^(KJNetworkComplete * _Nonnull complete) {
        
    }];
}

#pragma mark - lazy

- (UILabel *)IPLabel{
    if (!_IPLabel) {
        _IPLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, self.view.frame.size.width - 60, 30)];
        _IPLabel.center = CGPointMake(_IPLabel.center.x, 100);
        _IPLabel.textColor = UIColor.greenColor;
        _IPLabel.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.15];
        _IPLabel.layer.cornerRadius = 5;
        _IPLabel.layer.borderWidth = 1;
        _IPLabel.layer.borderColor = UIColor.greenColor.CGColor;
        _IPLabel.layer.masksToBounds = YES;
        _IPLabel.textAlignment = NSTextAlignmentCenter;
        _IPLabel.font = [UIFont systemFontOfSize:15];
        _IPLabel.text = @"IP Address: ";
    }
    return _IPLabel;
}

@end
