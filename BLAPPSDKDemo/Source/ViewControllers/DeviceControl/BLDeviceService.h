//
//  BLDeviceService.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/11/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetCore/BLLetCore.h>

@interface BLDeviceService : NSObject

+ (instancetype)sharedDeviceService;

@property (nonatomic, strong) NSMutableDictionary *scanDevices;     //Probe Devices in Lan
@property (nonatomic, strong) NSMutableDictionary *manageDevices;   //Device added into sdk

@property (nonatomic, strong) BLDNADevice *selectDevice;
@property (nonatomic, strong) BLDNADevice *gatewayDevice;

@property (nonatomic, copy) NSString *h5Data;               //存储H5调用接口的时候传递的data数据（当前地产项目使用到改数据）

- (void)startDeviceManagment;
- (void)stopDeviceManagment;

- (void)addNewDeivce:(BLDNADevice *)device;
- (void)removeDevice:(NSString *)did;

@end
