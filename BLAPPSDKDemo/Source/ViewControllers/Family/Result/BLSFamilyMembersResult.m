//
//  BLSFamilyMembersResult.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSFamilyMembersResult.h"

@implementation BLSFamilyMember

@end

@implementation BLSFamilyMembersResult

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"memberList":[BLSFamilyMember class]
             };
}

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"memberList":@"data.familymember"
             };
}

@end
