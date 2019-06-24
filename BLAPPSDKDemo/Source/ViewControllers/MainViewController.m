//
//  MainViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/25.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "MainViewController.h"
#import "LoginsTableViewController.h"
#import "UserViewController.h"
#import "FamilyListViewController.h"
#import "DeviceMainViewController.h"
#import "IRCodeTestViewController.h"
#import "ProductListViewController.h"
#import "PushViewController.h"

#import "BLUserDefaults.h"
#import "BLStatusBar.h"

@interface MainViewController ()

- (IBAction)buttonClick:(UIButton *)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)buttonClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
            [self gotoAccountViewController];
            break;
        case 101:
            [self gotoFamilyViewController];
            break;
        case 102:
            [self gotoDeviceViewController];
            break;
        case 103:
            [self gotoIRCodeViewController];
            break;
        case 104:
            [self gotoProductViewController];
            break;
        case 105:
            [self gotoPushViewController];
            break;
        default:
            break;
    }
}

- (void)gotoAccountViewController {
    if ([self hasBeenLogined]) {
        UserViewController *vc = [UserViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        LoginsTableViewController *vc = [LoginsTableViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)gotoFamilyViewController {
    if ([self hasBeenLogined]) {
        FamilyListViewController *vc = [FamilyListViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
    }
}

- (void)gotoDeviceViewController {
    DeviceMainViewController *vc = [DeviceMainViewController viewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoIRCodeViewController {
    if ([self hasBeenLogined]) {
        IRCodeTestViewController *vc = [IRCodeTestViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
    }
}

- (void)gotoProductViewController {
    if ([self hasBeenLogined]) {
        ProductListViewController *vc = [ProductListViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
    }
}

- (void)gotoPushViewController {
    if ([self hasBeenLogined]) {
        PushViewController *vc = [PushViewController viewController];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [BLStatusBar showTipMessageWithStatus:@"Please login first!!!"];
    }
}

- (BOOL)hasBeenLogined {
    BLUserDefaults *userDefaults = [BLUserDefaults shareUserDefaults];
    NSString *userId = [userDefaults getUserId];
    NSString *loginSession = [userDefaults getSessionId];
    if (userId && loginSession) {
        return YES;
    } else {
        return NO;
    }
    
}

@end
