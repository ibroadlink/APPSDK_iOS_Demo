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

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
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
        //Pair Device,Get RemoteControl Id and Key
        BLPairResult *result = [[BLLet sharedLet].controller pairWithDevice:device];
        if ([result succeed]) {
            device.controlId = result.getId;
            device.controlKey = result.getKey;
            [[BLLet sharedLet].controller addDevice:device];
            //add device info to local db
            [[DeviceDB sharedOperateDB] insertSqlWithDevice:device];
            
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Pair Success,%ld,%@",(long)result.getId,result.getKey]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.deviceListTableView reloadData];
            });
        }else {
            [BLStatusBar showTipMessageWithStatus:@"Pair Fail,Try again!!!"];
        }
        
    }
}

#pragma mark - tabel delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.showDevices = [NSMutableArray arrayWithCapacity:0];
    NSArray *tmpMyDevices = self.myDevices;

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *scanDevice = [delegate.scanDevices copy];
    [scanDevice enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString *  _Nonnull key, BLDNADevice *  _Nonnull device, BOOL * _Nonnull stop) {
        BOOL isAdded = NO;
        for (BLDNADevice *myDevice in tmpMyDevices) {
            if ([key isEqualToString:myDevice.did]) {
                isAdded = YES;
                break;
            }
        }
        
        if (!isAdded) {
            [self.showDevices addObject:device];
        }
    }];
    
    return self.showDevices.count;
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
    typeLabel.text = [NSString stringWithFormat:@"Type:%ld", (long)[device getType]];
    
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

@end
