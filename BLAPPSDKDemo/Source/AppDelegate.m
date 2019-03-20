//
//  AppDelegate.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "AppDelegate.h"

#import "AppMacro.h"
#import "DeviceDB.h"
#import "MainViewController.h"
#import "BLUserDefaults.h"
#import "BLNewFamilyManager.h"
#import "UserViewController.h"

#import <BLLetAccount/BLLetAccount.h>
#import <BLLetFamily/BLLetFamily.h>
#import <BLLetIRCode/BLLetIRCode.h>
#import <DoraemonKit.h>

#ifndef DISABLE_PUSH_NOTIFICATIONS
#import "BLSNotificationService.h"
#endif

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate () <UNUserNotificationCenterDelegate>

/*push message*/
@property (nonatomic, strong) NSDictionary *pushMessageDic;

@end

@implementation AppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
#ifdef DEBUG
    [[DoraemonManager shareInstance] install];
#endif
    
    [self loadAppSdk];

#ifndef DISABLE_PUSH_NOTIFICATIONS
    //注册消息推送
    [self replyPushNotificationAuthorization:application];
    self.pushMessageDic = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
#endif
    
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
#ifndef DISABLE_PUSH_NOTIFICATIONS

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    // re-post ( broadcast )
    NSString *deviceTokenStr = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceTokenStr : %@", deviceTokenStr);
    [BLSNotificationService sharedInstance].deviceToken = deviceTokenStr;
    [self registerDeviceNotificationService];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    // re-post ( broadcast )
    NSLog(@"Register Remote Notifications error:{%@}",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"userInfo == %@",userInfo);
//    [self alertViewWithUserInfo:userInfo];
    [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
//    if(!self.pushMessageDic) {
//        [self performWithPushMessage:userInfo];
//    }
    completionHandler();
}

//申请通知权限
- (void)replyPushNotificationAuthorization:(UIApplication *)application {//申请通知权限
    if (IsiOS10Later) {//iOS 10 later
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;//必须写代理，不然无法监听通知的接收与点击事件
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {//用户点击允许
                
            } else {//用户点击不允许
                
            }
        }];
        
        // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
        //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象，不能直接修改！
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        }];
    } else if (IsiOS8Later) {//iOS 8 - iOS 10系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    [application registerForRemoteNotifications];//注册远端消息通知以便获取device token
}

- (void)registerDeviceNotificationService {
    NSString *userId = [[BLUserDefaults shareUserDefaults] getUserId];
    
    if (userId && [BLSNotificationService sharedInstance].deviceToken) {
        [[BLSNotificationService sharedInstance] registerDevice];
    }
}

#endif


#pragma mark - private method
- (void)loadAppSdk {
    [BLConfigParam sharedConfigParam].controllerResendMode = 0;                     // 本地控制失败，远程尝试控制
    
    BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
    if ([userDefault getPackName] && [userDefault getLicense]) {
        [BLConfigParam sharedConfigParam].packName = [userDefault getPackName];
        self.let = [BLLet sharedLetWithLicense:[userDefault getLicense]];
    } else {
        [BLConfigParam sharedConfigParam].packName = SDK_PACKAGE_ID;                // Set Package ID
        self.let = [BLLet sharedLetWithLicense:SDK_LICENSE];                        // Init APPSDK
    }
    
    [BLConfigParam sharedConfigParam].controllerLocalTimeout = 5000;                // 局域网控制超时时间
    [BLConfigParam sharedConfigParam].controllerRemoteTimeout = 8000;               // 远程控制超时时间
    [BLConfigParam sharedConfigParam].controllerSendCount = 3;                      // 控制重试次数
    [BLConfigParam sharedConfigParam].controllerQueryCount = 8;                     // 设备批量查询设备个数
    [BLConfigParam sharedConfigParam].controllerScriptDownloadVersion = 1;          // 脚本下载平台
    [BLConfigParam sharedConfigParam].appServiceEnable = [userDefault getAppServiceEnable]; // 使用appService集群

#ifndef DISABLE_PUSH_NOTIFICATIONS
    //测试服务器
    [BLConfigParam sharedConfigParam].appServiceHost = @"https://01e78622f3e6b3a861133fbc0690f4a9appservice.ibroadlink.com";
#endif
    
    [self.let setDebugLog:BL_LEVEL_DEBUG];                                          // Set APPSDK debug log level
    [self.let.controller setSDKRawDebugLevel:BL_LEVEL_DEBUG];                       // Set DNASDK debug log level
    
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
    if ([userDefault getUserId] && [userDefault getSessionId]) {
        NSLog(@"Local loging...");
        [BLNewFamilyManager sharedFamily].userid = [userDefault getUserId];
        [BLNewFamilyManager sharedFamily].loginsession = [userDefault getSessionId];
        [account localLoginWithUsrid:[userDefault getUserId] session:[userDefault getSessionId] completionHandler:^(BLLoginResult * _Nonnull result) {
            if ([result succeed]) {
                NSLog(@"Log success!");
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
