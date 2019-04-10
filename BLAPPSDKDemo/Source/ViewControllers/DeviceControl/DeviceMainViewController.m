//
//  MainViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DeviceMainViewController.h"
#import "MyDeviceListViewController.h"
#import "DeviceStressTestController.h"

#import "DeviceDB.h"
#import "BLUserDefaults.h"

@interface DeviceMainViewController ()

@property (nonatomic, strong) NSArray *titles;

@end

@implementation DeviceMainViewController

+ (instancetype)viewController {
    DeviceMainViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
