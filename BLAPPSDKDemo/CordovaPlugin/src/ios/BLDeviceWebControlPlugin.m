//
//  BLDeviceWebControlPlugin.m
//  Let
//
//  Created by junjie.zhu on 2016/10/31.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLDeviceWebControlPlugin.h"
#import "BLDeviceService.h"
#import "AppDelegate.h"
@implementation BLDeviceWebControlPlugin

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)deviceinfo:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        BLController *selectControl = deviceService.blController;
        BLDNADevice *selectDevice = deviceService.selectDevice;
        NSString *accountName = deviceService.accountName;
        
        NSString *deviceinfoJsonString = [NSString stringWithFormat:@"{\"deviceID\":\"%@\",\"subDeviceID\":\"%@\",\"deviceName\":\"%@\", \"deviceStatus\":%ld,\"networkStatus\":{\"status\":\"available\"},\"user\":{\"name\":\"%@\"}}", [selectDevice getDid],[selectDevice getPDid], [selectDevice getName], (long)[selectControl queryDeviceState:[selectDevice getDid]], accountName];
        
        NSLog(@"H5deviceinfoJsonString:%@", deviceinfoJsonString);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceinfoJsonString];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)devicecontrol:(CDVInvokedUrlCommand*)command {
    [self actWithControlParam:command.arguments andBlock:^(BOOL ret, NSDictionary *dic) {
        CDVPluginResult* pluginResult;
        if (ret) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[self p_toJsonString:dic]];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)actWithControlParam:(NSArray *)info andBlock:(void(^)(BOOL ret, NSDictionary *dic))mainBlock {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    BLController *selectControl = deviceService.blController;
    BLDNADevice *selectDevice = deviceService.selectDevice;
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dataDic setDictionary:[info objectAtIndex:2]];
    [dataDic setObject:[selectDevice getDid] forKey:@"did"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *controlResult;
        NSString *dataStr = [self p_toJsonString:dataDic];
        controlResult = [selectControl dnaControl:[selectDevice getDid] subDevDid:selectDevice.pDid
                                          dataStr:dataStr command:info[3] scriptPath:nil];
        NSLog(@"H5controlResult:%@",controlResult);
        
        mainBlock(YES, [self p_toDictory:controlResult]);
    });
    
    
}

- (void)notification:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        BLDNADevice *selectDevice = deviceService.selectDevice;
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[selectDevice getDid], @"did", nil];
        NSString *echo = [self p_toJsonString:dic];
        
        CDVPluginResult* pluginResult;
        if (echo && [echo length] > 0) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

/*Device authorization*/
- (void)deviceAuth:(CDVInvokedUrlCommand *)command {
   
}

//获取当前家庭信息
- (void)getFamilyInfo:(CDVInvokedUrlCommand *)command {
    NSDictionary *currentFamilyInfoIDic = @{@"familyId"     :   @"00f441737c9f0866a717834fcc3ed416",
                                            @"familyName"   :   @"测试433",
                                            @"familyIcon"   :   @"http://www.broadlink.com.cn/images/homeFullpage/broadlink.png"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:currentFamilyInfoIDic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getGetwaySubDeviceList:(CDVInvokedUrlCommand *)command {
    NSMutableArray *subDeviceList = [NSMutableArray arrayWithCapacity:0];
    NSArray *arguments = command.arguments;
    NSString *did = nil;
    if (arguments && arguments.count>0) {
        did = [[self parseArguments:command.arguments.firstObject] objectForKey:@"did"];
    }
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    BLDNADevice *selectDevice = deviceService.selectDevice;
    if (!did || [did isEqualToString:@""]) {
        did = [selectDevice getDid];
    }
    BLSubDevListResult *result = [[BLLet sharedLet].controller subDevListQueryWithDid:did index:0 count:10];

    if ([result succeed]) {
        if (result.list && ![result.list isKindOfClass:[NSNull class]] && result.list.count > 0) {
            
            NSArray *resultlist = result.list;
            NSMutableArray *subDeviceList = [NSMutableArray arrayWithCapacity:0];
            for (BLDNADevice *subDevice in resultlist) {
                [[BLLet sharedLet].controller addDevice:subDevice];
                //下载子设备脚本
                [[BLLet sharedLet].controller downloadScript:subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {NSLog(@"resultsavePath:%@",result.savePath);}];
                NSDictionary *subDeviceInfo = @{@"did"      :   subDevice.did,
                                                @"pid"      :   subDevice.pid ? subDevice.pid : @"",
                                                @"name"     :   subDevice.name ? subDevice.name : @"",
                                                @"icon"     :   @"http://www.broadlink.com.cn/images/homeFullpage/broadlink.png",
                                                @"roomId"   :   @"2008450249062634829",
                                                @"roomName" :   @"客厅"};
                [subDeviceList addObject:subDeviceInfo];
            }
        }
    }

    NSDictionary *resultDic = @{@"status":@0,@"deviceList":[subDeviceList copy]};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:resultDic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//获取设备的Profile
- (void)getDeviceProfile:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = [self parseArguments:command.arguments.firstObject];
    NSString *pid = dic[@"pid"];;
    NSString *profile = [NSString stringWithFormat:@"{\"profile\":%@}", [[[BLLet sharedLet].controller queryProfileByPid:pid] getProfile]];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:profile];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSDictionary *)parseArguments:(id)obj {
    if ([obj isKindOfClass:[NSString class]]) {
        return [self p_toDictory:obj];
    } else if([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    }
    return @{};
}

#pragma mark - private
- (NSString *)p_toJsonString:(NSDictionary *)dic {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)p_toDictory:(NSString *)jsonString {
    NSError *error;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }
    
    return dic;
}

@end
