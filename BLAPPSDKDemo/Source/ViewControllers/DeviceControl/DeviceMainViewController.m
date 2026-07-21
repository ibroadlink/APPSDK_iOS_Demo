//
//  DeviceMainViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DeviceMainViewController.h"
#import "MyDeviceListViewController.h"
#import "DeviceStressTestController.h"
#import "BLTheme.h"

#import "DeviceDB.h"
#import "BLUserDefaults.h"

@implementation DeviceMainViewController

+ (instancetype)viewController {
    DeviceMainViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Device";
    NSArray *items = @[
        @{@"title": @"Network Config", @"desc": @"SmartConfig / AP provisioning", @"symbol": @"wifi", @"tag": @101},
        @{@"title": @"Probe In LAN", @"desc": @"Discover nearby devices", @"symbol": @"magnifyingglass", @"tag": @102},
        @{@"title": @"My Device List", @"desc": @"Paired devices & control", @"symbol": @"list.bullet", @"tag": @103},
        @{@"title": @"Stress Test", @"desc": @"Device control pressure test", @"symbol": @"hammer.fill", @"tag": @104},
    ];
    [BLTheme installMenuListOnView:self.view
                             title:@"Device"
                          subtitle:@"Configure, discover and manage devices"
                             items:items
                            target:self
                            action:@selector(menuAction:)];
}

- (void)menuAction:(UIButton *)sender {
    switch (sender.tag) {
        case 101: [self configDevices:sender]; break;
        case 102: [self probeInLan:sender]; break;
        case 103: [self myDeviceList:sender]; break;
        case 104: [self pushToDeviceStressTestView:sender]; break;
        default: break;
    }
}

- (IBAction)configDevices:(id)sender {
    [self performSegueWithIdentifier:@"ConfigureView" sender:nil];
}

- (IBAction)probeInLan:(id)sender {
    [self performSegueWithIdentifier:@"DeviceListView" sender:nil];
}

- (IBAction)myDeviceList:(id)sender {
    [self performSegueWithIdentifier:@"MyDeviceListView" sender:nil];
}

- (IBAction)pushToDeviceStressTestView:(id)sender {
    DeviceStressTestController *vc = [DeviceStressTestController viewController];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
