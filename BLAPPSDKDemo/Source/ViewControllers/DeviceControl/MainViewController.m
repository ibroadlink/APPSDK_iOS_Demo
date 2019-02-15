//
//  MainViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "MainViewController.h"
#import "MyDeviceListViewController.h"

#import "DeviceDB.h"
#import "BLUserDefaults.h"

@interface MainViewController ()

@property (nonatomic, strong) NSArray *titles;

@end

@implementation MainViewController {
    BLController *_blController;
}

+ (instancetype)viewController {
    MainViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _blController = [BLLet sharedLet].controller;
    
//    BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
//    BLAccount *account = [BLLet sharedLet].account;
//    [account getUserInfo:@[userDefault.getUserId] completionHandler:^(BLGetUserInfoResult * _Nonnull result) {
//
//    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MyDeviceListView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[MyDeviceListViewController class]]) {
            MyDeviceListViewController* myDeviceVC = (MyDeviceListViewController *)target;
            myDeviceVC.myDevices = [[NSMutableArray alloc] initWithArray:[[DeviceDB sharedOperateDB] readAllDevicesFromSql]];
        }
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


@end
