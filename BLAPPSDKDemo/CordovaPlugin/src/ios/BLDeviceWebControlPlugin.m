//
//  BLDeviceWebControlPlugin.m
//  Let
//
//  Created by junjie.zhu on 2016/10/31.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLDeviceWebControlPlugin.h"
#import "BLDeviceService.h"

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
        
        NSString *deviceinfoJsonString = [NSString stringWithFormat:@"{\"deviceID\":\"%@\",\"deviceName\":\"%@\", \"deviceStatus\":%ld,\"networkStatus\":{\"status\":\"available\"},\"user\":{\"name\":\"%@\"}}", [selectDevice getDid], [selectDevice getName], (long)[selectControl queryDeviceState:[selectDevice getDid]], accountName];
        
        NSLog(@"%@", deviceinfoJsonString);
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

    NSString *controlResult;
    if ([dataDic[@"act"] isEqualToString:@"get"] || [dataDic[@"act"] isEqualToString:@"set"]) {
        NSString *dataStr = [self p_toJsonString:dataDic];
        controlResult = [selectControl dnaControl:[selectDevice getDid] subDevDid:nil
                                          dataStr:dataStr command:@"dev_ctrl" scriptPath:nil];
        NSLog(@"%@",controlResult);
    }else {
        NSString *dataStr = [self p_toJsonString:dataDic];
        controlResult = [selectControl dnaControl:[selectDevice getDid] subDevDid:nil
                                          dataStr:dataStr command:@"dev_subdev_timer" scriptPath:nil];
    }
    
    mainBlock(YES, [self p_toDictory:controlResult]);
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
