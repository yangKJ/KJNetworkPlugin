//
//  KJNetworkComplete.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/10/23.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "KJNetworkComplete.h"
#import "KJNetworkingRequest.h"

@implementation KJNetworkComplete

- (BOOL)cacheData{
    return self.request.cacheData;
}

- (NSUInteger)taskIdentifier{
    return [[self.request valueForKey:@"taskIdentifier"] integerValue];
}

@end
