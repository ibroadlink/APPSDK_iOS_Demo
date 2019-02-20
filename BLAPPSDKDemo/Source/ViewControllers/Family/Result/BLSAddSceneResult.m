//
//  BLSAddSceneResult.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSAddSceneResult.h"

@implementation BLSAddSceneResult
+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"sceneId": @"data.sceneId"
             };
}

@end
