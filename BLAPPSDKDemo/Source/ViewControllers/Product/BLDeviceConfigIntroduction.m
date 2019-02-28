//
//  BLDeviceConfigIntroduction.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLDeviceConfigIntroduction.h"
#import <BLLetBase/BLLetBase.h>
@implementation BLDeviceConfigIntroduction

- (BOOL)BLS_modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.url = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/configfile%@",[BLConfigParam sharedConfigParam].licenseId,dic[@"url"]];
    self.icon = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/configfile%@",[BLConfigParam sharedConfigParam].licenseId,dic[@"icon"]];
    return YES;
}

@end
