//
//  BLDeviceConfigureInfo.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLDeviceConfigureInfo.h"
#import <BLLetBase/BLLetBase.h>

@implementation BLDeviceConfigureInfo

/*
 _deviceName = subDic[@"name"];
 _moduleName = subDic[@"model"];
 _brand = subDic[@"brandname"];
 _pid = subDic[@"pid"];
 _failedHtml = [self htmlStringWithPicUrlString:subDic[@"cfgfailedurl"]];
 _beforeConfigHtml = [self htmlStringWithPicUrlString:subDic[@"beforecfgpurl"]];
 _iconUrlString = BL_URL_APPMANAGE(BL_GET_ICON_URL_PRI(subDic[@"icon"]));//设备图标的url
 _configPicUrlString = BL_URL_APPMANAGE(BL_GET_ICON_URL_PRI(subDic[@"configpic"]));//配置图片的url
 _shortCutIconUrlString = BL_URL_APPMANAGE(BL_GET_ICON_URL_PRI(subDic[@"shortcuticon"]));
 _resetPic = BL_URL_APPMANAGE(BL_GET_ICON_URL_PRI(subDic[@"resetpic"]));
 _resetText = subDic[@"resettext"];
 _configText = subDic[@"configtext"];
 _iconsArray = subDic[@"ads"];
 _pids = subDic[@"pids"];
 _mappid = subDic[@"mappid"];
 if (!_pids || [_pids isKindOfClass:[NSNull class]]) {
 _pids = nil;
 }
 NSMutableArray *temp = [NSMutableArray new];
 if (![subDic[@"introduction"] isKindOfClass:[NSNull class]]) {
 [subDic[@"introduction"] enumerateObjectsUsingBlock:
 ^(id obj, NSUInteger idx, BOOL *stop) {
 BLDeviceConfigIntroduction *introduction = [BLDeviceConfigIntroduction new];
 NSDictionary *dic = (NSDictionary *)obj;
 introduction.introductionTitle = dic[@"name"];
 introduction.introductionHtml = [self htmlStringWithPicUrlString:dic[@"url"]];
 [temp addObject: introduction];
 }];
 }
 _introductions = [NSArray arrayWithArray:temp];
 _profile = subDic[@"profile"];
 _protocol = subDic[@"protocol"];
 */
+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    return @{@"deviceName":@"name",
             @"moduleName":@"model",
             @"brand":@"brandname",
             @"iconsArray":@"ads",
             @"configText":@"configtext",
             @"resetText":@"resettext"
             };
}

- (BOOL)BLS_modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.iconUrlString = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/configfile%@",[BLConfigParam sharedConfigParam].licenseId,dic[@"icon"]];
    self.configPicUrlString = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/configfile%@",[BLConfigParam sharedConfigParam].licenseId,dic[@"configpic"]];
    self.shortCutIconUrlString = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/configfile%@",[BLConfigParam sharedConfigParam].licenseId,dic[@"shortcuticon"]];
    self.resetPic = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/configfile%@",[BLConfigParam sharedConfigParam].licenseId,dic[@"resetpic"]];
    self.beforeConfigHtml = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/configfile%@",[BLConfigParam sharedConfigParam].licenseId,dic[@"beforecfgpurl"]];
    self.failedHtml = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/configfile%@",[BLConfigParam sharedConfigParam].licenseId,dic[@"cfgfailedurl"]];
    return YES;
}

@end
