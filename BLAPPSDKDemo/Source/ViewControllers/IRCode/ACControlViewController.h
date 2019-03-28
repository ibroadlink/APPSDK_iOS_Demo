//
//  ControlViewController.h
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@class BLDNADevice;

@interface ACControlViewController : BaseViewController

@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) NSString *savePath;

+ (instancetype)viewController;

@end
