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
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface FastconGroupDeviceEditViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) BLDNADevice *device;
@property (nonatomic, strong) NSMutableArray<BLGroupConfig *> *groupConfigList;

@end

@implementation FastconGroupDeviceEditViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Edit Group Device";
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.groupConfigList = [NSMutableArray array];
    [self buildUI];
    [self queryGroupDeviceBind];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([BLDeviceService sharedDeviceService].gatewayDevice) {
        [BLDeviceService sharedDeviceService].selectDevice = [BLDeviceService sharedDeviceService].gatewayDevice;
        [BLDeviceService sharedDeviceService].gatewayDevice = nil;
    }
    [super viewWillDisappear:animated];
}

- (void)buildUI {
    UIView *headerCard = [[UIView alloc] init];
    [BLTheme styleCardView:headerCard];
    [self.view addSubview:headerCard];

    self.nameButton = [BLTheme makeSecondaryButtonWithTitle:@"Group Name" target:self action:@selector(editName)];
    [headerCard addSubview:self.nameButton];

    UIButton *addBtn = [BLTheme makeSecondaryButtonWithTitle:@"Add Config" target:self action:@selector(Add)];
    UIButton *saveBtn = [BLTheme makePrimaryButtonWithTitle:@"Save" target:self action:@selector(SaveEdit)];

    UIStackView *actions = [[UIStackView alloc] initWithArrangedSubviews:@[addBtn, saveBtn]];
    actions.axis = UILayoutConstraintAxisHorizontal;
    actions.spacing = 10;
    actions.distribution = UIStackViewDistributionFillEqually;
    [headerCard addSubview:actions];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorColor = [BLTheme separatorColor];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];

    [headerCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
    }];
    [self.nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(headerCard).insets(UIEdgeInsetsMake(12, 12, 0, 12));
        make.height.mas_equalTo(44);
    }];
    [actions mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameButton.mas_bottom).offset(10);
        make.left.right.bottom.equalTo(headerCard).insets(UIEdgeInsetsMake(0, 12, 12, 12));
        make.height.mas_equalTo(44);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerCard.mas_bottom).offset(8);
        make.left.right.equalTo(headerCard);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-8);
    }];
}

#pragma mark - Actions

- (void)Add {
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

- (void)editName {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"reset the name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.nameButton.titleLabel.text;
    }];
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.nameButton setTitle:alertView.textFields.firstObject.text forState:UIControlStateNormal];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)SaveEdit {
    BLGroupVirtualDeviceInfo *info = [[BLGroupVirtualDeviceInfo alloc] init];
    info.did = [Tools controlDidForDevice:self.device];
    info.pid = self.device.pid;
    info.name = self.nameButton.titleLabel.text;
    info.config = self.groupConfigList;
    BLQueryGroupDeviceResult *result = [[BLLet sharedLet].controller bindFastconGroupDevice:self.device.pDid groupDeviceInfo:info];
    NSLog(@"%@", [result BLS_modelToJSONString]);
    if ([result succeed]) {
        [self viewBack];
    } else {
        [BLStatusBar showTipMessageWithStatus:result.msg];
    }
}

- (void)queryGroupDeviceBind {
    BLQueryGroupDeviceResult *result = [[BLLet sharedLet].controller queryFastconGroupDeviceBindInfo:self.device.pDid sdid:[Tools controlDidForDevice:self.device]];
    [self.nameButton setTitle:result.name forState:UIControlStateNormal];
    [self.groupConfigList addObjectsFromArray:result.config];
    [self.tableView reloadData];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupConfigList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"GROUP_CONFIG_LIST_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        cell.textLabel.textColor = [BLTheme titleColor];
        cell.detailTextLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
        cell.detailTextLabel.textColor = [BLTheme subtitleColor];
        cell.detailTextLabel.numberOfLines = 0;
    }
    BLGroupConfig *configInfo = self.groupConfigList[indexPath.row];
    cell.textLabel.text = configInfo.target;
    cell.detailTextLabel.text = [configInfo.list BLS_modelToJSONString];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewBack {
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

@end
