//
//  AppDelegate.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "AppDelegate.h"
#import "DeviceDB.h"
#import "MainViewController.h"
#import "BLUserDefaults.h"
#import "BLNewFamilyManager.h"
#import "UserViewController.h"
#import <BLLetAccount/BLLetAccount.h>
#import <BLLetFamily/BLLetFamily.h>
#import <BLLetIRCode/BLLetIRCode.h>
#import <DoraemonKit.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
#ifdef DEBUG
    [[DoraemonManager shareInstance] install];
#endif
    
    [self loadAppSdk];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    [self handleOpenFromOtherApp:url];
//    return YES;
//}
//
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    [self handleOpenFromOtherApp:url];
//    return YES;
//}
//
//- (void)handleOpenFromOtherApp:(NSURL *)url {
//    NSString *urlString = url.absoluteString;
//    NSLog(@"urlString:%@", urlString);
//
//    __weak typeof(self) weakSelf = self;
//
//    [self.blOauth HandleOpenURL:url completionHandler:^(BOOL status, BLOAuthBlockResult *result) {
//        if ([result succeed]) {
//
//            [weakSelf.account loginWithIhcAccessToken:result.accessToken completionHandler:^(BLLoginResult * _Nonnull result) {
//                if ([result succeed]) {
//                    BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
//                    [userDefault setUserId:[result getUserid]];
//                    [userDefault setSessionId:[result getLoginsession]];
//                }
//            }];
//        }else{
//            NSLog(@"error=%ld msg=%@", (long)result.error, result.msg);
//        }
//    }];
//}

#pragma mark - private method
- (void)loadAppSdk {
    [BLConfigParam sharedConfigParam].controllerLocalTimeout = 5000;                // 局域网控制超时时间
    [BLConfigParam sharedConfigParam].controllerRemoteTimeout = 8000;               // 远程控制超时时间
    [BLConfigParam sharedConfigParam].controllerSendCount = 3;                      // 控制重试次数
    [BLConfigParam sharedConfigParam].controllerQueryCount = 8;                     // 设备批量查询设备个数
    [BLConfigParam sharedConfigParam].controllerScriptDownloadVersion = 1;          // 脚本下载平台
    [BLConfigParam sharedConfigParam].appServiceEnable = 1;                         // 使用appService集群
    [BLConfigParam sharedConfigParam].controllerResendMode = 0;                     // 本地控制失败，远程尝试控制
    
    [BLConfigParam sharedConfigParam].packName = SDK_PACKAGE_ID; // set package name
    //BLLetCore
    self.let = [BLLet sharedLetWithLicense:SDK_LICENSE];                            // Init APPSDK
    [self.let setDebugLog:BL_LEVEL_DEBUG];                                            // Set APPSDK debug log level
    [self.let.controller setSDKRawDebugLevel:BL_LEVEL_DEBUG];                         // Set DNASDK debug log level
    
    [self.let.controller startProbe:3000];                                          // Start probe device
    self.let.controller.delegate = self;
    
    //从数据库取出所有设备加入SDK管理
    NSArray *storeDevices = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
    if (storeDevices && storeDevices.count > 0) {
        [self.let.controller addDeviceArray:storeDevices];
    }
    
    [BLFamilyController sharedManager];
    [BLIRCode sharedIrdaCode];
    [BLNewFamilyManager sharedFamily].licenseid = [BLConfigParam sharedConfigParam].licenseId;
    
    //本地登录 获取账号管理对象
    BLAccount *account = [BLAccount sharedAccount];
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    if ([userDefault getUserId] && [userDefault getSessionId]) {
        NSLog(@"本地登录开始");
        [BLNewFamilyManager sharedFamily].userid = [userDefault getUserId];
        [BLNewFamilyManager sharedFamily].loginsession = [userDefault getSessionId];
        [account localLoginWithUsrid:[userDefault getUserId] session:[userDefault getSessionId] completionHandler:^(BLLoginResult * _Nonnull result) {
            if ([result succeed]) {
                NSLog(@"本地登录成功");
            }
        }];
    }
}

#pragma mark - BLControllerDelegate
- (void)onDeviceUpdate:(BLDNADevice *)device isNewDevice:(Boolean)isNewDevice {
    //Only device reset, newconfig=1
    //Not all device support this.
    //NSLog(@"=====probe device did(%@) newconfig(%hhu)====", device.did, device.newConfig);
    
    if (device.did) {
        [self.scanDevices setObject:device forKey:device.did];
    }
    
}

- (void)statusChanged:(BLDNADevice *)device status:(BLDeviceStatusEnum)status {
    
}

#pragma mark - property
- (NSMutableDictionary *)scanDevices {
    if (!_scanDevices) {
        _scanDevices = [[NSMutableDictionary alloc] init];
    }
    
    return _scanDevices;
}

@end
