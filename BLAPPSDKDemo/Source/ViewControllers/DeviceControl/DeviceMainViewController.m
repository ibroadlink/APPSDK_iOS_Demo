//
//  DeviceMainViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DeviceMainViewController.h"
#import "ConfigureViewController.h"
#import "DeviceListViewController.h"
#import "MyDeviceListViewController.h"
#import "DeviceStressTestController.h"
#import "BLTheme.h"

@implementation DeviceMainViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Device";
    NSArray *items = @[
        @{@"title": @"Network Config",
          @"desc": @"SmartConfig / AP Wi-Fi provisioning",
          @"symbol": @"wifi",
          @"tag": @101},
        @{@"title": @"Probe In LAN",
          @"desc": @"Discover nearby devices and pair",
          @"symbol": @"dot.radiowaves.left.and.right",
          @"tag": @102},
        @{@"title": @"My Devices",
          @"desc": @"Paired devices, control & diagnostics",
          @"symbol": @"square.grid.2x2.fill",
          @"tag": @103},
        @{@"title": @"Stress Test",
          @"desc": @"Pressure-test device control APIs",
          @"symbol": @"hammer.fill",
          @"tag": @104},
    ];
    [BLTheme installMenuListOnView:self.view
                             title:@"Device"
                          subtitle:@"Configure, discover and manage BroadLink devices"
                             items:items
                            target:self
                            action:@selector(menuAction:)];
}

- (void)menuAction:(UIButton *)sender {
    UIViewController *vc = nil;
    switch (sender.tag) {
        case 101: vc = [ConfigureViewController viewController]; break;
        case 102: vc = [DeviceListViewController viewController]; break;
        case 103: vc = [MyDeviceListViewController viewController]; break;
        case 104: vc = [DeviceStressTestController viewController]; break;
        default: break;
    }
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
