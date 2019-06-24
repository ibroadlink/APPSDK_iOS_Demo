//
//  DeviceListViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DeviceListViewController.h"
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "BLUserDefaults.h"
@interface DeviceListViewController ()

@property (strong, nonatomic) NSMutableArray *showDevices;

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    self.deviceListTableView.delegate = self;
    self.deviceListTableView.dataSource = self;
    [self setExtraCellLineHidden:self.deviceListTableView];
    NSArray *addedList = [[BLLet sharedLet].controller queryDeviceAddedList];
    for (BLDNADevice *device in addedList) {
        NSLog(@"deviceid:%@",device.deviceId);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)storeDeviceIndex:(NSInteger)index {
    if (index < self.showDevices.count) {
        BLDNADevice *device = self.showDevices[index];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Pair Device,Get RemoteControl Id and Key
            BLPairResult *result = [[BLLet sharedLet].controller pairWithDevice:device];
            if ([result succeed]) {
                device.controlId = result.getId;
                device.controlKey = result.getKey;
//                BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
//                device.ownerId = [userDefault getUserId];
                BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
                [deviceService addNewDeivce:device];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Pair Success,%ld,%@",(long)result.getId,result.getKey]];
                    [self.deviceListTableView reloadData];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [BLStatusBar showTipMessageWithStatus:@"Pair Fail,Try again!!!"];
                });
            }
        });
    }
}

#pragma mark - tabel delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    [self.showDevices removeAllObjects];
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    for (int i = 0; i < deviceService.scanDevices.allKeys.count; i++) {
        NSString *did = deviceService.scanDevices.allKeys[i];
        BLDNADevice *manageDevice = [deviceService.manageDevices objectForKey:did];
        if (!manageDevice) {
            [self.showDevices addObject:deviceService.scanDevices[did]];
        }
    }
    
    return self.showDevices.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    BLDNADevice *device = self.showDevices[indexPath.row];
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

- (NSMutableArray *)showDevices {
    if (!_showDevices) {
        _showDevices = [NSMutableArray arrayWithCapacity:0];
    }
    return _showDevices;
}

@end
