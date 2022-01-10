//
//  KJNetworkWarningPlugin.swift
//  KJNetworkPlugin
//
//  Created by Condy on 2022/1/8.
//  https://github.com/yangKJ/KJNetworkPlugin
//  错误提示插件

import Foundation

/// 错误提示插件
@objc public final class KJNetworkWarningPlugin: KJNetworkBasePlugin {

    let time: TimeInterval
    
    @objc public init(delay time: TimeInterval) {
        self.time = time
    }
}

extension KJNetworkWarningPlugin {
    
    public override func failure(with request: KJNetworkingRequest,
                                 againRequest: UnsafeMutablePointer<ObjCBool>) -> KJNetworkingResponse {
        super.failure(with: request, againRequest: againRequest)
        
        
        return self.response
    }
}
