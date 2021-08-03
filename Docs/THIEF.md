# KJNetworkThiefPlugin

这里主要介绍关于**KJNetworkThiefPlugin**插件的简单使用教程和骚操作，下面直接步入正题。

### 插件网络使用示例
- **实例化请求体**

设置请求ip，路径，参数，请求方式，插件等等等

```
KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
request.method = KJNetworkRequestMethodGET;
request.ip = @"https://www.douban.com";
request.path = @"/j/app/radio/channels";

```

- **实例化此次网络需要的插件**

设置需求插件plugins

```
KJNetworkThiefPlugin * plugin = [[KJNetworkThiefPlugin alloc] init];
request.plugins = @[plugin];
```

- **开启插件版网络调用**

就是这么简单简洁的使用，

```
[KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
    NSLog(@"----%@",responseObject);
} failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
    NSLog(@"----%@",error);
}];
```
> 到此，小偷插件使用就算初步完成，是不是特别轻松简单，so easy.

-----

> 下面继续接着奏乐接着舞，

### 修改请求体

```
KJNetworkThiefPlugin * plugin = [[KJNetworkThiefPlugin alloc] init];
plugin.kChangeRequest = ^(KJNetworkingRequest * _Nonnull request) {
    
    // 这里即可修改请求体，这里需要提醒一下
    // 此处修改会影响后续网络请求，也就是说会改变你上面设置的`request`
    
};
```

> 其实一般情况下，我们不会去更改请求体，毕竟前面已设置请求体，当然这个也可以拿来做点骚操作，后面再慢慢讲，咱先一步一步来

### 获取插件数据

```
plugin.kGetResponse = ^(KJNetworkingResponse * _Nonnull response) {
    
    // 这里可以拿到网络请求返回的原始数据
    NSLog(@"🎷🎷🎷原汁原味的数据 = %@", response.responseObject);

    // 准备插件处理之后的数据
    if (response.opportunity == KJNetworkingRequestOpportunityPrepare) {
        NSLog(@"🎷🎷🎷准备插件处理之后的数据 = %@", response.prepareResponse);
    }
    
    // 成功插件处理之后的数据
    if (response.opportunity == KJNetworkingRequestOpportunitySuccess) {
        NSLog(@"🎷🎷🎷成功插件处理之后的数据 = %@", response.successResponse);
    }
    
    // 失败插件处理之后的数据
    if (response.opportunity == KJNetworkingRequestOpportunityFailure) {
        NSLog(@"🎷🎷🎷失败插件处理之后的数据 = %@", response.failureResponse);
        NSLog(@"🎷🎷🎷失败 = %@", response.error);
    }
    
};
```

> 备注说明：如果你使用的插件没有处理过成功数据或者失败数据，甚至任何一个插件数据，只要未经插件处理过，那么对应的该插件数据即为空，不必大惊小怪

### 失败之后更改请求体
不知道大家在使用的过程中，有没有遇见这样的情况：

- **场景一**：通常情况下我们的默认域名都是同一个，但是有的时候也会出现这样的场景，常规操作之下使用默认域名，如果失败则换另外的备用域名
- **场景二**：网络请求第一次失败之后，更换另外一套网络接口

```
KJNetworkThiefPlugin * plugin = [[KJNetworkThiefPlugin alloc] init];
// 该字段必须开启，才会再次调用网络请求
plugin.againRequest = YES;
plugin.kChangeRequest = ^(KJNetworkingRequest * _Nonnull request) {
    
    // 场景一，失败之后更换ip
    if (request.opportunity == KJNetworkingRequestOpportunityFailure) {
        request.ip = @"https://www.baidu.com";
    }
    
    // 场景二，失败之后更换另外一套网络接口
    if (request.opportunity == KJNetworkingRequestOpportunityFailure) {
        request.path = @"/other/path";
        request.params = @{
            @"token": @"XHFI-213-XDJHso-A0345",
            @"userid": @"likeyou",
        };
    }
};
```
> 我觉得还有更多骚操作，可以玩一下，待发现ing..

### 多插件时刻获取插件数据
插件版网络就是有这样一个弊端，最终成功或者失败回调出来的数据都是最后一个插件处理之后的数据，那么如果我想拿到中间某个插件处理之后的数据，常规的方法就不行，于是就诞生下面这种骚操作来满足这些无理取闹的需求

```
KJNetworkCachePlugin * cache = [[KJNetworkCachePlugin alloc] init];
...
缓存插件相关操作

KJNetworkThiefPlugin * afterCache = [[KJNetworkThiefPlugin alloc] init];
afterCache.kGetResponse = ^(KJNetworkingResponse * _Nonnull response) {
    // 获取缓存插件处理后的数据
};
    
KJNetworkAnslysisPlugin * anslysis = [[KJNetworkAnslysisPlugin alloc] init];
... 
解析插件相关操作

KJNetworkThiefPlugin * afterAnslysis = [[KJNetworkThiefPlugin alloc] init];
afterAnslysis.kGetResponse = ^(KJNetworkingResponse * _Nonnull response) {
    // 获取解析插件处理后的数据
};

// 这里设置好对应插件顺序即可    
request.plugins = @[cache, afterCache, anslysis, afterAnslysis];

```
> 我依然觉得还有更多用法待发现，去吧！皮卡丘

### 完整测试用例
提供完整的测试用例，自己去玩吧

```
- (void)testThiefPlugin{
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"test thief plugin."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.douban.com";
    request.path = @"/j/app/radio/channels";
    request.responseSerializer = KJResponseSerializerJSON;
    
    KJNetworkThiefPlugin * plugin = [[KJNetworkThiefPlugin alloc] init];
    plugin.kGetResponse = ^(KJNetworkingResponse * _Nonnull response) {
        // 这里可以拿到网络请求返回的原始数据
        NSLog(@"🎷🎷🎷原汁原味的数据 = %@", response.responseObject);
    };
    request.plugins = @[plugin];
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

// 测试修改域名
- (void)testChangeIp{
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"test change ip."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.xxx.com";
    request.path = @"/j/app/radio/channels";
    request.responseSerializer = KJResponseSerializerJSON;
    
    KJNetworkThiefPlugin * plugin = [[KJNetworkThiefPlugin alloc] init];
    plugin.againRequest = YES;
    plugin.kChangeRequest = ^(KJNetworkingRequest * _Nonnull request) {
        if (request.opportunity == KJNetworkingRequestOpportunityFailure) {
            request.ip = @"https://www.douban.com";
        }
    };
    request.plugins = @[plugin];
    
    [KJNetworkPluginManager HTTPPluginRequest:request success:^(KJNetworkingRequest * _Nonnull request, id  _Nonnull responseObject) {
        [expectation fulfill];
    } failure:^(KJNetworkingRequest * _Nonnull request, NSError * _Nonnull error) {
        XCTFail(@"%@", error.localizedDescription);
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
}
```

### Cocoapods使用

```
pod 'KJNetworkPlugin/Thief' # 偷梁换柱插件
```

### 关于作者
- 🎷**邮箱地址：[ykj310@126.com](ykj310@126.com) 🎷**
- 🎸**GitHub地址：[yangKJ](https://github.com/yangKJ) 🎸**
- 🎺**掘金地址：[茶底世界之下](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻**简书地址：[77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

#### 救救孩子吧，谢谢各位老板～～～～

-----
