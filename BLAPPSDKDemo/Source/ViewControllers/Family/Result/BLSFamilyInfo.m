//
//  BLSFamilyInfo.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSFamilyInfo.h"
#import <BLLetBase/BLLetBase.h>

@implementation BLSFamilyInfo

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"desc":@"description"
             };
}

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"roominfo":[BLSRoomInfo class]
             };
}

@end
