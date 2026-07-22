//
//  GroupDeviceViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/8/29.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "GroupDeviceViewController.h"
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import <BLLetCore/BLLetCore.h>
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>

@interface GroupDeviceViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *endpointTextField;
@property (nonatomic, strong) UITextField *productIdTextField;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat groupTableHeight;
@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) NSMutableDictionary *selectGroupDevices;

@end

@implementation GroupDeviceViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Group Devices";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.selectGroupDevices = [NSMutableDictionary dictionaryWithCapacity:0];
    [self buildUI];
}

- (void)buildUI {
    self.endpointTextField = [BLTheme makeTextFieldWithPlaceholder:@"Endpoint ID"];
    self.endpointTextField.delegate = self;

    self.productIdTextField = [BLTheme makeTextFieldWithPlaceholder:@"Product ID"];
    self.productIdTextField.delegate = self;
    self.productIdTextField.text = @"0000000000000000000000004e100100";

    UIButton *selectGatewayButton = [BLTheme makeSecondaryButtonWithTitle:@"Select Gateway"
                                                                   target:self
                                                                   action:@selector(buttonClick:)];
    selectGatewayButton.tag = 100;

    UIButton *addGroupButton = [BLTheme makeSecondaryButtonWithTitle:@"Add Group Device"
                                                              target:self
                                                              action:@selector(buttonClick:)];
    addGroupButton.tag = 101;

    UIButton *queryGroupButton = [BLTheme makeSecondaryButtonWithTitle:@"Query Group"
                                                                target:self
                                                                action:@selector(buttonClick:)];
    queryGroupButton.tag = 102;

    UIButton *queryEndpointButton = [BLTheme makeSecondaryButtonWithTitle:@"Query Endpoint"
                                                                 target:self
                                                                 action:@selector(buttonClick:)];
    queryEndpointButton.tag = 103;

    UIStackView *row1 = [[UIStackView alloc] initWithArrangedSubviews:@[selectGatewayButton, addGroupButton]];
    row1.axis = UILayoutConstraintAxisHorizontal;
    row1.spacing = 10;
    row1.distribution = UIStackViewDistributionFillEqually;

    UIStackView *row2 = [[UIStackView alloc] initWithArrangedSubviews:@[queryGroupButton, queryEndpointButton]];
    row2.axis = UILayoutConstraintAxisHorizontal;
    row2.spacing = 10;
    row2.distribution = UIStackViewDistributionFillEqually;

    UILabel *resultTitle = [[UILabel alloc] init];
    resultTitle.text = @"Result";
    resultTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    resultTitle.textColor = [BLTheme subtitleColor];

    self.resultTextView = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.resultTextView];
    self.resultTextView.editable = NO;
    self.resultTextView.selectable = YES;
    self.resultTextView.text = @"Group device API result will appear here.";
    [self.resultTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(140);
    }];

    UILabel *tableTitle = [[UILabel alloc] init];
    tableTitle.text = @"Selected Group Devices";
    tableTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    tableTitle.textColor = [BLTheme subtitleColor];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.tableView];
    self.groupTableHeight = 56;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.groupTableHeight);
    }];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Group Devices"
                          subtitle:@"Manage virtual endpoints and grouped family devices"
                         formViews:@[self.endpointTextField, self.productIdTextField, row1, row2, resultTitle, self.resultTextView, tableTitle, self.tableView]
                     primaryButton:nil
                       footerViews:nil];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)updateTableHeight {
    self.groupTableHeight = MAX(self.selectGroupDevices.count, 1) * 56;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.groupTableHeight);
    }];
    [self.tableView reloadData];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)buttonClick:(UIButton *)sender {
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
                BLDNADevice *device = [[BLLet sharedLet].controller getDevice:@"00000000000000000000c8f742fe2834"];
                BLSEndpointInfo *info = [[BLSEndpointInfo alloc] initWithBLDevice:device];
                info.friendlyName = @"VirtualDevice";
                info.endpointId = result.endpointId;
                info.devicetypeFlag = 2;
                [[BLSFamilyManager sharedFamily] addEndpoints:@[info] completionHandler:^(BLBaseResult * _Nonnull result) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"%@", [result BLS_modelToJSONString]]];
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
                [self updateTableHeight];
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
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"%@", [result BLS_modelToJSONString]]];
        });
    }];
}

- (void)queryGroupDevice {
    NSString *endpointid = self.endpointTextField.text;
    [[BLSFamilyManager sharedFamily] queryGroupDeviceWithEndpointId:endpointid completionHandler:^(BLSGroupDeviceResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultTextView.text = [result BLS_modelToJSONString];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"%@", [result BLS_modelToJSONString]]];
        });
    }];
}

- (void)queryEndpoint {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.selectGroupDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"GROUPDEVICE_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        cell.textLabel.textColor = [BLTheme titleColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        cell.detailTextLabel.textColor = [BLTheme subtitleColor];
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
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self updateTableHeight];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
