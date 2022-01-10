//
//  KJNetworkIndicatorPlugin.swift
//  KJNetworkPlugin
//
//  Created by Condy on 2022/1/8.
//  https://github.com/yangKJ/KJNetworkPlugin
//  指示器插件

import Foundation

/// 指示器插件
@objc public final class KJNetworkIndicatorPlugin: KJNetworkBasePlugin {
    
    private(set) static var numberOfRequests: Int = 0 {
        didSet {
            if numberOfRequests > 1 { return }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = self.numberOfRequests > 0
            }
        }
    }
    
    @objc public override init() { }
}

extension KJNetworkIndicatorPlugin {
    
    public override func willSend(with request: KJNetworkingRequest,
                         stopRequest: UnsafeMutablePointer<ObjCBool>) -> KJNetworkingResponse {
        super.willSend(with: request, stopRequest: stopRequest)
        
        KJNetworkIndicatorPlugin.numberOfRequests += 1        
        return self.response
    }
    
    public override func succeed(with request: KJNetworkingRequest,
                                 againRequest: UnsafeMutablePointer<ObjCBool>) -> KJNetworkingResponse {
        super.succeed(with: request, againRequest: againRequest)
        
        KJNetworkIndicatorPlugin.numberOfRequests -= 1
        return self.response
    }
    
    public override func failure(with request: KJNetworkingRequest,
                                 againRequest: UnsafeMutablePointer<ObjCBool>) -> KJNetworkingResponse {
        super.failure(with: request, againRequest: againRequest)
        
        KJNetworkIndicatorPlugin.numberOfRequests -= 1
        return self.response
    }
}
