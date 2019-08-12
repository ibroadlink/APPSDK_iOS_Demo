//
//  APConfigTableViewController.m
//  SDKDemo
//
//  Created by 白洪坤 on 2017/7/25.
//  Copyright © 2017年 BroadLink Co., Ltd. All rights reserved.
//

#import "APConfigTableViewController.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"
#import "MBProgressHUD.h"

@interface APConfigTableViewController (){
    BLController *_controller;
    
}
@property (nonatomic,strong)NSArray *apListArray;
@end

@implementation APConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.apListArray = [NSArray array];
    [self refresh];
}
- (IBAction)refresh:(id)sender {
    [self refresh];
}

- (void)refresh {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"deviceAPList start");
        BLGetAPListResult *apconfigResult = [[BLLet sharedLet].controller deviceAPList:7000];
        NSLog(@"deviceAPList: %@", apconfigResult);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([apconfigResult succeed]) {
                self.apListArray = apconfigResult.list;
                NSLog(@"_apListArray: %@", self.apListArray);
                [self.tableView reloadData];
            }else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"deviceAPList staus:%ld,msg:%@",(long)apconfigResult.status,apconfigResult.msg]];
            }
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    BLAPInfo *APinfo = self.apListArray[indexPath.row];
    NSString *ssidtxt = APinfo.ssid;
    NSInteger ssidType = APinfo.type;
    cell.textLabel.text = ssidtxt;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)ssidType];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = @"APConfig";
    NSString *acceptTitle = @"Config";
    NSString *cancelTitle = @"Cancel";
    BLAPInfo *APinfo = self.apListArray[indexPath.row];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text =  APinfo.ssid;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:acceptTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *ssidtxt = alertController.textFields.firstObject;
        UITextField *passwordtxt = alertController.textFields.lastObject;

        NSLog(@"apconfigResult start");
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        BLAPConfigResult *apconfigResult = [[BLLet sharedLet].controller deviceAPConfig:ssidtxt.text password:passwordtxt.text type:APinfo.type];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([apconfigResult succeed]) {
            NSLog(@"apconfig success:did--%@,pid--%@,ssid--%@,devkey--%@",apconfigResult.did,apconfigResult.pid,apconfigResult.ssid,apconfigResult.devkey);
            [self viewBack];
        }else {
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"deviceAPConfig staus:%ld,msg:%@",(long)apconfigResult.status,apconfigResult.msg]];
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewBack {
    [self.navigationController popToRootViewControllerAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}


@end
