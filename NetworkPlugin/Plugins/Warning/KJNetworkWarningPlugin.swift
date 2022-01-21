//
//  KJNetworkWarningPlugin.swift
//  KJNetworkPlugin
//
//  Created by Condy on 2022/1/8.
//  https://github.com/yangKJ/KJNetworkPlugin
//  错误提示插件

///`Toast_Swift`文档
/// https://github.com/scalessec/Toast-Swift

import Foundation
import Toast_Swift

/// 错误提示插件
@objc public final class KJNetworkWarningPlugin: KJNetworkBasePlugin {
    
    /// Whether to display the Window again, the default is YES
    @objc public var displayInWindow: Bool = true
    /// The default duration. Used for the `makeToast` and `showToast` methods that don't require an explicit duration.
    @objc public var duration: TimeInterval = 1
    
    /// 是否会覆盖上次的错误展示，
    /// 如果上次错误展示还在，新的错误展示是否需要覆盖上次
    /// Whether it will overwrite the last error display,
    /// If the last error display is still there, whether the new error display needs to overwrite the last one
    @objc public var coverLastToast: Bool = true
    
    @objc public override init() { }
}

extension KJNetworkWarningPlugin {
    
    public override func failure(with request: KJNetworkingRequest,
                                 response: KJNetworkingResponse, againRequest:
                                 UnsafeMutablePointer<ObjCBool>) -> KJNetworkingResponse {
        
        self.showText(response.error.localizedDescription)
        return response
    }
}

extension KJNetworkWarningPlugin {
    
    private func showText(_ text: String) {
        DispatchQueue.main.async {
            guard let view = self.displayInWindow ? KJNetworkPlugin.KJNetworkWarningPlugin.keyWindow :
                    KJNetworkPlugin.KJNetworkWarningPlugin.topViewController?.view else {
                        return
                    }
            
            if self.coverLastToast {
                view.hideToast()
            }
            
            var style = ToastStyle()
            style.messageColor = UIColor.white

            view.makeToast(text, duration: self.duration, position: ToastPosition.bottom, style: style)
            
            // or perhaps you want to use this style for all toasts going forward?
            // just set the shared style and there's no need to provide the style again
            ToastManager.shared.style = style
            
            // toggle "tap to dismiss" functionality
            ToastManager.shared.isTapToDismissEnabled = true
            
            // toggle queueing behavior
            ToastManager.shared.isQueueEnabled = !self.coverLastToast
        }
    }
    
    private static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: \.isKeyWindow)
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    private static var topViewController: UIViewController? {
        var vc = keyWindow?.rootViewController
        if let presentedController = vc as? UITabBarController {
            vc = presentedController.selectedViewController
        }
        while let presentedController = vc?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                vc = presentedController.selectedViewController
            } else {
                vc = presentedController
            }
        }
        return vc
    }
}
