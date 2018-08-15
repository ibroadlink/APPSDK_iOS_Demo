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

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

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
    _titles = @[@"Probe Device In Lan", @"MyDevices", @"Config Devices"];
    _blController = [BLLet sharedLet].controller;
    
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
//    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    _mainTabel.delegate = self;
    _mainTabel.dataSource = self;
    [self setExtraCellLineHidden:_mainTabel];
    
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

//- (void)logout {
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//
//    BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
//    [userDefault setUserId:nil];
//    [userDefault setSessionId:nil];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MyDeviceListView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[MyDeviceListViewController class]]) {
            MyDeviceListViewController* myDeviceVC = (MyDeviceListViewController *)target;
            myDeviceVC.myDevices = [[NSMutableArray alloc] initWithArray:[[DeviceDB sharedOperateDB] readAllDevicesFromSql]];
        }
    }
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"MAIN_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = _titles[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            [self performSegueWithIdentifier:@"DeviceListView" sender:nil];
        }
            break;
        case 1: {
            [self performSegueWithIdentifier:@"MyDeviceListView" sender:nil];
        }
            break;
        case 2: {
            [self performSegueWithIdentifier:@"ConfigureView" sender:nil];
        }
            break;
        case 3: {
            [self performSegueWithIdentifier:@"OauthBind" sender:nil];
        }
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
