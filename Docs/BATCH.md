# 批量网络使用教程

关于批量网络请求，平时使用的场景是非常之多，于是乎就封装该批量插件版网络请求，下面介绍一下使用技巧。

**这里主要分为两个大类：**

- **KJBatchConfiguration：**配置文件，这里包括网络请求最大并发数，最大失败重连次数，失败重连时机和批量网络请求体

```
/// 设置网络并发最大数量，默认5条
@property (nonatomic, assign) NSInteger maxQueue;
/// 设置最大失败重调次数，默认3次
@property (nonatomic, assign) NSInteger againCount;
/// 网络连接失败重连时机，默认 KJBatchReRequestOpportunityNone
@property (nonatomic, assign) KJBatchReRequestOpportunity opportunity;
/// 批量请求体，
@property (nonatomic, strong) NSArray<__kindof KJNetworkingRequest *> * requestArray;
```

- **KJNetworkBatchManager：**批量网络请求管理器

### API说明

批量插件网络请求，这里提供设置最大并发数量，失败调用次数，错误重连时机等配置信息

```
/// 批量网络请求
/// @param configuration 批量请求配置信息
/// @param reconnect 网络请求失败时候回调，返回YES再次继续批量处理
/// @param complete 最终结果回调，返回成功和失败数据数组
+ (void)HTTPBatchRequestConfiguration:(KJBatchConfiguration *)configuration
                            reconnect:(KJNetworkBatchReconnect)reconnect
                             complete:(KJNetworkBatchComplete)complete;
```

### 测试用例
实例化设置配置文件`KJBatchConfiguration`，然后传入我们需要批量操作的请求体`request`，批量结果显示在**complete**回调。

关于reconnect回调，这里说明一下，存在失败网络时刻，会先记录下来然后回调出来，**`retuen yes`**则再次请求失败的网络。

```
// 测试批量网络请求
- (void)testBatchNetworking{
    XCTestExpectation * expectation = [self expectationWithDescription:@"test batch."];
    
    NSMutableArray * array = [NSMutableArray array];
    {
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.path = @"/headers";
        request.responseSerializer = KJSerializerJSON;
        [array addObject:request];
    }{
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.path = @"/ip";
        [array addObject:request];
    }{
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.path = @"/user-agent";
        [array addObject:request];
    }{
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.path = @"/bearer";
        request.responseSerializer = KJSerializerJSON;
        [array addObject:request];
    }{
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.method = KJNetworkRequestMethodGET;
        request.path = @"/cache";
        request.responseSerializer = KJSerializerJSON;
        [array addObject:request];
    }
    
    KJBatchConfiguration * configuration = [KJBatchConfiguration sharedBatch];
    configuration.maxQueue = 3;
    configuration.requestArray = array.mutableCopy;
    
    [KJNetworkBatchManager HTTPBatchRequestConfiguration:configuration reconnect:^BOOL(NSArray<KJNetworkingRequest *> * _Nonnull reconnectArray) {
        return YES;
    } complete:^(NSArray<KJBatchResponse *> * _Nonnull result) {
        NSLog(@"----%@",result);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:300 handler:nil];
}
```

> 具体使用，可以下载Demo查看测试用例

### Cocoapods安装
```
pod 'KJNetworkPlugin/Batch' # 批量插件版网络请求
```

### 关于作者
- 🎷**邮箱地址：[ykj310@126.com](ykj310@126.com) 🎷**
- 🎸**GitHub地址：[yangKJ](https://github.com/yangKJ) 🎸**
- 🎺**掘金地址：[茶底世界之下](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻**简书地址：[77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

#### 救救孩子吧，谢谢各位老板～～～～

-----
