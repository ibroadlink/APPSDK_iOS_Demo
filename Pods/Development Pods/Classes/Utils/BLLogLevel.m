//
//  BLLogLevel.m
//  BLLetBase
//
//  Created by zhujunjie on 2017/12/27.
//  Copyright © 2017年 zhujunjie. All rights reserved.
//

#import "BLLogLevel.h"

@implementation BLLogLevel

+ (instancetype)sharedLevel {
    static BLLogLevel *sharedLevel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLevel = [[BLLogLevel alloc] init];
        sharedLevel.level = 0;
    });
    
    return sharedLevel;
}

@end
