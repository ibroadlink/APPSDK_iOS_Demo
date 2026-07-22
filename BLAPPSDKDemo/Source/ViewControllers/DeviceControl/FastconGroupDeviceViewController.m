//
//  FastconGroupDeviceViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/8/23.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "FastconGroupDeviceViewController.h"
#import "DNAControlViewController.h"
#import "FastconGroupDeviceEditViewController.h"
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface FastconGroupDeviceViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) BLDNADevice *device;
@property (nonatomic, strong) NSMutableArray<BLDNADevice *> *subDevicelist;
@property (nonatomic, strong) UITextField *pidText;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FastconGroupDeviceViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Fastcon Group Device";
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.subDevicelist = [NSMutableArray arrayWithCapacity:0];
    [self buildUI];
    [self subDevListQuery:0];
}

- (void)buildUI {
    UIView *filterCard = [[UIView alloc] init];
    [BLTheme styleCardView:filterCard];
    [self.view addSubview:filterCard];

    self.pidText = [BLTheme makeTextFieldWithPlaceholder:@"Group device PID"];
    self.pidText.text = @"000000000000000000000000aaaa0000";
    self.pidText.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    [filterCard addSubview:self.pidText];

    UIButton *getListBtn = [BLTheme makePrimaryButtonWithTitle:@"Get List" target:self action:@selector(getGroupDeviceList)];
    [filterCard addSubview:getListBtn];

    self.resultTextView = [[UITextView alloc] init];
    self.resultTextView.editable = NO;
    [BLTheme styleResultTextView:self.resultTextView];
    self.resultTextView.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    [self.view addSubview:self.resultTextView];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [BLTheme backgroundColor];
    self.tableView.separatorColor = [BLTheme separatorColor];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.tableView];
    [self.view addSubview:self.tableView];

    [filterCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
    }];
    [self.pidText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(filterCard).offset(12);
        make.right.equalTo(getListBtn.mas_left).offset(-10);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(filterCard).offset(-12);
    }];
    [getListBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(filterCard).offset(-12);
        make.centerY.equalTo(self.pidText);
        make.width.mas_equalTo(96);
        make.height.mas_equalTo(44);
    }];
    [self.resultTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(filterCard.mas_bottom).offset(8);
        make.left.right.equalTo(filterCard);
        make.height.mas_equalTo(100);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resultTextView.mas_bottom).offset(8);
        make.left.right.equalTo(filterCard);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-8);
    }];
}

- (void)getGroupDeviceList {
    [self subDevListQuery:0];
}

- (void)subDevListQuery:(NSUInteger)index {
    if (index == 0) {
        [self.subDevicelist removeAllObjects];
    }
    BLSubDevListResult *result = [[BLLet sharedLet].controller subDevListQueryWithDid:[Tools controlDidForDevice:self.device] index:index count:10];
    if ([result succeed]) {
        self.resultTextView.text = [result BLS_modelToJSONString];
        __block int n = 0;
        if (result.list.count > 0) {
            [result.list enumerateObjectsUsingBlock:^(BLDNADevice * _Nonnull subDevice, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([subDevice.pid isEqualToString:self.pidText.text]) {
                    [self.subDevicelist addObject:subDevice];
                } else {
                    n = n + 1;
                }
            }];
        }
        if (self.subDevicelist.count + n < result.total) {
            [self subDevListQuery:++index];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.tableView reloadData];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.tableView reloadData];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        });
    }
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subDevicelist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SUB_DEVICE_LIST_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        cell.textLabel.textColor = [BLTheme titleColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        cell.detailTextLabel.textColor = [BLTheme subtitleColor];
    }
    BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
    cell.textLabel.text = subDevice.did;
    cell.detailTextLabel.text = subDevice.pid;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Control" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        deviceService.gatewayDevice = deviceService.selectDevice;
        deviceService.selectDevice = subDevice;
        [[BLLet sharedLet].controller addDevice:subDevice];
        [self.navigationController pushViewController:[DNAControlViewController viewController] animated:YES];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        deviceService.gatewayDevice = deviceService.selectDevice;
        deviceService.selectDevice = subDevice;
        [[BLLet sharedLet].controller addDevice:subDevice];
        [self.navigationController pushViewController:[FastconGroupDeviceEditViewController viewController] animated:YES];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertView animated:YES completion:nil];
}

@end
