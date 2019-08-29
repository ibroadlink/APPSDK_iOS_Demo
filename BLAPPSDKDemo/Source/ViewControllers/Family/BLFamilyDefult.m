//
//  BLSFamilyManager.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/19.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BLFamilyDefult.h"

#define UPDATA_ICON_MAXLIMIT            (2014 * 512)

@implementation BLFamilyDefult

+ (instancetype)sharedFamily {
    static dispatch_once_t onceToken;
    static BLFamilyDefult *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}


@end
