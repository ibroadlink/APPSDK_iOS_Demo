//
//  MeterInfo.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/7/1.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeterInfo : NSObject

typedef NS_ENUM(NSInteger, RELAY_STATE_ENUM) {
    RELAY_STATE_CONNECTED,
    RELAY_STATE_DISCONNECTED
};

//状态
@property (nonatomic, assign) NSInteger state;
//余额
@property (nonatomic, assign) double balance;
//time
@property (nonatomic, strong) NSString *time;
//继电器状态
@property (nonatomic, assign) RELAY_STATE_ENUM relayState;
//正向有功总功率
@property (nonatomic, assign) double positiveActivePower;
//正向有功总能量
@property (nonatomic, assign) double positiveActiveEnergy;
//正向有功费率1能量
@property (nonatomic, assign) double positiveActiveEnergyRate1;
//正向有功费率2能量
@property (nonatomic, assign) double positiveActiveEnergyRate2;
//正向有功费率3能量
@property (nonatomic, assign) double positiveActiveEnergyRate3;
//正向有功费率4能量
@property (nonatomic, assign) double positiveActiveEnergyRate4;
//秘钥版本号
@property (nonatomic, assign) int secretKeyVision;
//费率
@property (nonatomic, assign) double rate;

@end

NS_ASSUME_NONNULL_END
