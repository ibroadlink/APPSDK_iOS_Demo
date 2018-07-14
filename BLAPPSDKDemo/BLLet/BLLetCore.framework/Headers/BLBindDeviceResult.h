//
//  BindDeviceResult.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLBindDeviceResult : BLBaseResult

/**
 Device bind map
 */
@property (nonatomic, strong, getter=getBindmap) NSArray<NSNumber *> *bindmap;

@end
