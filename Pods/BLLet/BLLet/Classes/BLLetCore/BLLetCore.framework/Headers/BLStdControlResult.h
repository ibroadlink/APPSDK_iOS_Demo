//
//  StdControlResult.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLStdData.h"

@interface BLStdControlResult : BLBaseResult

/**
 Device control data object
 */
@property (nonatomic, strong, getter=getData) BLStdData *data;

@end
