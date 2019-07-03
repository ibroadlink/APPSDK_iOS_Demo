//
//  RechargeInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/7/1.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RechargeInfo : NSObject

//状态
@property (nonatomic, assign) NSInteger state;
//充值额度
@property (nonatomic, assign) double rechargeValue;
//余额
@property (nonatomic, assign) double balance;

@end

NS_ASSUME_NONNULL_END
