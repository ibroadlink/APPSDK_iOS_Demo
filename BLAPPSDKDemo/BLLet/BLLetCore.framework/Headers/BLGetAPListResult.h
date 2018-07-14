//
//  BLGetAPListResult.h
//  Let
//
//  Created by junjie.zhu on 2016/10/24.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <BLLetBase/BLLetBase.h>

/**
 AP info
 */
@interface BLAPInfo : NSObject

/**
 AP SSID
 */
@property (nonatomic, copy) NSString *ssid;

/**
 AP RSSI
 */
@property (nonatomic, assign) NSInteger rssi;

/**
 AP Type
 */
@property (nonatomic, assign) NSInteger type;

@end


@interface BLGetAPListResult : BLBaseResult

/**
 AP Info list
 */
@property (nonatomic, strong) NSArray<BLAPInfo *> *list;

@end
