//
//  IRCodeTestViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/24.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "IRCodeTestViewController.h"
#import "TVBoxAreaSelectController.h"
#import "CateGoriesTableViewController.h"
#import "AKeyToIdentifyViewController.h"

#import "BLStatusBar.h"
#import <BLLetIRCode/BLLetIRCode.h>

@interface IRCodeTestViewController ()

@end

@implementation IRCodeTestViewController

+ (instancetype)viewController {
    IRCodeTestViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)button:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
            [self acIRCodeSelect];
            break;
        case 101:
            [self tvIRCodeSelect];
            break;
        case 102:
            [self tvBoxIRCodeSelect];
            break;
        default:
            break;
    }
}

- (void)acIRCodeSelect {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"AC Code selection" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cateGories = [UIAlertAction actionWithTitle:@"Brand selection" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CateGoriesTableViewController *vc = [CateGoriesTableViewController viewController];
            vc.devtype = BL_IRCODE_DEVICE_AC;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
    UIAlertAction *keyIdentify = [UIAlertAction actionWithTitle:@"Code one key recognition" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"aKeyToIdentify" sender:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:cateGories];
    [alertController addAction:keyIdentify];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)tvIRCodeSelect {
    dispatch_async(dispatch_get_main_queue(), ^{
        CateGoriesTableViewController *vc = [CateGoriesTableViewController viewController];
        vc.devtype = BL_IRCODE_DEVICE_TV;
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)tvBoxIRCodeSelect {
    TVBoxAreaSelectController *vc = [TVBoxAreaSelectController viewController];
    IRCodeSubAreaInfo *area = [[IRCodeSubAreaInfo alloc] init];
    vc.currentArea = area;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
