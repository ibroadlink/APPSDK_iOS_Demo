//
//  PassthroughResult.h
//  Let
//
//  Created by yzm on 16/5/17.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLPassthroughResult : BLBaseResult

/**
 Passthrough raw data
 */
@property (nonatomic, strong, getter=getData) NSData *data;

@end
