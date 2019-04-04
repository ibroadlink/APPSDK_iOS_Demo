//
//  IRCodeMatchTreeInfo.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/4/3.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "IRCodeMatchTreeInfo.h"

@implementation TreeInfo

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{
             @"codeList":[CodeInfo class]
             };
}

@end

@implementation CodeInfo


@end

@implementation IRCodeMatchTreeInfo



+ (NSDictionary *)BLS_modelCustomPropertyMapper {
    
    return @{
             @"hotircode":@"hotircode.ircodeid",
             @"nobyteircode":@"nobyteircode.ircodeid",
             };
}

@end
