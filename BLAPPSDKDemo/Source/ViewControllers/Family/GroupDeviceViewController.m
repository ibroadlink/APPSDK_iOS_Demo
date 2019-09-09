//
//  GroupDeviceViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/8/29.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "GroupDeviceViewController.h"
#import <BLSFamily/BLSFamily.h>
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import <BLLetCore/BLLetCore.h>

@interface GroupDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *endpointTextField;
@property (weak, nonatomic) IBOutlet UITextField *productIdTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) NSMutableDictionary *selectGroupDevices;
@end

@implementation GroupDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.selectGroupDevices = [NSMutableDictionary dictionaryWithCapacity:0];
    self.productIdTextField.text = @"0000000000000000000000004e100100";
}

- (IBAction)Button:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
            [self showSelectGatewayDevice];
            break;
        case 101:
            [self showSelectGroupDevice];
            break;
        case 102:
            [self queryGroupDevice];
            break;
        case 103:
            [self queryEndpoint];
            break;
        default:
            break;
    }
}

- (void)showSelectGatewayDevice {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    
    if (deviceService.manageDevices.allKeys.count == 0) {
        [BLStatusBar showTipMessageWithStatus:@"Please add device to sdk first!"];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please Select Gateway Device" preferredStyle:UIAlertControllerStyleActionSheet];
        [deviceService.manageDevices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull did, BLDNADevice * _Nonnull dev, BOOL * _Nonnull stop) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:did style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self getVirtualid:did];
            }];
            [alert addAction:action];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)getVirtualid:(NSString *)gatewayId {
    [[BLSFamilyManager sharedFamily] getVirtualidWithDevicetypeFlag:2 productId:self.productIdTextField.text gatewayId:gatewayId completionHandler:^(BLSVirtualidResult * _Nonnull result) {
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.endpointTextField.text = result.endpointId;
                self.resultTextView.text = [result BLS_modelToJSONString];
                //通过获取的endpointId构建设备信息并加入家庭
                BLDNADevice *device = [[BLLet sharedLet].controller getDevice:@"00000000000000000000c8f742fe2834"];
                BLSEndpointInfo *info = [[BLSEndpointInfo alloc] initWithBLDevice:device];
                info.friendlyName = @"VirtualDevice";
                info.endpointId = result.endpointId;
                info.devicetypeFlag = 2;
                [[BLSFamilyManager sharedFamily] addEndpoints:@[info] completionHandler:^(BLBaseResult * _Nonnull result) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"%@",[result BLS_modelToJSONString]]];
                    });
                }];
            });
        }
    }];
}

- (void)showSelectGroupDevice {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    
    if (deviceService.manageDevices.allKeys.count == 0) {
        [BLStatusBar showTipMessageWithStatus:@"Please add device to sdk first!"];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please Select Group Device" preferredStyle:UIAlertControllerStyleActionSheet];
        [deviceService.manageDevices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull did, BLDNADevice * _Nonnull dev, BOOL * _Nonnull stop) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:did style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.selectGroupDevices setObject:dev forKey:did];
                [self AddGroupDeviceManage];
                [self.tableView reloadData];
            }];
            [alert addAction:action];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)AddGroupDeviceManage {
    NSString *endpointid = self.endpointTextField.text;
    
    NSMutableArray *groupDeviceList = [NSMutableArray arrayWithCapacity:0];
    [self.selectGroupDevices enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull did, BLDNADevice * _Nonnull dev, BOOL * _Nonnull stop) {
        BLSGroupDevice *groupDevice = [[BLSGroupDevice alloc] init];
        groupDevice.endpointId = dev.did;
        groupDevice.gatewayId = dev.pDid;
        groupDevice.extend = @"";
        [groupDeviceList addObject:groupDevice];
    }];
    
    [[BLSFamilyManager sharedFamily] groupDeviceManageWithEndpointId:endpointid action:@"add" groupdevices:groupDeviceList completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultTextView.text = [result BLS_modelToJSONString];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"%@",[result BLS_modelToJSONString]]];
        });
    }];
}

- (void)queryGroupDevice {
    NSString *endpointid = self.endpointTextField.text;
    [[BLSFamilyManager sharedFamily] queryGroupDeviceWithEndpointId:endpointid completionHandler:^(BLSGroupDeviceResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultTextView.text = [result BLS_modelToJSONString];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"%@",[result BLS_modelToJSONString]]];
        });
    }];
}

-(void)queryEndpoint {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please Select Family Device" preferredStyle:UIAlertControllerStyleActionSheet];
    [[BLSFamilyManager sharedFamily] getEndpointsWithCompletionHandler:^(BLSQueryEndpointsResult * _Nonnull result) {
        NSArray *endpoints = result.endpoints;
        for (BLSEndpointInfo *endpointInfo in endpoints) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:endpointInfo.endpointId style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.endpointTextField.text = endpointInfo.endpointId;
            }];
            [alert addAction:action];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectGroupDevices.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"GROUPDEVICE_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSArray *groupDeviceList = [self.selectGroupDevices allValues];
    BLDNADevice *device = groupDeviceList[indexPath.row];
    
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = device.did;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *groupDeviceList = [self.selectGroupDevices allKeys];
    NSString *did = groupDeviceList[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.selectGroupDevices removeObjectForKey:did];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]  withRowAnimation:UITableViewRowAnimationNone];
    }
}


@end
