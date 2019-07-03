//
//  BLESMDataParser.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/7/1.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressInfo.h"
#import "RechargeInfo.h"
#import "BalanceInfo.h"
#import "MeterInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLESMDataParser : NSObject


/**
 获取表号

 @return
 */
+ (NSData *)genGetAddress;

/**
 生成充值命令

 @param token 用户输入的20位数字token字符串
 @param address 通讯地址
 @return
 */
+ (NSData *)genRechargeStringWithToken:(NSString *)token address:(NSString *)address;

/**
 生成余额查询命令

 @param address 通讯地址
 @return
 */
+ (NSData *)genBalanceWithAddress:(NSString *)address;

/**
 生成参数查询命令
 
 @param address 通讯地址
 @return
 */
+ (NSData *)genInquiryWithAddress:(NSString *)address;


/**
 获取命令解析

 @param data 获取数据
 @return 解析信息
 */
+ (id)parseBytes:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
