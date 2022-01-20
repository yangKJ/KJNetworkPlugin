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

> + [**中文文档**](https://github.com/yangKJ/KJNetworkPlugin/blob/master/README.md)

### Network Plugin, support batch and chain operation
- Friends who are familiar with swift should know an excellent three party library [Moya](https://github.com/Moya/Moya), the plugin version of the network request is really fragrant, so I use the idea to make a pure oc version of the plugin Network request library.
- Friends who are familiar with oc should know an excellent three party library [YTKNetwork](https://github.com/yuantiku/YTKNetwork), object based protocol version network request, and then his batch network request and chain network The request is also super fragrant.
- Combining some of the advantages of the two, make a pure OC version of the batch and chain plugin version of the network request library.

### Function list
<font color=red>The plugin version of the network request can be more convenient and quick to customize the exclusive network request, and supports batch operation and chain operation.</font>

- Support basic network requests, download and upload files.
- Support configuration of general request and path, general parameters, etc.
- Support batch operation.
- Support chain network request.
- Support setting loading animation plugin.
- Support analysis result plugin.
- Support web cache plugin.
- Support configuration of self built certificate plugin.
- Support to modify the request body and get the response result plugin.
- Support network log packet capture plugin.
- Support refresh to load more plugins.
- Support error code parsing plugin.
- Support error and empty data UI display plugin.
- Support display indicator plugin.
- Support failed error prompt plugin.
- Support request parameter set secret key plugin.
- Support network data unzip and parameter zip plugin.

### Network
<details open><summary><font size=2>**KJBaseNetworking**: network request base class, based on AFNetworking package use</font></summary>

> There are also two entrances to set the common root path and common parameters, similar to: userID, token, etc.

```
/// Root path address
@property (nonatomic, strong, class) NSString *baseURL;
/// Basic parameters, similar to: userID, token, etc.
@property (nonatomic, strong, class) NSDictionary *baseParameters;
```
> Packaged methods include basic network requests, upload and download files, etc.
</details>

<details><summary><font size=2>**KJNetworkingRequest**: Request body, set network request related parameters, including parameters, request method, plug-ins, etc.</font></summary></details>

<details><summary><font size=2>**KJNetworkingResponse**: Respond to the request result, get the data generated between plugins, etc.</font></summary></details>

<details><summary><font size=2>**KJNetworkingType**: Summarize all enumerations and callback declarations</font></summary></details>

<details><summary><font size=2>**KJNetworkBasePlugin**: Plugin base class, plugin parent class</font></summary></details>

<details><summary><font size=2>**KJNetworkPluginManager**: Plugin manager, central nervous system</font></summary>

```
/// Plug-in version network request
/// @param request request body
/// @param success success callback
/// @param failure failure callback
+ (void)HTTPPluginRequest:(KJNetworkingRequest *)request success:(KJNetworkPluginSuccess)success failure:(KJNetworkPluginFailure)failure;
```
</details>

<details><summary><font size=2>**KJNetworkingDelegate**: Plugin protocol, manage network request results</font></summary>

<font color=red>**Currently, there are 5 protocol methods extracted, starting time, network request time, network success, network failure, and final return**</font>

```
/// Start preparing network request
/// @param request request related data
/// @param endRequest Whether to end the following network request
/// @return returns the data processed by the plugin
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request endRequest:(BOOL *)endRequest;

/// Request at the beginning of the network request
/// @param request request related data
/// @param stopRequest Whether to stop the network request
/// @return returns the data processed by the plugin at the start of the network request
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request stopRequest:(BOOL *)stopRequest;

/// Successfully received data
/// @param request request related data
/// @param againRequest Do you need to request the network again
/// @return returns the data processed by the successful plugin
- (KJNetworkingResponse *)succeedWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest;

/// Failure handling
/// @param request request related data
/// @param againRequest Do you need to request the network again
/// @return returns the data processed by the failed plugin
- (KJNetworkingResponse *)failureWithRequest:(KJNetworkingRequest *)request againRequest:(BOOL *)againRequest;

/// Ready to return to the business logic to call at any time
/// @param request request related data
/// @param error error message
/// @return returns the data after the final processing
- (KJNetworkingResponse *)processSuccessResponseWithRequest:(KJNetworkingRequest *)request error:(NSError **)error;
```
</details>

### Plugins collection
**There are 13 plugins available for you to use:**

- [**KJNetworkLoadingPlugin**](Docs/LOADING.md): Loading animation plugin
- [**KJNetworkAnslysisPlugin**](Docs/ANSLYSIS.md): Anslysis data plugin
- [**KJNetworkCachePlugin**](Docs/CACHE.md): Cache plugin
- [**KJNetworkCertificatePlugin**](Docs/CERTIFICATE.md): Configure certificate plugin
- [**KJNetworkThiefPlugin**](Docs/THIEF.md): Modifier plugin
- [**KJNetworkCapturePlugin**](Docs/CAPTURE.md): Network log packet capture plugin
- [**KJNetworkCodePlugin**](Docs/CODE.md): Error code analysis plugin
- [**KJNetworkRefreshPlugin**](Docs/REFRESH.md): Refresh to load more plugin
- [**KJNetworkEmptyPlugin**](Docs/EMPTY.md): Empty data UI display plugin
- [**KJNetworkIndicatorPlugin**](Docs/INDICATOR.md): Indicator plugin
- [**KJNetworkWarningPlugin**](Docs/WARNING.md): Failed error prompt plugin
- [**KJNetworkSecretPlugin**](Docs/SECRET.md): Secret key plugin
- [**KJNetworkZipPlugin**](Docs/ZIP.md): Unzip plugin

#### Chain

- Chained network requests are actually mainly used to manage network requests with interdependencies, and it can actually eventually be used to manage multiple topologically sorted network requests.

```
// Test the chained network request
- (void)testChainNetworking{
    XCTestExpectation * expectation = [self expectationWithDescription:@"test chain."];
    
    KJNetworkingRequest * request = [[KJNetworkingRequest alloc] init];
    request.method = KJNetworkRequestMethodGET;
    request.ip = @"https://www.httpbin.org";
    request.path = @"/ip";
    request.responseSerializer = KJSerializerJSON;
    
    [KJNetworkChainManager HTTPChainRequest:request failure:^(NSError *error) {
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
    .lastChain(^(id _Nonnull responseObject) {
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:300 handler:nil];
}
```

> [**More about chained plugin network processing.👒👒**](Docs/CHAIN.md)

#### Batch

- Regarding batch network requests, provide configuration information such as setting the maximum concurrent number, the number of failed calls, and the timing of error reconnection.

```
// Test batch network requests
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
    
    KJBatchConfiguration *configuration = [KJBatchConfiguration sharedBatch];
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

> [**More about batch plugin network processing.👒👒**](Docs/CHAIN.md)

### About the author
- 🎷 **E-mail address: [yangkj310@gmail.com](yangkj310@gmail.com) 🎷**
- 🎸 **GitHub address: [yangKJ](https://github.com/yangKJ) 🎸**

-----

### License

KJNetworkPlugin is available under the [MIT](LICENSE) license. See the [LICENSE](LICENSE) file for more info.
