//
//  TaskDataResult.h
//  Let
//
//  Created by yzm on 16/5/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>
#import "BLStdData.h"

@interface BLTaskDataResult : BLBaseResult

/**
 Task control data object
 */
@property (nonatomic, strong, getter=getData) BLStdData *data;

@property (nonatomic, strong, getter=getData2) BLStdData *data2;

@end
