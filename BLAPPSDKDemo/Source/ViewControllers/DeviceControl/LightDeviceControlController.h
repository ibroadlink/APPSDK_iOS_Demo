//
//  LightDeviceControlController.h
//  BLAPPSDKDemo
//
//  Created by admin on 2019/7/10.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "BaseViewController.h"
#import "BLDeviceService.h"

NS_ASSUME_NONNULL_BEGIN

@interface LightDeviceControlController : BaseViewController

@property (nonatomic, strong) BLDNADevice *device;

+ (instancetype)viewController;

@end

NS_ASSUME_NONNULL_END
