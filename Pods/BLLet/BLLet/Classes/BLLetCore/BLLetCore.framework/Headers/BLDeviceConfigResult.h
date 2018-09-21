//
//  DeviceConfigResult.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLDeviceConfigResult : BLBaseResult

/**
 Device ip address
 */
@property (nonatomic, strong, getter=getDevaddr) NSString *devaddr;

/**
 Device mac
 */
@property (nonatomic, strong, getter=getMac) NSString *mac;

/**
 Device did
 */
@property (nonatomic, strong, getter=getDid) NSString *did;

@end
