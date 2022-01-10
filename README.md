<p style="align: center">
<a href="https://github.com/yangKJ/KJNetworkPlugin">
<img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&color=blue"></a>
<a href="https://github.com/yangKJ/KJNetworkPlugin">
<img src="https://img.shields.io/badge/language-objective--c-blue.svg"></a>
<a href="https://cocoapods.org/pods/KJNetworkPlugin">
<img src="https://img.shields.io/cocoapods/v/KJNetworkPlugin.svg?style=flat&label=CocoaPods&colorA=28a745&&colorB=4E4E4E"></a>
<a href="https://github.com/yangKJ/KJNetworkPlugin">
<img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS-4E4E4E.svg?colorA=28a745"></a>
</p>

> + [**English Documents**](https://github.com/yangKJ/KJNetworkPlugin/blob/master/README_EN.md)

### 插件版网络请求架构，支持批量操作和链式操作
- 熟悉swift的朋友应该都知道一款优秀的三方库[Moya](https://github.com/Moya/Moya)，插件版网络请求是真香，于是乎借鉴思路制作一款纯oc版本的插件网络请求库。
- 熟悉oc的朋友又应该都知道一款优秀的三方库[YTKNetwork](https://github.com/yuantiku/YTKNetwork)，基于对象的协议版网络请求，然后他的批量网络请求和链式网络请求也超级香。
- 结合两者部分优点，制作一款纯OC版 批量 和 链式 插件版网络请求库。

### 功能清单
> + <font color=red>插件版网络请求可以更方便快捷的定制专属网络请求，并且支持批量操作，链式操作</font>

---

<img src="Docs/list.png" width="250" height="350" vspace="10px" align="right">

- 支持基本的网络请求，下载上传文件
- 支持配置通用请求跟路径，通用参数等
- 支持批量操作
- 支持链式网络请求
- 支持设置加载插件
- 支持解析结果插件
- 支持网络缓存插件
- 支持配置自建证书插件
- 支持修改请求体和获取响应结果插件
- 支持网络日志抓包插件
- 支持刷新加载更多插件
- 支持指示器插件
- 支持错误码解析插件
- 支持错误和空数据UI展示插件
- 支持错误提示插件
- 支持密钥插件
- 支持解压缩插件

---

#### Network
<details open><summary><font size=2>**KJBaseNetworking**：网络请求基类，基本的网络请求，上传下载文件等方法</font></summary>

```
/// 根路径地址
@property (nonatomic, strong, class) NSString *baseURL;
/// 基本参数，类似：userID，token等
@property (nonatomic, strong, class) NSDictionary *baseParameters;
```
</details>

<details><summary><font size=2>**KJNetworkingRequest**：请求体，设置网络请求相关参数，其中包含参数，请求方式，插件等等</font></summary></details>

<details><summary><font size=2>**KJNetworkingResponse**：响应请求结果，获取插件之间产生的数据等等</font></summary></details>

<details><summary><font size=2>**KJNetworkingType**：汇总所有枚举和回调声明</font></summary></details>

<details><summary><font size=2>**KJNetworkBasePlugin**：插件基类，插件父类</font></summary></details>

<details><summary><font size=2>**KJNetworkPluginManager**：插件管理器，中枢神经</font></summary>

```
/// 插件版网络请求
/// @param request 请求体
/// @param success 成功回调
/// @param failure 失败回调
+ (void)HTTPPluginRequest:(KJNetworkingRequest *)request
                  success:(KJNetworkPluginSuccess)success 
                  failure:(KJNetworkPluginFailure)failure;
```
</details>

<details><summary><font size=2>**KJNetworkingDelegate**：插件协议，管理网络请求结果</font></summary>

<font color=red>**目前抽离出5条协议方法，开始时刻、网络请求时刻、网络成功、网络失败、最终返回**</font>

```
/// 开始准备网络请求
/// @param request 请求相关数据
/// @param endRequest 是否结束下面的网络请求
/// @return 返回准备插件处理后的数据
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request endRequest:(BOOL *)endRequest;

/// 网络请求开始时刻请求
/// @param request 请求相关数据
/// @param stopRequest 是否停止网络请求
/// @return 返回网络请求开始时刻插件处理后的数据
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request stopRequest:(BOOL *)stopRequest;

/// 成功接收数据
/// @param request 请求相关数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回成功插件处理后的数据
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest;

/// 失败处理
/// @param request 请求相关数据
/// @param againRequest 是否需要再次请求该网络
/// @return 返回失败插件处理后的数据
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest;

/// 准备返回给业务逻辑时刻调用
/// @param request 请求相关数据
/// @param error 错误信息
/// @return 返回最终加工之后的数据
- (KJNetworkingResponse *)processSuccessResponseWithRequest:(KJNetworkingRequest *)request error:(NSError **)error;
```
</details>

#### Plugins
目前已有13款插件供使用：

- [**KJNetworkLoadingPlugin**](Docs/LOADING.md)：加载动画插件
- [**KJNetworkAnslysisPlugin**](Docs/ANSLYSIS.md)：解析数据插件
- [**KJNetworkCachePlugin**](Docs/CACHE.md)：网络缓存插件
- [**KJNetworkCertificatePlugin**](Docs/CERTIFICATE.md)：配置自建证书插件
- [**KJNetworkThiefPlugin**](Docs/THIEF.md)：修改器插件
- [**KJNetworkCapturePlugin**](Docs/CAPTURE.md)：网络日志抓包插件
- [**KJNetworkCodePlugin**](Docs/CODE.md)：错误码解析插件
- [**KJNetworkRefreshPlugin**](Docs/REFRESH.md)：刷新加载更多插件
- [**KJNetworkEmptyPlugin**](Docs/EMPTY.md)：错误和空数据UI展示插件
- [**KJNetworkIndicatorPlugin**](Docs/INDICATOR.md)：指示器插件
- [**KJNetworkWarningPlugin**](Docs/WARNING.md)：错误提示插件
- [**KJNetworkSecretPlugin**](Docs/SECRET.md)：密钥插件
- [**KJNetworkZipPlugin**](Docs/ZIP.md)：解压缩插件

----

#### Chain

- 链式网络请求其实主要用于管理有相互依赖的网络请求，它实际上最终可以用来管理多个拓扑排序后的网络请求。

```
// 测试链式网络请求
- (void)testChainNetworking{
    XCTestExpectation * expectation = [self expectationWithDescription:@"test chain."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.httpbin.org";
    request.path = @"/ip";
    request.responseSerializer = KJSerializerJSON;
    
    [KJNetworkChainManager HTTPChainRequest:request failure:^(NSError * error) {
        XCTFail(@"%@", error.localizedDescription);
    }]
    .chain(^__kindof KJNetworkingRequest * _Nullable(id _Nonnull responseObject) {
        KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
        request.ip = @"https://www.httpbin.org";
        request.path = @"/post";
        request.params = {
            "ip": responseObject["origin"]
        };
        return request;
    })
    .lastChain(^(id  _Nonnull responseObject) {
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:300 handler:nil];
}
```

> [**更多关于链式插件网络处理.👒👒**](Docs/CHAIN.md)

#### Batch

- 关于批量网络请求，提供设置最大并发数量，失败调用次数，错误重连时机等配置信息

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
    }
    
    KJBatchConfiguration * configuration = [KJBatchConfiguration sharedBatch];
    configuration.maxQueue = 3;
    configuration.requestArray = array.mutableCopy;
    
    [KJNetworkBatchManager HTTPBatchRequestConfiguration:configuration reconnect:^BOOL(NSArray<KJNetworkingRequest *> * _Nonnull reconnectArray) {
        return YES;
    } complete:^(NSArray<KJBatchResponse *> * _Nonnull result) {
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:300 handler:nil];
}
```

> [**更多关于批量插件网络处理.👒👒**](Docs/CHAIN.md)

### 关于作者
- 🎷 **邮箱地址：[ykj310@126.com](ykj310@126.com) 🎷**
- 🎸 **GitHub地址：[yangKJ](https://github.com/yangKJ) 🎸**
- 🎺 **掘金地址：[茶底世界之下](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻 **简书地址：[77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

#### 救救孩子吧，谢谢各位老板～～～～

-----
