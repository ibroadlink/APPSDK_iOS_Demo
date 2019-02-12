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
#import "UserViewController.h"
#import <BLLetAccount/BLLetAccount.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
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

#pragma mark - private method
- (void)loadAppSdk {
    //BLLetCore
    self.let = [BLLet sharedLetWithLicense:baihk_SDK_LICENSE];                      // Init APPSDK
    [self.let setDebugLog:BL_LEVEL_ALL];                                            // Set APPSDK debug log level
    [self.let.controller setSDKRawDebugLevel:BL_LEVEL_ALL];                         // Set DNASDK debug log level
    
    [BLConfigParam sharedConfigParam].controllerLocalTimeout = 2000;                // 局域网控制超时时间
    [BLConfigParam sharedConfigParam].controllerRemoteTimeout = 4000;               // 远程控制超时时间
    [BLConfigParam sharedConfigParam].controllerSendCount = 3;                      // 控制重试次数
    [BLConfigParam sharedConfigParam].controllerQueryCount = 8;                     // 设备批量查询设备个数
    [BLConfigParam sharedConfigParam].controllerScriptDownloadVersion = 1;          // 脚本下载平台
    [BLConfigParam sharedConfigParam].appServiceEnable = 1;                         // 使用appService集群
    [BLConfigParam sharedConfigParam].controllerResendMode = 0;                     // 本地控制失败，远程尝试控制
    
    [BLConfigParam sharedConfigParam].packName = @"cn.com.broadlink.econtrol.plus"; //Reset package name
    [BLLet sharedLetWithLicense:SDK_LICENSE];                                       //Reset License
    
    [self.let.controller startProbe:3000];                                          // Start probe device
    self.let.controller.delegate = self;
    
    //获取账号管理对象
    BLAccount *account = [BLAccount sharedAccount];
    
    //从数据库取出所有设备加入SDK管理
    NSArray *storeDevices = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
    if (storeDevices && storeDevices.count > 0) {
        [self.let.controller addDeviceArray:storeDevices];
    }
    //本地登录
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    if ([userDefault getUserId] && [userDefault getSessionId]) {
        NSLog(@"本地登录开始");
        [account localLoginWithUsrid:[userDefault getUserId] session:[userDefault getSessionId] completionHandler:^(BLLoginResult * _Nonnull result) {
            if ([result succeed]) {
                NSLog(@"本地登录成功");
            }
        }];
    }
}

- (BOOL)isDeviceHasBeenScaned:(BLDNADevice *)device {
    for (BLDNADevice *dev in self.scanDevices) {
        if ([dev.getDid isEqualToString:device.getDid]) {
            return YES;
        }
    }
    return NO;
}

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

#pragma mark - BLControllerDelegate
- (void)onDeviceUpdate:(BLDNADevice *)device isNewDevice:(Boolean)isNewDevice {
    //Only device reset, newconfig=1
    //Not all device support this.
//    NSLog(@"=====probe device did(%@) newconfig(%hhu)====", device.did, device.newConfig);
    if (![self isDeviceHasBeenScaned:device]) {
        //[device setLastStateRefreshTime:[NSDate timeIntervalSinceReferenceDate]];
        [self.scanDevices addObject:device];
    }
    if (isNewDevice) { //Device did not add SDK
        
    } else { //Device has been added SDK
        if (device.newConfig) {
            //Update Device Info
            BLPairResult *result = [[BLLet sharedLet].controller pairWithDevice:device];
            if ([result succeed]) {
                device.controlId = result.getId;
                device.controlKey = result.getKey;
                [[DeviceDB sharedOperateDB] updateSqlWithDevice:device];
                //addDevice
                [[BLLet sharedLet].controller addDevice:device];
            }
            
        }
    }
}

- (void)statusChanged:(BLDNADevice *)device status:(BLDeviceStatusEnum)status {
    
}

#pragma mark - property
- (NSMutableArray *)scanDevices {
    if (!_scanDevices) {
        _scanDevices = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _scanDevices;
}


@end
