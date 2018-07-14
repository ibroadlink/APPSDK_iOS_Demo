//
//  BLDeviceService.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/11/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BLDeviceService.h"

@implementation BLDeviceService

static BLDeviceService *deviceService = nil;

+ (instancetype)sharedDeviceService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceService = [[BLDeviceService alloc] init];
    });
    
    return deviceService;
}

@end
