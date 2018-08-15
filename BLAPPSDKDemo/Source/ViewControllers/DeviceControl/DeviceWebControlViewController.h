//
//  DeviceWebControlViewController.h
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/31.
//  Copyright © 2016年 BroadLink. All rights reserved.
//
#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>

@class BLDNADevice;

@interface DeviceWebControlViewController : CDVViewController

@property (nonatomic, strong) BLDNADevice *selectDevice;
@property (nonatomic, strong) NSString *subDevicePid;
@end

@interface DeviceControlIndexCommandDelegate : CDVCommandDelegateImpl

@end


@interface DeviceControlIndexCommandQueue : CDVCommandQueue

@end
