//
//  FastconGroupDeviceEditViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/8/26.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "FastconGroupDeviceEditViewController.h"
#import "BLDeviceService.h"
#import "BLStatusBar.h"

@interface FastconGroupDeviceEditViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *name;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) BLDNADevice *device;
@property (nonatomic, strong) NSMutableArray<BLGroupConfig *>* groupConfigList;

@end

@implementation FastconGroupDeviceEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 175;
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.groupConfigList = [NSMutableArray array];
    [self queryGroupDeviceBind];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([BLDeviceService sharedDeviceService].gatewayDevice) {
        [BLDeviceService sharedDeviceService].selectDevice = [BLDeviceService sharedDeviceService].gatewayDevice;
        [BLDeviceService sharedDeviceService].gatewayDevice = nil;
    }
    [super viewWillDisappear:animated];
}

- (IBAction)Add:(id)sender {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"set the config" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"pwr";
        textField.placeholder = @"Target Key";
    }];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"00000000000000000000c8f74293afcf";
        textField.placeholder = @"did";
    }];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"pwr";
        textField.placeholder = @"Keys";
    }];
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLGroupConfig *configInfo = [[BLGroupConfig alloc] init];
        configInfo.target = alertView.textFields.firstObject.text;
        BLSubDevKeys *subKeys = [[BLSubDevKeys alloc] init];
        subKeys.did = alertView.textFields[1].text;
        subKeys.key = @[alertView.textFields[2].text];
        configInfo.list = @[subKeys];
        [self.groupConfigList addObject:configInfo];
        [self.tableView reloadData];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

- (IBAction)editName:(id)sender {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"reset the name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.name.titleLabel.text;
    }];
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.name setTitle:alertView.textFields.firstObject.text forState:UIControlStateNormal] ;
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertView animated:YES completion:nil];
    
}
- (IBAction)SaveEdit:(id)sender {
    BLGroupVirtualDeviceInfo *info = [[BLGroupVirtualDeviceInfo alloc] init];
    info.did = self.device.did;
    info.pid = self.device.pid;
    info.name = self.name.titleLabel.text;
    info.config = self.groupConfigList;
    BLQueryGroupDeviceResult *result = [[BLLet sharedLet].controller bindFastconGroupDevice:self.device.pDid groupDeviceInfo:info];
    NSLog(@"%@",[result BLS_modelToJSONString]);
    if ([result succeed]) {
        [self viewBack];
    }else {
        [BLStatusBar showTipMessageWithStatus:result.msg];
    }
}

- (void)queryGroupDeviceBind {
    BLQueryGroupDeviceResult *result = [[BLLet sharedLet].controller queryFastconGroupDeviceBindInfo:self.device.pDid sdid:self.device.did];
    [self.name setTitle:result.name forState:UIControlStateNormal] ;
    [self.groupConfigList addObjectsFromArray:result.config];
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupConfigList.count;
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"GROUP_CONFIG_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    BLGroupConfig *configInfo = self.groupConfigList[indexPath.row];
    cell.textLabel.text = configInfo.target;
    cell.detailTextLabel.text = [configInfo.list BLS_modelToJSONString];
    [cell.detailTextLabel setNumberOfLines:0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)viewBack {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}
@end
