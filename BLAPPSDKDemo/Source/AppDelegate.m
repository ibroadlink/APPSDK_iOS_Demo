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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    [self handleOpenFromOtherApp:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    [self handleOpenFromOtherApp:url];
    return YES;
}

#pragma mark - private method
- (void)loadAppSdk {
    //BLLetCore
    self.let = [BLLet sharedLetWithLicense:SDK_LICENSE];        // Init APPSDK
    [self.let setDebugLog:BL_LEVEL_ALL];                           // Set APPSDK debug log level
    [self.let.controller setSDKRawDebugLevel:BL_LEVEL_ALL];        // Set DNASDK debug log level
    self.let.configParam.controllerSendCount = 1;
    
    [BLLet sharedLet].configParam.controllerLocalTimeout = 2000;
    [BLLet sharedLet].configParam.controllerRemoteTimeout = 4000;
    
//    self.let.configParam.controllerScriptDownloadVersion = 1;
    
    
    [self.let.controller startProbe:3000];                           // Start probe device
    self.let.controller.delegate = self;
    
    NSString *licenseId = self.let.configParam.licenseId;
    NSString *companyId = self.let.configParam.companyId;
    
    //BLLetAccount
    self.account = [BLAccount sharedAccountWithlicenseId:licenseId CompanyId:companyId];
    
    //BLLetFamily
    self.familyController = [BLFamilyController sharedManagerWithlicenseId:licenseId];
    
    //BLLetPlugins
    BLPicker *blPicker = [BLPicker sharedPickerWithLicenseId:licenseId License:self.let.configParam.sdkLicense];
    [blPicker startPick];
    NSString *cliendId = @"c39a135e4829daa4c307e60255699416";
    NSString *redirectURI = @"http://latiao.izanpin.com/";
    self.blOauth = [[BLOAuth alloc] initWithLicenseId:licenseId cliendId:cliendId redirectURI:redirectURI];
    
    //BLLetCloud
    self.blCloudTime = [BLCloudTime sharedManagerWithLicenseId:licenseId License:self.let.configParam.sdkLicense];
    self.blCloudScene = [BLCloudScene sharedManagerWithLicenseId:licenseId License:self.let.configParam.sdkLicense];
    self.blCloudLinkage = [BLCloudLinkage sharedManagerWithLicenseId:licenseId License:self.let.configParam.sdkLicense];

    //从数据库取出所有设备加入SDK管理
    NSArray *storeDevices = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
    if (storeDevices && storeDevices.count > 0) {
        [self.let.controller addDeviceArray:storeDevices];
    }
    //本地登录
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    if ([userDefault getUserId] && [userDefault getSessionId]) {
        [_account localLoginWithUsrid:[userDefault getUserId] session:[userDefault getSessionId] completionHandler:nil];
    }
//    _apiUrls = [BLApiUrls sharedApiUrl];
//    NSString *checkApiResult = [self.apiUrls checkApiUrlHosts];
//    NSLog(@"checkApiUrlHosts:%@",checkApiResult);
    
}

- (BOOL)isDeviceHasBeenScaned:(BLDNADevice *)device {
    for (BLDNADevice *dev in self.scanDevices) {
        if ([dev.getDid isEqualToString:device.getDid]) {
            return YES;
        }
    }
    return NO;
}

- (void)handleOpenFromOtherApp:(NSURL *)url {
    NSString *urlString = url.absoluteString;
    NSLog(@"%@", urlString);
    
    __weak typeof(self) weakSelf = self;
    
    [self.blOauth HandleOpenURL:url completionHandler:^(BOOL status, BLOAuthBlockResult *result) {
        if ([result succeed]) {
            
            [weakSelf.account loginWithIhcAccessToken:result.accessToken completionHandler:^(BLLoginResult * _Nonnull result) {
                if ([result succeed]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MainViewController *vc = [MainViewController viewController];
                        [((UINavigationController*)(weakSelf.window.rootViewController)) pushViewController:vc animated:YES];
                    });
                }
            }];
        }else{
            NSLog(@"error=%ld msg=%@", (long)result.error, result.msg);
        }
    }];
}

#pragma mark - BLControllerDelegate
- (Boolean)shouldAdd:(BLDNADevice *)device {
    return NO;
}

- (void)onDeviceUpdate:(BLDNADevice *)device isNewDevice:(Boolean)isNewDevice {
    //Only device reset, newconfig=1
    //Not all device support this.
//    NSLog(@"=====probe device pid(%@) newconfig(%hhu)====", device.pid, device.newConfig);
    
    if (isNewDevice) { //Device did not add SDK
        if (![self isDeviceHasBeenScaned:device]) {
            //[device setLastStateRefreshTime:[NSDate timeIntervalSinceReferenceDate]];
            [self.scanDevices addObject:device];
        }
    } else { //Device has been added SDK
        
        
        if (device.newConfig) {
            //Update Device Info
            [[DeviceDB sharedOperateDB] updateSqlWithDevice:device];
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
