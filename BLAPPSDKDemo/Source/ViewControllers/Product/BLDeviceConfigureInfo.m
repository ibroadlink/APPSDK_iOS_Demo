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

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    return @{@"deviceName":@"name",
             @"moduleName":@"model",
             @"brand":@"brandname",
             @"configText":@"configtext",
             @"resetText":@"resettext"
             };
}

// 声明自定义类参数类型
+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    return @{@"introduction" : [BLDeviceConfigIntroduction class]
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
