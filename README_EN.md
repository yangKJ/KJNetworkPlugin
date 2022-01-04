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

### Plug-in network, support batch and chain operation
- Friends who are familiar with swift should know an excellent three-party library [Moya](https://github.com/Moya/Moya), the plug-in version of the network request is really fragrant, so I use the idea to make a pure oc version of the plug-in Network request library.
- Friends who are familiar with oc should know an excellent three-party library [YTKNetwork](https://github.com/yuantiku/YTKNetwork), object-based protocol version network request, and then his batch network request and chain network The request is also super fragrant.
- Combining some of the advantages of the two, make a pure OC version of the batch and chain plug-in version of the network request library.

### Function list
> + <font color=red>The plug-in version of the network request can be more convenient and quick to customize the exclusive network request, and supports batch operation and chain operation.</font>

- Support basic network requests, download and upload files
- Support configuration of general request and path, general parameters, etc.
- Support setting loading and prompt box plugin
- Support analysis result plug-in
- Support web cache plugin
- Support configuration of self-built certificate plug-in
- Support to modify the request body and get the response result plug-in
- Support network log packet capture plugin
- Support refresh to load more plugins
- Support error code parsing plugin
- Support error and empty data UI display plugin
- Support batch operation
- Support chain network request

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

<details><summary><font size=2>**KJNetworkingRequest**: Request body, set network request related parameters, including parameters, request method, plug-ins, etc.</font></summary>
</details>

<details><summary><font size=2>**KJNetworkingResponse**: Respond to the request result, get the data generated between plug-ins, etc.</font></summary>
</details>

<details><summary><font size=2>**KJNetworkingType**: Summarize all enumerations and callback declarations</font></summary>
</details>

<details><summary><font size=2>**KJNetworkBasePlugin**: plug-in base class, plug-in parent class</font></summary>
</details>

<details><summary><font size=2>**KJNetworkPluginManager**: Plug-in manager, central nervous system</font></summary>

```
/// Plug-in version network request
/// @param request request body
/// @param success success callback
/// @param failure failure callback
+ (void)HTTPPluginRequest:(KJNetworkingRequest *)request success:(KJNetworkPluginSuccess)success failure:(KJNetworkPluginFailure)failure;
```
</details>

<details><summary><font size=2>**KJNetworkingDelegate**: plug-in protocol, manage network request results</font></summary>

<font color=red>**Currently, there are 5 protocol methods extracted, starting time, network request time, network success, network failure, and final return**</font>

```
/// Start preparing network request
/// @param request request related data
/// @param endRequest Whether to end the following network request
/// @return returns the data processed by the plug-in
- (KJNetworkingResponse *)prepareWithRequest:(KJNetworkingRequest *)request endRequest:(BOOL *)endRequest;

/// Request at the beginning of the network request
/// @param request request related data
/// @param stopRequest Whether to stop the network request
/// @return returns the data processed by the plugin at the start of the network request
- (KJNetworkingResponse *)willSendWithRequest:(KJNetworkingRequest *)request stopRequest:(BOOL *)stopRequest;

/// Successfully received data
/// @param request request related data
/// @param againRequest Do you need to request the network again
/// @return returns the data processed by the successful plug-in
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
**There are 9 plugins available for use:**

- [**KJNetworkLoadingPlugin**](Docs/LOADING.md): Loadin and failed message plugin
- [**KJNetworkAnslysisPlugin**](Docs/ANSLYSIS.md): Anslysis data plugin
- [**KJNetworkCachePlugin**](Docs/CACHE.md): Cache plugin
- [**KJNetworkCertificatePlugin**](Docs/CERTIFICATE.md): Configure certificate plugin
- [**KJNetworkThiefPlugin**](Docs/THIEF.md): Modifier plugin
- [**KJNetworkCapturePlugin**](Docs/CAPTURE.md): Network log packet capture plugin
- [**KJNetworkCodePlugin**](Docs/CODE.md): Error code analysis plugin
- [**KJNetworkRefreshPlugin**](Docs/REFRESH.md): Refresh to load more plugin
- [**KJNetworkEmptyPlugin**](Docs/EMPTY.md): Empty data UI display plugin

### Chain plugin network
[**KJNetworkChainManager**](Docs/CHAIN.md)

### Batch plugin network
[**KJNetworkBatchManager**](Docs/BATCH.md)

### About the author
- 🎷 **E-mail address: [yangkj310@gmail.com](yangkj310@gmail.com) 🎷**
- 🎸 **GitHub address: [yangKJ](https://github.com/yangKJ) 🎸**

-----

### License

KJNetworkPlugin is available under the [MIT](LICENSE) license. See the [LICENSE](LICENSE) file for more info.
