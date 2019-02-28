//
//  EndpointAddViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/2/21.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "EndpointAddViewController.h"
#import "BLNewFamilyManager.h"

#import "AppMacro.h"
#import "DeviceDB.h"
#import <BLLetCore/BLLetCore.h>

#import "BLStatusBar.h"

@interface EndpointAddViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, copy) NSArray *myDevices;

@property (weak, nonatomic) IBOutlet UITableView *MyDeviceTable;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *roomIdField;
@property (weak, nonatomic) IBOutlet UILabel *showDevice;


- (IBAction)buttonClick:(UIButton *)sender;

@end

@implementation EndpointAddViewController

+ (EndpointAddViewController *)viewController {
    EndpointAddViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"EndpointAddViewController"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.myDevices = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
    
    self.MyDeviceTable.delegate = self;
    self.MyDeviceTable.dataSource = self;
    
    self.nameField.delegate = self;
    self.roomIdField.delegate = self;
    
    self.showDevice.numberOfLines = 0;
    self.showDevice.font = [UIFont systemFontOfSize:15.0];
    self.showDevice.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFamilyRooms];
    
    if (self.selectDevice) {
        self.MyDeviceTable.hidden = YES;
        self.showDevice.hidden = NO;
        self.showDevice.text = [self.selectDevice BLS_modelToJSONString];
        self.nameField.text = [NSString stringWithFormat:@"%@", self.selectDevice.name];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.h5param) {
         [[NSNotificationCenter defaultCenter] postNotificationName:BL_SDK_H5_PARAM_BACK object:nil userInfo:self.h5param]; //如果是H5调用的，将h5传递的参数再传递回去
    }
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    if (!self.selectDevice) {
        [BLStatusBar showTipMessageWithStatus:@"Please select device first!!!"];
        return;
    }
    
    BLSEndpointInfo *info = [[BLSEndpointInfo alloc] initWithBLDevice:self.selectDevice];
    info.friendlyName = self.nameField.text;
    info.roomId = self.roomIdField.text;
    
    [self addEndpointToFamily:info];
}


- (void)getFamilyRooms {
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    
    [manager getFamilyRoomsWithCompletionHandler:^(BLSManageRoomResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                if (result.roomInfos && result.roomInfos.count > 0) {
                    BLSRoomInfo *info = result.roomInfos.firstObject;
                    self.roomIdField.text = info.roomid;
                }
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Delete Room Failed. Code:%ld MSG:%@", result.status, result.msg]];
            }
        });
    }];
}

- (void)addEndpointToFamily:(BLSEndpointInfo *)info {
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
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
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Add Endpoints Failed. Code:%ld MSG:%@", result.status, result.msg]];
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"MY_DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BLDNADevice *device = self.myDevices[indexPath.row];
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = device.did;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectDevice = self.myDevices[indexPath.row];
    
    if (self.selectDevice) {
        self.MyDeviceTable.hidden = YES;
        self.showDevice.hidden = NO;
        self.showDevice.text = [self.selectDevice BLS_modelToJSONString];
        self.nameField.text = [NSString stringWithFormat:@"%@", self.selectDevice.name];
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
