//
//  DNADevice.h
//  Let
//
//  Created by yzm on 16/5/16.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>

@interface BLSDNADevice : NSObject

#pragma mark - Device common propertis

/**
 This ID is assigned when the device is added to the SDK.
 deviceId = did + pDid + ownerId;
 */
@property (nonatomic, strong, readonly) NSString *deviceId;

/**
 Device did.
 */
@property (nonatomic, strong, getter=getDid) NSString *did;

/**
 Device's owner id.
 It is used for discriminate same did in different owner.
 */
@property (nonatomic, copy) NSString *ownerId;

/**
 Device product id.
 The same product devices have same pid.
 */
@property (nonatomic, strong, getter=getPid) NSString *pid;

/**
 Device type
 The same product devices have same type.
 */
@property (nonatomic, assign, getter=getType) NSUInteger type;

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

/**
 类型，实体设备(0),其他平台虚拟设备(1),分组设备(2),分路设备(3),功能模块虚拟设备(4)
 */
@property (nonatomic, assign) NSUInteger deviceFlag;

/**
 包含的设备
 */
@property (nonatomic, strong) NSArray *containDevices;

- (NSString *)toJsonString;
@end
