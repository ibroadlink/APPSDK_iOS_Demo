//
//  BLIRCodeDataResult.h
//  Let
//
//  Created by junjie.zhu on 2017/1/23.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

@interface BLIRCodeDataResult : BLBaseResult

/**
 Ircode send frequency
 */
@property(nonatomic, assign)NSInteger freq;

/**
 Ircode send hex string
 */
@property(nonatomic, strong)NSString *ircode;

@end
