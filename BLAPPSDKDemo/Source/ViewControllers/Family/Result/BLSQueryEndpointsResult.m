//
//  BLSQueryEndpointsResult.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSQueryEndpointsResult.h"

@implementation BLSQueryEndpointsResult

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"endpoints":[BLSEndpointInfo class]
             };
}


+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"endpoints": @"data.endpoints"
             };
}


@end
