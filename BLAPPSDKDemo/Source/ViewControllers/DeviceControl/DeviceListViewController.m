//
//  DeviceListViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DeviceListViewController.h"
#import "AppDelegate.h"
#import "DeviceDB.h"

@interface DeviceListViewController ()

@property (strong, nonatomic) NSMutableArray *showDevices;
@property (strong, nonatomic) NSArray *myDevices;
@property (strong, nonatomic) NSArray *scanDevices;

@end

@implementation DeviceListViewController {
    BLController *_blController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    _blController = [BLLet sharedLet].controller;
    
    self.deviceListTableView.delegate = self;
    self.deviceListTableView.dataSource = self;
    [self setExtraCellLineHidden:self.deviceListTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)storeDeviceIndex:(NSInteger)index {
    if (index < _showDevices.count) {
        BLDNADevice *device = _showDevices[index];
        [_blController addDevice:device];
        //add device info to local db
        [[DeviceDB sharedOperateDB] insertSqlWithDevice:device];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.deviceListTableView reloadData];
        });
    }
}

#pragma mark - tabel delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    _showDevices = [NSMutableArray arrayWithCapacity:0];
    NSArray *tmpScanDevices = self.scanDevices;
    NSArray *tmpMyDevices = self.myDevices;
    for (BLDNADevice *device in tmpScanDevices) {
        BOOL isAdded = NO;
        for (BLDNADevice *myDevice in tmpMyDevices) {
            if ([device.did isEqualToString:myDevice.did]) {
                isAdded = YES;
                break;
            }
        }
        
        if (!isAdded) {
            [_showDevices addObject:device];
        }
    }
    
    return _showDevices.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    BLDNADevice *device = _showDevices[indexPath.row];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text = [device getName];
    
    UILabel *macLabel = (UILabel *)[cell viewWithTag:102];
    macLabel.text = [NSString stringWithFormat:@"MAC:%@", [device getMac]];
    
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:103];
//    typeLabel.text = [NSString stringWithFormat:@"Type:%ld", (long)[device getType]];
    typeLabel.text = [NSString stringWithFormat:@"Key:%@", [device getControlKey]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Action" message:@"Add device info to local db?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *bindAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf storeDeviceIndex:indexPath.row];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:bindAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSArray *)myDevices {
    return [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
}

- (NSArray *)scanDevices {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return [delegate.scanDevices copy];
}

@end
