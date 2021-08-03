# 链式网络使用教程

链式网络请求其实主要用于管理有相互依赖的网络请求，它实际上最终可以用来管理多个拓扑排序后的网络请求。

例如，我们有一个需求，需要用户先发送注册Api，然后获取用户信息Api，最后再获取用户id等信息。

### 链式插件方案

- 方案1：采用自定义参数方式处理

```
/// 链式网络请求
/// @param request 请求体系
/// @param success 全部成功回调，存放请求所有结果数据
/// @param failure 失败回调，只要一个失败就会响应
/// @param chain 链式回调，返回下个网络请求体，为空时即可结束后续请求，responseObject上个网络请求响应数据
+ (void)HTTPChainRequest:(__kindof KJNetworkingRequest *)request
                 success:(KJNetworkChainSuccess)success
                 failure:(KJNetworkChainFailure)failure
                   chain:(KJNetworkNextChainRequest)chain,...;
```

- 方案2：采用链式闭包方式处理

```
/// 链式网络请求，需 `chain` 和 `lastchain` 配合使用
/// @param request 请求体系
/// @param failure 失败回调，只要一个失败就会响应
/// @return 返回自身对象
+ (instancetype)HTTPChainRequest:(__kindof KJNetworkingRequest *)request failure:(KJNetworkChainFailure)failure;
/// 请求体传递载体，回调返回上一个网络请求结果
@property (nonatomic, copy, readonly) KJNetworkChainManager * (^chain)(KJNetworkNextChainRequest);
/// 最后链数据回调，回调最后一个网络请求结果
@property (nonatomic, copy, readonly) void(^lastChain)(void(^)(id responseObject));
```

### 使用教程

- **方案1：采用不定参数方式处理**

**使用说明：**

实例化第一个网络请求体`request`，获取到数据回调在**chain**，然后解析**return**给第二个网络请求体`request`，然后依次类推，最终以**`nil`**结尾即可。

**success回调：**可拿到全部网络响应数据，目录和请求顺序一致  
**failure回调：**只要当中某一个网络失败，即响应失败

**测试用例：**

```
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
```

- **方案2：采用链式闭包方式处理**

**使用说明：**

实例化第一个网络请求体`request`，然后通过链式闭包方式**chain**获取到上一个响应结果，然后**return**第二个网络请求体`request`，依次类推，最后一个网络请求响应结果则通过**lastChain**获取`responseObject `即可。

**failure回调：**只要当中某一个网络失败，即响应失败

**测试用例：**

```
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
```

> 大致介绍就差不多这么多吧，其实这类网络使用一般都是在个人中心

### Cocoapods安装
```
pod 'KJNetworkPlugin/Chain'
```

### 关于作者
- 🎷**邮箱地址：[ykj310@126.com](ykj310@126.com) 🎷**
- 🎸**GitHub地址：[yangKJ](https://github.com/yangKJ) 🎸**
- 🎺**掘金地址：[茶底世界之下](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻**简书地址：[77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

#### 救救孩子吧，谢谢各位老板～～～～

-----
