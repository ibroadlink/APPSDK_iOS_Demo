//
//  BLSubDevListResult.h
//  Let
//
//  Created by junjie.zhu on 2016/10/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLSubdevBaseResult.h"
#import "BLDNADevice.h"

@interface BLSubDevListResult : BLSubdevBaseResult

/**
 Sub device total number
 */
@property (nonatomic, assign) NSInteger total;

/**
 This query index
 */
@property (nonatomic, assign) NSInteger index;

/**
 Sub device list
 */
@property (nonatomic, copy) NSArray<BLDNADevice *>* list;

@end
