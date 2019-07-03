//
//  BLEDeviceViewController.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/6/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLEDeviceViewController : BaseViewController

@property(nonatomic, strong) CBPeripheral *currentPeripheral;

+ (instancetype)viewController;

@end

NS_ASSUME_NONNULL_END
