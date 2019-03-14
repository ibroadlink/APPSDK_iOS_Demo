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
    
    BLApiUrls *apiUrls = [BLApiUrls sharedApiUrl];
    self.iconUrlString = [apiUrls familyCommonUrlWithPath:[NSString stringWithFormat:@"/ec4/v1/system/configfile%@", dic[@"icon"]]];
    self.configPicUrlString = [apiUrls familyCommonUrlWithPath:[NSString stringWithFormat:@"/ec4/v1/system/configfile%@", dic[@"configpic"]]];
    self.shortCutIconUrlString = [apiUrls familyCommonUrlWithPath:[NSString stringWithFormat:@"/ec4/v1/system/configfile%@", dic[@"shortcuticon"]]];
    self.resetPic = [apiUrls familyCommonUrlWithPath:[NSString stringWithFormat:@"/ec4/v1/system/configfile%@", dic[@"resetpic"]]];
    self.beforeConfigHtml = [apiUrls familyCommonUrlWithPath:[NSString stringWithFormat:@"/ec4/v1/system/configfile%@", dic[@"beforecfgpurl"]]];
    self.failedHtml = [apiUrls familyCommonUrlWithPath:[NSString stringWithFormat:@"/ec4/v1/system/configfile%@", dic[@"cfgfailedurl"]]];
    
    return YES;
}


@end
