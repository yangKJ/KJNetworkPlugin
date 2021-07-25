//
//  KJNetworkingRequest+KJCertificate.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/25.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkingRequest+KJCertificate.h"
#import <objc/runtime.h>

@implementation KJNetworkingRequest (KJCertificate)

- (NSString *)certificatePath{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCertificatePath:(NSString *)certificatePath{
    objc_setAssociatedObject(self, @selector(certificatePath), certificatePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)validatesDomainName{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setValidatesDomainName:(BOOL)validatesDomainName{
    objc_setAssociatedObject(self, @selector(validatesDomainName), @(validatesDomainName), OBJC_ASSOCIATION_ASSIGN);
}

@end
