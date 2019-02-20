//
//  BLSQueryScenesResult.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSQueryScenesResult.h"

@implementation BLSQueryScenesResult

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"scenes":[BLSSceneInfo class]
             };
}


+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"scenes": @"data.scenes"
             };
}


@end
