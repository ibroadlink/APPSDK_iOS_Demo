//
//  BLSFamilyListResult.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSFamilyListResult.h"
#import "BLSFamilyInfo.h"

@implementation BLSFamilyListResult
+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"familyList":[BLSFamilyInfo class]
             };
}

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"familyList":@"data.familyList"
             };
}

@end
