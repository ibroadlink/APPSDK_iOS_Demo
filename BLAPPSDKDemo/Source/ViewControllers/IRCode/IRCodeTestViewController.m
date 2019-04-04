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
#import "BrandSelectController.h"

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
    UIAlertAction *cateGories = [UIAlertAction actionWithTitle:@"Choose Brand Model" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CateGoriesTableViewController *vc = [CateGoriesTableViewController viewController];
        vc.devtype = BL_IRCODE_DEVICE_AC;
        [self.navigationController pushViewController:vc animated:YES];
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
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"TV Code selection" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cateGories = [UIAlertAction actionWithTitle:@"Choose Brand Model" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CateGoriesTableViewController *vc = [CateGoriesTableViewController viewController];
        vc.devtype = BL_IRCODE_DEVICE_TV;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *keyIdentify = [UIAlertAction actionWithTitle:@"Match Tree" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        BrandSelectController *vc = [BrandSelectController viewController];
        vc.devtype = BL_IRCODE_DEVICE_TV;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:cateGories];
    [alertController addAction:keyIdentify];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)tvBoxIRCodeSelect {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"TV Code selection" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cateGories = [UIAlertAction actionWithTitle:@"Choose Brand Model" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TVBoxAreaSelectController *vc = [TVBoxAreaSelectController viewController];
        IRCodeSubAreaInfo *area = [[IRCodeSubAreaInfo alloc] init];
        vc.currentArea = area;
        
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *keyIdentify = [UIAlertAction actionWithTitle:@"Match Tree" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        BrandSelectController *vc = [BrandSelectController viewController];
        vc.devtype = BL_IRCODE_DEVICE_TV_BOX;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:cateGories];
    [alertController addAction:keyIdentify];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
