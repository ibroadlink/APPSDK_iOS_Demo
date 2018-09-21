//
//  DNADevice.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>

@interface BLDNADevice : NSObject

#pragma mark - Device common propertis

/** 
 Device did. 
 Uniquely identifies to our device.
 */
@property (nonatomic, strong, getter=getDid) NSString *did;

/**
 Device product id.
 The same product devices have same pid.
 */
@property (nonatomic, strong, getter=getPid) NSString *pid;

/**
 Device name.
 */
@property (nonatomic, strong, getter=getName) NSString *name;

#pragma mark - Sub device properties

/**
 Sub device dependent WiFi device's did.
 */
@property (nonatomic, strong, getter=getPDid) NSString *pDid;

/**
 Sub device is added to WiFi device flag.
 */
@property (nonatomic, assign, getter=getAddFlag) NSInteger addFlag;

#pragma mark - WiFi device properties
/**
 Device Mac
 */
@property (nonatomic, strong, getter=getMac) NSString *mac;

/**
 Device type
 */
@property (nonatomic, assign, getter=getType) NSUInteger type;

/**
 Device is lock or not
 */
@property (nonatomic, assign, getter=getLock) Boolean lock;

/**
 Device is new configed wifi in last 5 min.
 */
@property (nonatomic, assign, getter=getNewConfig) Boolean newConfig;

/**
 Device control password, only first version device haved.
 */
@property (nonatomic, assign, getter=getPassword) NSUInteger password;

/**
 Device control id
 */
@property (nonatomic, assign, getter=getControlId) NSUInteger controlId;

/**
 Device control key
 */
@property (nonatomic, strong, getter=getControlKey) NSString *controlKey;

/**
 Device lan ip address
 */
@property (nonatomic, strong, getter=getLanaddr) NSString *lanaddr;

/**
 Device extend info
 */
@property (nonatomic, strong, getter=getExtendInfo) NSDictionary *extendInfo;

/**
 Device network status
 */
@property (nonatomic, assign, getter=getState) BLDeviceStatusEnum state;

/**
 最后状态刷新时间
 */
@property (nonatomic, assign) NSTimeInterval lastStateRefreshTime;

/**
 远程状态刷新flag
 */
@property (nonatomic, assign) Boolean refreshStateFlag;

- (instancetype)initWithDeviceInfoDic:(NSDictionary *)dic;

- (NSDictionary *)getBaseDictionary;

- (NSString *)toJsonString;
@end
