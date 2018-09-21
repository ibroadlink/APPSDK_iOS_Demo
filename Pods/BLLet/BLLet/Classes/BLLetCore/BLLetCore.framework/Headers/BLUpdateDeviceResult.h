//
//  UpdateDeviceResult.h
//  Let
//
//  Created by yzm on 16/5/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLUpdateDeviceResult : BLBaseResult

/**
 Device lock status
 */
@property (nonatomic, assign, getter=isLock) Boolean lock;

/**
 Device name
 */
@property (nonatomic, strong, getter=getName) NSString *name;

@end
