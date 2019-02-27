//
//  BLProductCategoryModel.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/2/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLProductCategoryModel.h"
#import <BLLetBase/BLLetBase.h>
@implementation BLProductCategoryModel
- (BOOL)BLS_modelCustomTransformFromDictionary:(NSDictionary *)dic {
    self.link = [NSString stringWithFormat:@"https://%@bizappmanage.ibroadlink.com/ec4/v1/system/configfile/staticfilesys%@",[BLConfigParam sharedConfigParam].licenseId,dic[@"link"]];
    return YES;
}

@end
