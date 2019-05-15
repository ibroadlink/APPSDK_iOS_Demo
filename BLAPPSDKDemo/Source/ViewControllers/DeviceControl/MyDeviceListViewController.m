//
//  MyDeviceListViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/20.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "MyDeviceListViewController.h"
#import "OperateViewController.h"

#import "BLDeviceService.h"

@implementation MyDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _MyDeviceTable.delegate = self;
    _MyDeviceTable.dataSource = self;
    [self setExtraCellLineHidden:_MyDeviceTable];
    
    __weak typeof(self) weakSelf = self;
    [NSTimer scheduledTimerWithTimeInterval:2.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf.MyDeviceTable reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    NSArray *dids = deviceService.manageDevices.allKeys;
    
    return dids.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"MY_DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    NSString *did = deviceService.manageDevices.allKeys[indexPath.row];
    BLDNADevice *device = [deviceService.manageDevices objectForKey:did];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text = [device getName];
    
    UILabel *macLabel = (UILabel *)[cell viewWithTag:102];
    macLabel.text = [NSString stringWithFormat:@"MAC:%@", [device getMac]];
    
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:103];
    typeLabel.text = [NSString stringWithFormat:@"Type:%ld", (long)[device getType]];
    
    UILabel *netstateLabel = (UILabel *)[cell viewWithTag:104];
    netstateLabel.text = [NSString stringWithFormat:@"NetState:%@", [self getstate:device.ownerId ? device.deviceId : device.did]];
    
    return cell;
}

- (NSString *)getstate:(NSString *)did {
    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:did];
    
    NSString *stateString = @"State UnKown";
    switch (state) {
        case BL_DEVICE_STATE_LAN:
            stateString = @"LAN";
            break;
        case BL_DEVICE_STATE_REMOTE:
            stateString = @"REMOTE";
            break;
        case BL_DEVICE_STATE_OFFLINE:
            stateString = @"OFFLINE";
            break;
        default:
            break;
    }
    return stateString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    NSString *did = deviceService.manageDevices.allKeys[indexPath.row];
    BLDNADevice *device = [deviceService.manageDevices objectForKey:did];
    deviceService.selectDevice = device;
    
    [self performSegueWithIdentifier:@"OperateView" sender:device];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        NSString *did = deviceService.manageDevices.allKeys[indexPath.row];
        [deviceService removeDevice:did];
        [self.MyDeviceTable reloadData];
    }
}
@end
