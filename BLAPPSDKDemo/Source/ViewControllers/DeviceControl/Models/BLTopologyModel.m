//
//  BLTopologyModel.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/11/22.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLTopologyModel.h"

@implementation BLTopologyDevice



@end

@implementation BLTopologyModel

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"deviceList":[BLTopologyDevice class]
             };
}

+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"count":@"data.count",
             @"deviceList":@"data.deviceList"
             };
}
@end
