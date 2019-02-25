//
//  BLDeviceWebControlPlugin.m
//  Let
//
//  Created by junjie.zhu on 2016/10/31.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLDeviceWebControlPlugin.h"
#import "BLDeviceService.h"
#import "BLNewFamilyManager.h"
#import "BLUserDefaults.h"
#import "AppDelegate.h"

#import <BLLetAccount/BLLetAccount.h>
#import <BLLetCore/BLLetCore.h>

@implementation BLDeviceWebControlPlugin

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)onReset {
    
}

//获取当前家庭信息
- (void)getFamilyInfo:(CDVInvokedUrlCommand *)command {
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    BLSFamilyInfo *familyInfo = manager.currentFamilyInfo;
    
    NSDictionary *currentFamilyInfoIDic = @{};
    if (familyInfo) {
        currentFamilyInfoIDic = @{@"familyId"       :   familyInfo.familyid ?: @"",
                                  @"familyName"     :   familyInfo.name ?: @"",
                                  @"familyIcon"     :   familyInfo.iconpath ?: @"",
                                  @"countryCode"    :   familyInfo.countryCode ?: @"",
                                  @"provinceCode"   :   familyInfo.provinceCode ?: @"",
                                  @"cityCode"       :   familyInfo.cityCode ?: @"",
                                  @"isAdmin"        :   [NSNumber numberWithBool:YES]
                                  };
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:currentFamilyInfoIDic]];
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

//获取设备信息
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

//设备控制通用接口
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
    NSString *did = [info objectAtIndex:0];
    NSString *sdid = nil;
    if (![info[1] isKindOfClass:[NSString class]]) {
        //子设备模块暂不引入
//        if (deviceService.currentOperateModule.subDeviceInfo) {
//            [self setGateWayModule];
//        }
    } else {
        sdid = info[1];
    }
    
    NSString *dataStr = nil;
    if (dataDic.allKeys.count<=0) {
        dataStr = [NSString stringWithFormat:@"{\"did\":\"%@\"}", did];
    } else {
        dataStr = [self p_toJsonString:dataDic];
    }
    NSInteger sendCount = 1;
    if (info.count >= 4) {
        NSDictionary *dic = [self parseArguments:info[3]];
        sendCount = dic[@"sendCount"] ? [dic[@"sendCount"] integerValue] : 1;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *controlResult;
        NSString *dataStr = [self p_toJsonString:dataDic];
        controlResult = [selectControl dnaControl:did subDevDid:sdid
                                          dataStr:dataStr command:info[3] scriptPath:nil sendcount:sendCount];
        NSLog(@"H5controlResult:%@",controlResult);
        
        mainBlock(YES, [self p_toDictory:controlResult]);
    });
}

//通知接口
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

//自定义导航栏
- (void)custom:(CDVInvokedUrlCommand *)command {
    if (command.arguments != nil) {
        NSNotification * notice = [NSNotification notificationWithName:BL_SDK_H5_NAVI object:nil userInfo:@{@"hander":command.arguments}];
        [[NSNotificationCenter defaultCenter] postNotification:notice];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT messageAsString:@"error"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//http request
- (void)httpRequest:(CDVInvokedUrlCommand *)command {
    __block CDVPluginResult* pluginResult = nil;
    NSDictionary *dataDic = [self parseArguments:command.arguments.firstObject];
    NSArray *params = dataDic[@"bodys"];
    NSData *data = [self parseDataFrom:params];
    NSString *myUrlString = dataDic[@"url"];
    
    NSDictionary *header = dataDic[@"headerJson"] ;
    NSMutableDictionary *headerDic = [header mutableCopy];
    for (NSString *key in header) {
        headerDic[key] = [NSString stringWithFormat:@"%@",header[key]];
    }
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    if ([[dataDic[@"method"] lowercaseString] isEqualToString:@"post"]) {
        [httpAccessor post:myUrlString head:header data:data timeout:10*1000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
            NSString *jsonString;
            if (error) {
                NSDictionary *dic = @{
                                      @"error": [error localizedDescription]
                                      };
                jsonString = [self p_toJsonString:dic];
            } else {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                jsonString = [self p_toJsonString:dic];
            }
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonString];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    } else {
        [httpAccessor get:myUrlString head:header timeout:10*1000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
            NSString *jsonString;
            if (error) {
                NSDictionary *dic = @{
                                      @"error": [error localizedDescription]
                                      };
                jsonString = [self p_toJsonString:dic];
            } else {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                jsonString = [self p_toJsonString:dic];
            }
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonString];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
}

//获取用户信息
- (void)getUserInfo:(CDVInvokedUrlCommand *)command {
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    
    NSString *userInfoJsonString =
    [NSString stringWithFormat:@"{\"userId\":\"%@\", \"nickName\":\"%@\",\"userName\":\"%@\", \"userIcon\":\"%@\",\"loginSession\":\"%@\"}",
     userDefault.getUserId,
     userDefault.getUserName,
     userDefault.getUserName,
     @"",
     userDefault.getSessionId];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:userInfoJsonString];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//获取网关子设备列表
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

//关闭页面
- (void)closeWebView:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = @{@"status":@0, @"msg":@"ok"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

//获取Wi-Fi信息
- (void)wifiInfo:(CDVInvokedUrlCommand *)command {
    NSString *ssid = [BLNetworkImp getCurrentSSIDInfo]?:@"";
    NSDictionary *dic = @{@"ssid":ssid};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//发送验证码
- (void)accountSendVCode:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSString *account = param[@"account"];
    NSString *countryCode = param[@"countrycode"];
    [[BLAccount sharedAccount] sendFastVCode:account countryCode:countryCode completionHandler:^(BLBaseResult * _Nonnull result) {
        NSDictionary *dic = @{@"error":@([result getError]),
                                 @"msg":[result getMsg]};
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

//打开指定页面
- (void)openUrl:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSString *platform = param[@"platform"];
    NSString *url = param[@"url"];
    NSDictionary *dic = @{@"status":@0, @"msg":@"ok"};
    if ([platform isEqualToString:@"app"]) {
        NSString *locationJs = [NSString stringWithFormat:@"window.document.location = '%@';", url];
        [self.webViewEngine evaluateJavaScript:locationJs completionHandler:nil];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else if ([platform isEqualToString:@"system"]) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

//添加设备到SDK
- (void)addDeviceToNetworkInit:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    BLDNADevice *device = [[BLDNADevice alloc] initWithDeviceInfoDic:param];
    
    device.controlKey = param[@"key"];
    if (param[@"id"]) {
        device.controlId = [param[@"id"] unsignedIntegerValue];
    }
    
    [[BLLet sharedLet].controller addDevice:device];
    NSDictionary *dic = @{@"status":@0, @"msg":@"ok"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



#pragma mark - private
- (NSDictionary *)parseArguments:(id)obj {
    if ([obj isKindOfClass:[NSString class]]) {
        return [self p_toDictory:obj];
    } else if([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    }
    return @{};
}

- (NSData *)parseDataFrom:(NSArray *)params {
    NSMutableData *data = [[NSMutableData alloc] init];
    
    if ([params isKindOfClass:[NSArray class]]) {
        for (int i=0; i<[params count]; ++i ){
            id value = [params objectAtIndex:i];
            int tmp = 0;
            if ([value isKindOfClass:[NSNumber class]]) {
                tmp = [value intValue];
            } else if ([value isKindOfClass:[NSString class]]) {
                tmp = [value doubleValue];
            }
            [data appendBytes:&tmp length:1];
        }
    }
    return [data copy];
}


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
