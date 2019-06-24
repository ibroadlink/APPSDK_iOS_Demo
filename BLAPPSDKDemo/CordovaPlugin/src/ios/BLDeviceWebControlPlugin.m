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
#import "AppMacro.h"

#import "EndpointAddViewController.h"
#import "EndpointDetailController.h"
#import "DeviceWebControlViewController.h"
#import "DNAControlViewController.h"
#import "GateWayViewController.h"

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
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    BLSFamilyInfo *familyInfo = manager.currentFamilyInfo;
    
    NSDictionary *currentFamilyInfoIDic = @{};
    if (familyInfo) {
        currentFamilyInfoIDic = @{
                                  @"familyId"       :   familyInfo.familyid ?: @"",
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

//获取当前家庭场景列表
- (void)getFamilySceneList:(CDVInvokedUrlCommand *)command {
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [manager getScenesWithCompletionHandler:^(BLSQueryScenesResult * _Nonnull result) {
        NSMutableArray *scenesList = [NSMutableArray arrayWithCapacity:0];
        
        if ([result succeed]) {
            for (BLSSceneInfo *info in result.scenes) {
                NSDictionary *sceneInfo = @{@"id"   :   info.sceneId,
                                            @"name" :   info.friendlyName,
                                            @"icon" :   info.icon};
                [scenesList addObject:sceneInfo];
            }
        }
        
        NSDictionary *resultDic = @{@"scenes":scenesList};
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:resultDic]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

//获取设备所在的房间
- (void)getDeviceRoom:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, dic: %@", command.methodName, dic);

    NSString *did = dic[@"did"];
    NSDictionary *resultDic = @{};
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    
    if (!manager.roomList) {
        //获取一次房间列表
        dispatch_group_t group = dispatch_group_create();  //创建信号量
        dispatch_group_enter(group);  //在此发送信号量
        [manager getFamilyRoomsWithCompletionHandler:^(BLSManageRoomResult * _Nonnull result) {
            dispatch_group_leave(group);
        }];
        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));  //关键点，在此等待信号量
    }
    
    for (BLSEndpointInfo *info in manager.endpointList) {
        if ([info.endpointId isEqualToString:did]) {

            for (BLSRoomInfo *room in manager.roomList) {
                if ([info.roomId isEqualToString:room.roomid]) {
                    resultDic = @{
                                  @"id"   :   room.roomid,
                                  @"name" :   room.name
                                  };
                }
            }
            break;
        }
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:resultDic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//获取设备的Profile
- (void)getDeviceProfile:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, dic: %@", command.methodName, dic);
    
    NSString *pid = dic[@"pid"];;
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:pid];
    
    NSString *profile = @"";
    if ([result succeed]) {
        profile = result.getProfile;
    }
    
    NSDictionary *resultDic = @{@"profile":profile};

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:resultDic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//获取设备信息
- (void)deviceinfo:(CDVInvokedUrlCommand *)command {
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
    [self.commandDelegate runInBackground:^{
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        BLController *selectControl = [BLLet sharedLet].controller;
        BLDNADevice *selectDevice = deviceService.selectDevice;
        
        BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
        NSString *accountName = [userDefault getUserName];
        
        NSString *deviceinfoJsonString = nil;
        if ([BLCommonTools isEmpty:selectDevice.pDid]) {
            //Wi-Fi设备
            deviceinfoJsonString = [NSString stringWithFormat:@"{\"productID\":\"%@\", \"deviceMac\":\"%@\", \"deviceID\":\"%@\", \"deviceName\":\"%@\",\"deviceStatus\":%ld,\"networkStatus\":{\"status\":\"available\"},\"user\":{\"name\":\"%@\"}}",
                                    [selectDevice getPid],
                                    [selectDevice getMac],
                                    [selectDevice getDid],
                                    [selectDevice getName],
                                    (long)[selectControl queryDeviceState:selectDevice.ownerId ? selectDevice.deviceId : [selectDevice getDid]],
                                    accountName];
        } else {
            //子设备
            deviceinfoJsonString = [NSString stringWithFormat:@"{\"productID\":\"%@\", \"deviceID\":\"%@\",\"subDeviceID\":\"%@\",\"deviceName\":\"%@\",\"deviceStatus\":%ld,\"networkStatus\":{\"status\":\"available\"},\"user\":{\"name\":\"%@\"}}",
                                    [selectDevice getPid],
                                    [selectDevice getPDid],
                                    [selectDevice getDid],
                                    [selectDevice getName],
                                    (long)[selectControl queryDeviceState:selectDevice.ownerId ? selectDevice.deviceId :[selectDevice getPDid]],
                                    accountName];
        }
        
        NSLog(@"H5deviceinfoJsonString:%@", deviceinfoJsonString);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceinfoJsonString];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

//设备控制通用接口
- (void)devicecontrol:(CDVInvokedUrlCommand*)command {
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
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
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *did = info[0];
    NSString *sdid = info[1];
    [dataDic setDictionary:[info objectAtIndex:2]];

    NSString *dataStr = nil;
    if (dataDic.allKeys.count <= 0) {
        dataStr = [NSString stringWithFormat:@"{\"did\":\"%@\"}", did];
    } else {
        dataStr = [self p_toJsonString:dataDic];
    }
    NSInteger sendCount = 1;
    if (info.count >= 4) {
        NSDictionary *dic = [self parseArguments:info[3]];
        sendCount = dic[@"sendCount"] ? [dic[@"sendCount"] integerValue] : 1;
    }
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    BLDNADevice *device = deviceService.selectDevice;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *controlResult;
        NSString *dataStr = [self p_toJsonString:dataDic];
        BLDNADevice *fDevice = [[BLLet sharedLet].controller getDevice:[NSString stringWithFormat:@"%@++%@", device.pDid, device.ownerId]];
        controlResult = [[BLLet sharedLet].controller dnaControl:device.ownerId ? fDevice.deviceId : did subDevDid:device.ownerId ? device.deviceId : sdid
                                          dataStr:dataStr command:info[3] scriptPath:nil sendcount:sendCount];
        NSLog(@"H5controlResult:%@",controlResult);
        
        mainBlock(YES, [self p_toDictory:controlResult]);
    });
}

//通知接口
- (void)notification:(CDVInvokedUrlCommand *)command {
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
    [self.commandDelegate runInBackground:^{
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        BLDNADevice *selectDevice = deviceService.selectDevice;
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[selectDevice getDid], @"did", nil];
        NSString *echo = [self p_toJsonString:dic];
        
        CDVPluginResult* pluginResult;
        if (![BLCommonTools isEmpty:echo]) {
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
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
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
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, dataDic);
    
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

//请求云端服务
- (void)cloudServices:(CDVInvokedUrlCommand *)command {
    __block CDVPluginResult* pluginResult = nil;
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
    NSString *interface = param[@"interfaceName"];
    NSString *httpBody = param[@"httpBody"];
    NSString *serviceName = param[@"serviceName"];
    NSString *method = param[@"method"];
    
    if ([interface isEqualToString:@"URL_HOST_NAME"] || [interface isEqualToString:@"URL_HOST_IP"]) {
        [self getDomainOrIpWithServiceName:serviceName infName:interface command:command];
        return;
    }
    
    NSMutableDictionary *head = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *myUrlString = nil;
    
    if (![BLCommonTools isEmpty:serviceName]) {
        if ([serviceName isEqualToString:@"iftttservice"]           //联动服务，数据需要加密
            || [serviceName isEqualToString:@"privatedataservice"]  //家庭私有数据
            || [serviceName isEqualToString:@"resourceservice"]) {  //家庭私有资源服务
            
            if (![interface hasPrefix:@"/"]) {
                interface = [NSString stringWithFormat:@"/%@", interface];
            }
            myUrlString = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:interface];
            NSDictionary *postDic = [self p_toDictory:httpBody];

            BLFamilyHttpAccessor *accessor = [BLFamilyHttpAccessor sharedAccessor];
            [accessor generatePost:myUrlString head:head data:postDic timeout:10*1000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
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
            
            return;
        } else if ([serviceName isEqualToString:@"productservice"]) { //产品中心服务
            NSString *url = [NSString stringWithFormat: @"https://%@bizappmanage.ibroadlink.com/ec4/%@", [BLConfigParam sharedConfigParam].licenseId, interface];
            
            BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
            
            NSData *postData;
            NSDictionary *postDic = [self p_toDictory:httpBody];
            if (postDic[@"locateid"]) {
                if ([postDic[@"locateid"] isKindOfClass:[NSNull class]]) {
                    NSMutableDictionary *modifyDic = [[NSMutableDictionary alloc] initWithDictionary:postDic];
                    modifyDic[@"locateid"] = @(0);
                    postData = [NSJSONSerialization dataWithJSONObject:modifyDic options:0 error:nil];
                }
            } else {
                postData = [httpBody dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            [httpAccessor post:url head:head data:postData timeout:10*1000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
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
                return;
        } else {
            interface = [self getInfUrlWithName:interface srvName:serviceName];
            
            long nowTime = (long)[[NSDate date] timeIntervalSince1970];
            NSString *verfiedString = [NSString stringWithFormat: @"%@%@%ldbroadlinkappmanage@%@", [BLApiUrls sharedApiUrl].baseIRCodeUrl, interface, nowTime, [BLConfigParam sharedConfigParam].licenseId];
            NSString *language = [BLCommonTools getCurrentLanguage];
            
            [head setObject:[BLCommonTools sha1:verfiedString] forKey:@"sign"];
            [head setObject:[NSString stringWithFormat:@"%ld", nowTime] forKey:@"timestamp"];
            [head setObject:language forKey:@"language"];
        }
    }
    
    if (![interface hasPrefix:@"/"]) {
        interface = [NSString stringWithFormat:@"/%@", interface];
    }
    //新集群接口服务直接请求
    myUrlString = [[BLApiUrls sharedApiUrl] familyCommonUrlWithPath:interface];
    
    BLBaseHttpAccessor *httpAccessor = [[BLBaseHttpAccessor alloc] init];
    
    if ([[method lowercaseString] isEqualToString:@"post"]) {
        NSData *postData;
        NSDictionary *postDic = [self p_toDictory:httpBody];
        if (postDic[@"locateid"]) {
            if ([postDic[@"locateid"] isKindOfClass:[NSNull class]]) {
                NSMutableDictionary *modifyDic = [[NSMutableDictionary alloc] initWithDictionary:postDic];
                modifyDic[@"locateid"] = @(0);
                postData = [NSJSONSerialization dataWithJSONObject:modifyDic options:0 error:nil];
            }
        } else {
            postData = [httpBody dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        [httpAccessor post:myUrlString head:head data:postData timeout:10*1000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
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
    } else if ([[method lowercaseString] isEqualToString:@"multipart"]) {
        NSData *postData = [httpBody dataUsingEncoding:NSUTF8StringEncoding];
        NSData *postData2;
        NSString *filePath = param[@"filePath"];
        if (![BLCommonTools isEmpty:filePath]) {
            postData2 = [NSData dataWithContentsOfFile:filePath];
        }
        
        NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:2];
        if (postData) {
            [postDic setObject:postData forKey:@"text"];
        }
        if (postData2) {
            [postDic setObject:postData2 forKey:@"file"];
        }
        
        [httpAccessor multipartPost:myUrlString head:head data:postDic timeout:10*1000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
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
        [httpAccessor get:myUrlString head:head timeout:10*1000 completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
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
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
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

//获取家庭下设备列表
- (void)getDeviceList:(CDVInvokedUrlCommand *)command {
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
    NSMutableArray *deviceArray = [NSMutableArray arrayWithCapacity:0];
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    NSArray *endpointList = manager.endpointList;
    
    for (BLSEndpointInfo *info in endpointList) {
        BLDNADevice *device = [info toDNADevice];
        [deviceArray addObject:[device BLS_modelToJSONObject]];
    }
    
    NSDictionary *resultDic = @{@"deviceList":deviceArray};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:resultDic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//获取联动列表
- (void)getLinkageList:(CDVInvokedUrlCommand *)command {
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    NSMutableArray *linkageList = [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary *resultDic = @{@"status":@(0),@"linkageList":linkageList};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:resultDic]];
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
    
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, command.arguments.firstObject);
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    BLDNADevice *selectDevice = deviceService.selectDevice;
    if (!did || [did isEqualToString:@""]) {
        did = [selectDevice getDid];
    }
    BLSubDevListResult *result = [[BLLet sharedLet].controller subDevListQueryWithDid:did index:0 count:10];

    if ([result succeed]) {
        if (result.list && ![result.list isKindOfClass:[NSNull class]] && result.list.count > 0) {
            
            NSArray *resultlist = result.list;
            for (BLDNADevice *subDevice in resultlist) {
                BLController *controller = [BLLet sharedLet].controller;
                [controller addDevice:subDevice];
                
                NSString *subScriptPath = [controller queryScriptFileName:subDevice.pid];
                if (![[NSFileManager defaultManager] fileExistsAtPath:subScriptPath]) {
                    //下载子设备脚本
                    [controller downloadScript:subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {
                        NSLog(@"result script savePath:%@",result.savePath);
                    }];
                    
                    //下载子设备UI包
                    [controller downloadUI:subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {
                        NSLog(@"result ui savePath:%@",result.savePath);
                    }];
                }
                
                NSString *did = subDevice.did;
                
                BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
                
                if (!manager.roomList) {
                    //获取一次房间列表
                    dispatch_group_t group = dispatch_group_create();  //创建信号量
                    dispatch_group_enter(group);  //在此发送信号量
                    [manager getFamilyRoomsWithCompletionHandler:^(BLSManageRoomResult * _Nonnull result) {
                        dispatch_group_leave(group);
                    }];
                    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));  //关键点，在此等待信号量
                }
                
                for (BLSEndpointInfo *info in manager.endpointList) {
                    if ([info.endpointId isEqualToString:did]) {
                        
                        for (BLSRoomInfo *room in manager.roomList) {
                            if ([info.roomId isEqualToString:room.roomid]) {
                                NSDictionary *subDeviceInfo = @{
                                                                @"did"      :   subDevice.did,
                                                                @"icon"     :   info.icon,
                                                                @"name"     :   info.friendlyName ? info.friendlyName : @"",
                                                                @"pid"      :   subDevice.pid ? subDevice.pid : @"",
                                                                @"roomId"    :   room.roomid,
                                                                @"roomName"  :   room.name
                                                                
                                                                };
                                [subDeviceList addObject:subDeviceInfo];
                            }
                        }
                    }
                }
                
                
            }
        }
    }

    NSDictionary *resultDic = @{@"status":@(0),@"deviceList":[subDeviceList copy]};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:resultDic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//打开设备控制页面
- (void)openDeviceControlPage:(CDVInvokedUrlCommand *)command {
    NSDictionary *dic = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, dic);
    
    if (dic[@"data"]) {
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        deviceService.h5Data = dic[@"data"];
    }
    if (dic[@"sdid"]) {
        [self openDeviceViewWithSdid:dic[@"sdid"]];
    } else if (dic[@"did"]) {
        [self openDeviceViewWithSdid:dic[@"did"]];
    } else {
        return;
    }
    NSDictionary *retDic = @{@"status":@(0),@"msg":@"ok"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:retDic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openDeviceViewWithSdid:(NSString *)sdid {
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    NSArray *endpointList = manager.endpointList;
    
    for (BLSEndpointInfo *info in endpointList) {
        if ([info.endpointId isEqualToString:sdid]) {
            manager.currentEndpointInfo = info;
            BLDNADevice *device = [info toDNADevice];
            [[BLLet sharedLet].controller addDevice:device];
            
            DeviceWebControlViewController* vc = [[DeviceWebControlViewController alloc] init];
            vc.selectDevice = device;
            [self.viewController.navigationController pushViewController:vc animated:YES];
            break;
        }
    }
}

//关闭页面
- (void)closeWebView:(CDVInvokedUrlCommand *)command {
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
    NSDictionary *dic = @{@"status":@(0), @"msg":@"ok"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

//获取Wi-Fi信息
- (void)wifiInfo:(CDVInvokedUrlCommand *)command {
    NSLog(@"BLDeviceWebControlPlugin method: %@", command.methodName);
    
    NSString *ssid = [BLNetworkImp getCurrentSSIDInfo]?:@"";
    NSDictionary *dic = @{@"ssid":ssid};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/*gpsLocation*/
- (void)gpsLocation:(CDVInvokedUrlCommand *)command {
    NSString *city = @"HangZhou";
    NSString *address = @"BingJiang";
    NSNumber *longitude = [NSNumber numberWithFloat:0];
    NSNumber *latitude = [NSNumber numberWithFloat:0];
    NSDictionary *locationInfo = @{@"city"      :   city?:@"",
                                   @"address"   :   address?:@"",
                                   @"longitude" :   longitude,
                                   @"latitude"  :   latitude};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:locationInfo]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//发送验证码
- (void)accountSendVCode:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
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
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
    NSString *platform = param[@"platform"];
    NSString *url = param[@"url"];
    NSDictionary *dic = @{@"status":@(0), @"msg":@"ok"};
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

//添加设备到家庭
- (void)addDeviceToFamily:(CDVInvokedUrlCommand *)command {
    NSDictionary *deviceParam = [self parseArguments:command.arguments.firstObject];
    NSDictionary *produceParam = [self parseArguments:command.arguments[1]];
    NSDictionary *h5Param = command.arguments.count==3 ? [self parseArguments:command.arguments[2]] : nil;
    
    NSLog(@"BLDeviceWebControlPlugin method: %@, deviceParam: %@, produceParam: %@, h5Param: %@", command.methodName, deviceParam, produceParam, h5Param);

    BLDNADevice *deviceInfo = [[BLDNADevice alloc] init];
    deviceInfo.did = deviceParam[@"did"];
    deviceInfo.pid = deviceParam[@"pid"];
    deviceInfo.mac = deviceParam[@"mac"];
    deviceInfo.name = deviceParam[@"name"];
    deviceInfo.pDid = deviceParam[@"pDid"];
    deviceInfo.controlKey = deviceParam[@"key"];
    if (deviceParam[@"id"]) {
        deviceInfo.controlId = [deviceParam[@"id"] unsignedIntegerValue];
    }
    if (deviceParam[@"type"]) {
        deviceInfo.type = [deviceParam[@"type"] unsignedIntegerValue];
    } else if (deviceInfo.pid) {
        NSData *pidData = [BLCommonTools hexString2Bytes:deviceInfo.pid];
        Byte *pidByte = (Byte *)[pidData bytes];
        deviceInfo.type = pidByte[12] + (pidByte[13] << 8);
    }
    
    EndpointAddViewController *vc = [EndpointAddViewController viewController];
    vc.selectDevice = deviceInfo;
    vc.h5param = h5Param;
    [self.viewController.navigationController pushViewController:vc animated:YES];

    NSDictionary *dic = @{@"status":@(0), @"msg":@"ok"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//添加设备到SDK
- (void)addDeviceToNetworkInit:(CDVInvokedUrlCommand *)command {
    NSDictionary *deviceParam = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, deviceParam);
    
    BLDNADevice *deviceInfo = [[BLDNADevice alloc] init];
    deviceInfo.did = deviceParam[@"did"];
    deviceInfo.pid = deviceParam[@"pid"];
    deviceInfo.mac = deviceParam[@"mac"];
    deviceInfo.name = deviceParam[@"name"];
    deviceInfo.pDid = deviceParam[@"pDid"];
    deviceInfo.controlKey = deviceParam[@"key"];
    if (deviceParam[@"id"]) {
        deviceInfo.controlId = [deviceParam[@"id"] unsignedIntegerValue];
    }
    if (deviceParam[@"type"]) {
        deviceInfo.type = [deviceParam[@"type"] unsignedIntegerValue];
    } else if (deviceInfo.pid) {
        NSData *pidData = [BLCommonTools hexString2Bytes:deviceInfo.pid];
        Byte *pidByte = (Byte *)[pidData bytes];
        deviceInfo.type = pidByte[12] + (pidByte[13] << 8);
    }
    
    [[BLLet sharedLet].controller addDevice:deviceInfo];
    NSDictionary *dic = @{@"status":@(0), @"msg":@"ok"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//从家庭里面删除
- (void)deleteFamilyDeviceList:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
    NSArray *dids = param[@"dids"];
    NSArray *sdids = param[@"sdids"];
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [manager delEndpoint:dids[0] completionHandler:nil];
    [manager delEndpoint:sdids[0] completionHandler:nil];
    NSDictionary *dic = @{@"status":@(0), @"msg":@"ok"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//打开设备属性页，跳转到 Native 页面
- (void)openDevicePropertyPage:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];

    NSString *did = param[@"did"];
    
    if ([BLCommonTools isEmpty:did]) {
        EndpointDetailController* vc = [EndpointDetailController viewController];
        vc.isNeedDeviceControl = NO;
        vc.endpoint = manager.currentEndpointInfo;
        
        [self.viewController.navigationController pushViewController:vc animated:YES];
        
    } else {
        NSArray *endpointList = manager.endpointList;
        
        for (BLSEndpointInfo *info in endpointList) {
            if ([info.endpointId isEqualToString:did]) {
                manager.currentEndpointInfo = info;

                BLDNADevice *device = [info toDNADevice];
                [[BLLet sharedLet].controller addDevice:device];
                
                EndpointDetailController* vc = [EndpointDetailController viewController];
                vc.isNeedDeviceControl = NO;
                vc.endpoint = info;
                
                [self.viewController.navigationController pushViewController:vc animated:YES];
                break;
            }
        }
    }
    
    NSDictionary *dic = @{@"status":@0, @"msg":@"ok"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openGatewaySubProductCategoryListPage:(CDVInvokedUrlCommand *) command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
    NSString *gatewayDid = param[@"did"];
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    BLDNADevice *gatewayDevice = [deviceService.manageDevices objectForKey:gatewayDid];

    if (gatewayDevice) {
        GateWayViewController *gateWayVC = [GateWayViewController viewController];
        deviceService.selectDevice = gatewayDevice;
        [self.viewController.navigationController pushViewController:gateWayVC animated:YES];
    }

    NSDictionary *dic = @{@"status":@(0), @"msg":@"ok"};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)deviceAuth:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    BLDNADevice *selectDevice = deviceService.selectDevice;
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [manager addAuthWithDid:selectDevice param:param completionHandler:^(BLSAddAuthResult * _Nonnull result) {
        NSDictionary *dic = @{@"did":[selectDevice getDid], @"ticket":result.ticket?:@"", @"authid":result.authid?:@"", @"status":@(result.status)};
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}

- (void)checkDeviceAuth:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    BLDNADevice *selectDevice = deviceService.selectDevice;
    NSDictionary *dic = @{@"did":[selectDevice getDid], @"ticket":@"", @"status":@0};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getDeviceVirtualGroups:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
    NSDictionary *dic = @{@"vGroups": @[@{@"vDevice": @{@"category":@"LIGHT",@"name":@"" , @"showIcon":@"", @"itemIcon":@"", @"h5ShowIcon":@""},@"name":@"一路", @"predefinedcategory": @[@"*"], @"params": @[@"pwr1"],}]
                          };
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)deviceLinkageParamsSet:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);

    NSDictionary *dic = @{@"status":@0, @"data":@{}};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openProductAddPage:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
    NSString *gatewayDid = param[@"gatewayDid"];
    NSString *pid = param[@"pid"];
    
    NSDictionary *dic = @{@"status":@0, @"pid":pid};
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[self p_toJsonString:dic]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)saveSceneCmds:(CDVInvokedUrlCommand *)command {
    NSDictionary *param = [self parseArguments:command.arguments.firstObject];
    NSLog(@"BLDeviceWebControlPlugin method: %@, param: %@", command.methodName, param);
    
    NSString *gatewayDid = param[@"gatewayDid"];
    
    NSDictionary *dic = @{@"gatewayDid":gatewayDid};
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

- (void)getDomainOrIpWithServiceName:(NSString *)serviceName infName:(NSString *)interfaceName command:(CDVInvokedUrlCommand *)command {
    NSString *url = nil;
    if ([serviceName isEqualToString:@"irservice"]) {
        url = [NSString stringWithFormat:@"%@rccode.ibroadlink.com", [BLConfigParam sharedConfigParam].licenseId];
    } else if ([serviceName isEqualToString:@"feedbackservice"]) {
        url = [NSString stringWithFormat:@"%@bizfeedback.ibroadlink.com", [BLConfigParam sharedConfigParam].licenseId];
    } else {
        url = [NSString stringWithFormat:@"%@appservice.ibroadlink.com", [BLConfigParam sharedConfigParam].licenseId];
    }
    NSString *retStr = [self getDomainOrIpWithUrl:url infName:interfaceName];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:retStr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSString *)getDomainOrIpWithUrl:(NSString *)url infName:(NSString *)interfaceName {
    NSDictionary *retDic = nil;
    if ([interfaceName isEqualToString:@"URL_HOST_NAME"]) {
        retDic = @{@"hostName" : url,
                   @"protocol" : @"https"
                   };
        return [self p_toJsonString:retDic];
    } else if ([interfaceName isEqualToString:@"URL_HOST_IP"]) {
        NSString *ipAddress = [BLNetworkImp getIpAddrFromHost:url];
        retDic = @{@"hostIP" : ipAddress,
                   @"protocol" : @"https"
                   };
        return [self p_toJsonString:retDic];
    }
    return nil;
}

- (NSString *)getInfUrlWithName:(NSString *)infName srvName:(NSString *)srvName {
    if ([srvName isEqualToString:@"dataservice"]) {                 //数据服务的具体接口由服务名(serviceName)和接口名组成(interfaceName)
        return [NSString stringWithFormat:@"%@/%@",srvName,infName];
    } else if ([srvName isEqualToString:@"irservice"]) {            //红码服务使用RM的域名,serviceName为publicircode，接口名(interfaceName)H5传递
        return [NSString stringWithFormat:@"/publicircode/%@", infName];
    } else if ([srvName isEqualToString:@"feedbackservice"]) {
        return [NSString stringWithFormat:@"/ec4%@",infName];
    }
    return @"";
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
