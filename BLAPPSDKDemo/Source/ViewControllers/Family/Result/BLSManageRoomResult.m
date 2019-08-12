//
//  BLSManageRoomResult.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSManageRoomResult.h"

@implementation BLSManageRoomResult
+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"roomInfos":[BLSRoomInfo class]
             };
}


+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"roomInfos": @[@"data.roomList", @"data.addroom"]
             };
}


@end
