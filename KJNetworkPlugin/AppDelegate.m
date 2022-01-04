//
//  AppDelegate.m
//  KJNetworkPlugin
//
//  Created by 77。 on 2021/7/24.
//  https://github.com/yangKJ/KJNetworkPlugin

#import "AppDelegate.h"
#import "KJNetworkPluginManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    KJBaseNetworking.openLog = NO;
    KJBaseNetworking.baseURL = @"https://www.httpbin.org";
    
    return YES;
}

@end
