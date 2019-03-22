//
//  BLDeviceService.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/11/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BLDeviceService.h"
#import "DeviceDB.h"

@interface BLDeviceService() <BLControllerDelegate>

@property (nonatomic, strong) NSTimer *checkTimer;

@end

@implementation BLDeviceService

static BLDeviceService *_deviceService = nil;

+ (instancetype)sharedDeviceService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceService = [[BLDeviceService alloc] init];
    });
    
    return _deviceService;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [BLLet sharedLet].controller.delegate = self;
        [self readDevicesInDb];
    }
    return self;
}

- (void)dealloc {
    [self stopDeviceManagment];
}

#pragma mark - public method
- (void)startDeviceManagment {
    [[BLLet sharedLet].controller startProbe:3000];
    
    if (![self.checkTimer isValid]) {
        __weak __typeof(self)weakSelf = self;
        self.checkTimer = [BLCommonTools bl_socheduledTimerWithTimeInterval:3.0f
                                                                      block:^{
                                                                          __strong __typeof(weakSelf) strongSelf = weakSelf;
                                                                          [strongSelf checkDeviceCache];
                                                                      }
                                                                    repeats:YES];
        
        [self.checkTimer fire];
    }
}

- (void)stopDeviceManagment {
    [[BLLet sharedLet].controller stopProbe];
    
    if (self.checkTimer && [self.checkTimer isValid]) {
        [self.checkTimer invalidate];
        self.checkTimer = nil;
    }
}

- (void)readDevicesInDb {
    //从数据库取出所有设备加入SDK管理
    self.manageDevices = [NSMutableDictionary dictionaryWithCapacity:0];
    NSArray *storeDevices = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
    [[BLLet sharedLet].controller addDeviceArray:storeDevices];
    
    for (BLDNADevice *device in storeDevices) {
        NSString *did = device.did;
        [self.manageDevices setObject:device forKey:did];
    }
}

- (void)addNewDeivce:(BLDNADevice *)device {
    NSString *did = device.did;
    BLDNADevice *manageDevice = [self.manageDevices objectForKey:did];
    if (!manageDevice) {
        [self.manageDevices setObject:device forKey:did];
        [[BLLet sharedLet].controller addDevice:device];
        [[DeviceDB sharedOperateDB] insertSqlWithDevice:device];
    }
}

- (void)removeDevice:(NSString *)did {
    BLDNADevice *device = self.manageDevices[did];
    if (device) {
        [self.manageDevices removeObjectForKey:did];
        [[BLLet sharedLet].controller removeDevice:device];
        [[DeviceDB sharedOperateDB] deleteWithinfo:device];
    }
}

- (void)checkDeviceCache {
    
    if (self.scanDevices.allKeys.count > 0) {
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSinceReferenceDate];
        
        for (int i = 0; i < self.scanDevices.allKeys.count; i++) {
            NSString *did = self.scanDevices.allKeys[i];
            BLDNADevice *obj = self.scanDevices[did];
            
            if (obj != nil) {
                if ((nowTime - obj.lastStateRefreshTime) > 15) {
                    @synchronized (self.scanDevices) {
                        [self.scanDevices removeObjectForKey:did];
                    }
                }
            }
        }
    }
}

#pragma mark - BLControllerDelegate
- (void)onDeviceUpdate:(BLDNADevice *)device isNewDevice:(Boolean)isNewDevice {
    //Only device reset, newconfig=1
    //Not all device support this.
    //NSLog(@"=====probe device did(%@) newconfig(%hhu)====", device.did, device.newConfig);
    
    if (device.did) {
        [self.scanDevices setObject:device forKey:device.did];
    }
    
}

- (void)statusChanged:(BLDNADevice *)device status:(BLDeviceStatusEnum)status {
    
}

#pragma mark - property
- (NSMutableDictionary *)scanDevices {
    if (!_scanDevices) {
        _scanDevices = [[NSMutableDictionary alloc] init];
    }
    return _scanDevices;
}

@end
