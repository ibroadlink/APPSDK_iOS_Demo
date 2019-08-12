//
//  BLSSceneInfo.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/20.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLSSceneInfo.h"

@implementation BLSSceneDevContent


@end

@implementation BLSSceneDev

@end

@implementation BLSSceneInfo

+ (NSDictionary *)BLS_modelContainerPropertyGenericClass {
    
    return @{
             @"scenedev":[BLSSceneDev class]
             };
}

@end
