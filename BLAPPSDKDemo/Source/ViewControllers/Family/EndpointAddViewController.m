//
//  EndpointAddViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "EndpointAddViewController.h"
#import "BLFamilyDefult.h"
#import "AppMacro.h"
#import "DeviceDB.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>

@interface EndpointAddViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, copy) NSArray *myDevices;
@property (nonatomic, strong) UITableView *myDeviceTable;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UILabel *showDeviceLabel;
@property (nonatomic, strong) UIView *deviceCard;
@property (nonatomic, assign) CGFloat deviceTableHeight;

@end

@implementation EndpointAddViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Add Endpoint";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.myDevices = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
    [self buildUI];
    [self updateDeviceSelectionUI];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)buildUI {
    self.nameField = [BLTheme makeTextFieldWithPlaceholder:@"Endpoint name"];
    self.nameField.delegate = self;

    UILabel *deviceTitle = [[UILabel alloc] init];
    deviceTitle.text = @"Selected Device";
    deviceTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    deviceTitle.textColor = [BLTheme subtitleColor];

    self.deviceCard = [[UIView alloc] init];
    [BLTheme styleCardView:self.deviceCard];
    self.deviceCard.hidden = YES;

    self.showDeviceLabel = [[UILabel alloc] init];
    self.showDeviceLabel.numberOfLines = 0;
    self.showDeviceLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.showDeviceLabel.textColor = [BLTheme subtitleColor];
    [self.deviceCard addSubview:self.showDeviceLabel];
    [self.showDeviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.deviceCard).insets(UIEdgeInsetsMake(12, 12, 12, 12));
    }];

    UILabel *listTitle = [[UILabel alloc] init];
    listTitle.text = @"My Devices";
    listTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    listTitle.textColor = [BLTheme subtitleColor];

    self.myDeviceTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.myDeviceTable.delegate = self;
    self.myDeviceTable.dataSource = self;
    self.myDeviceTable.backgroundColor = [UIColor clearColor];
    self.myDeviceTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myDeviceTable.scrollEnabled = NO;
    if (@available(iOS 15.0, *)) {
        self.myDeviceTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.myDeviceTable];
    self.deviceTableHeight = MAX(self.myDevices.count, 1) * 56;
    [self.myDeviceTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.deviceTableHeight);
    }];

    UIButton *addButton = [BLTheme makePrimaryButtonWithTitle:@"Add"
                                                       target:self
                                                       action:@selector(buttonClick:)];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Add Endpoint"
                          subtitle:@"Pick a local device and bind it to this family"
                         formViews:@[self.nameField, deviceTitle, self.deviceCard, listTitle, self.myDeviceTable]
                     primaryButton:addButton
                       footerViews:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.selectDevice) {
        self.nameField.text = [NSString stringWithFormat:@"%@", self.selectDevice.name];
        [self updateDeviceSelectionUI];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.h5param) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BL_SDK_H5_PARAM_BACK object:nil userInfo:self.h5param];
    }
}

- (void)updateDeviceSelectionUI {
    BOOL hasSelection = self.selectDevice != nil;
    self.deviceCard.hidden = !hasSelection;
    self.myDeviceTable.hidden = hasSelection;
    if (hasSelection) {
        self.showDeviceLabel.text = [self.selectDevice BLS_modelToJSONString];
    }
    self.deviceTableHeight = MAX(self.myDevices.count, 1) * 56;
    [self.myDeviceTable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.deviceTableHeight);
    }];
    [self.myDeviceTable reloadData];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)buttonClick:(UIButton *)sender {
    if (!self.selectDevice) {
        [BLStatusBar showTipMessageWithStatus:@"Please select device first!!!"];
        return;
    }
    BLFamilyDefult *familyDefult = [BLFamilyDefult sharedFamily];
    BLSEndpointInfo *info = [[BLSEndpointInfo alloc] initWithBLDevice:self.selectDevice];
    info.friendlyName = self.nameField.text;

    if (![BLCommonTools isEmptyArray:familyDefult.roomList]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择房间" message:@"请选择要添加的房间" preferredStyle:UIAlertControllerStyleActionSheet];
        for (BLSRoomInfo *room in familyDefult.roomList) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:room.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                info.roomId = room.roomid;
                [self addEndpointToFamily:info];
            }];
            [alert addAction:action];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self addEndpointToFamily:info];
    }
}

- (void)addEndpointToFamily:(BLSEndpointInfo *)info {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    NSArray *infos = @[info];

    [self showIndicatorOnWindow];
    [manager addEndpoints:infos completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });

        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorCode:result.status msg:result.msg];
            });
        }
    }];
}

#pragma mark - table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myDevices.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MY_DEVICE_LIST_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        cell.textLabel.textColor = [BLTheme titleColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        cell.detailTextLabel.textColor = [BLTheme subtitleColor];
    }

    BLDNADevice *device = self.myDevices[indexPath.row];
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = device.did;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectDevice = self.myDevices[indexPath.row];
    if (self.selectDevice) {
        self.nameField.text = [NSString stringWithFormat:@"%@", self.selectDevice.name];
        [self updateDeviceSelectionUI];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

@end
