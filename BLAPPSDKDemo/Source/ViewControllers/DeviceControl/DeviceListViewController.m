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
#import "BLTheme.h"
#import <Masonry/Masonry.h>

@interface DeviceListViewController ()

@property (nonatomic, strong) UITableView *deviceListTableView;
@property (nonatomic, strong) NSMutableArray *showDevices;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation DeviceListViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Probe In LAN";
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.deviceListTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.deviceListTableView.delegate = self;
    self.deviceListTableView.dataSource = self;
    self.deviceListTableView.backgroundColor = [BLTheme backgroundColor];
    self.deviceListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.deviceListTableView.contentInset = UIEdgeInsetsMake(4, 0, 20, 0);
    self.deviceListTableView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.deviceListTableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.deviceListTableView];
    [self.view addSubview:self.deviceListTableView];
    [self.deviceListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self setupHeader];
    [self setupEmptyLabel];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [BLTheme primaryColor];
    [refresh addTarget:self action:@selector(onPullRefresh:) forControlEvents:UIControlEventValueChanged];
    self.deviceListTableView.refreshControl = refresh;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onScanUpdated)
                                                 name:BLDeviceScanUpdatedNotification
                                               object:nil];
    [self refreshShowDevices];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadList];
    __weak typeof(self) weakSelf = self;
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf reloadList];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)setupHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 86)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Nearby Devices";
    titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Tap a device to pair and add to My Devices";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    [header addSubview:subtitleLabel];

    self.countLabel = [[UILabel alloc] init];
    self.countLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    self.countLabel.textColor = [BLTheme primaryColor];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    [header addSubview:self.countLabel];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [header addSubview:accent];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(header).offset(8);
        make.left.equalTo(header).offset(20);
        make.right.equalTo(self.countLabel.mas_left).offset(-8);
    }];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLabel);
        make.right.equalTo(header).offset(-20);
        make.width.mas_greaterThanOrEqualTo(40);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
        make.left.equalTo(titleLabel);
        make.right.equalTo(header).offset(-20);
    }];
    [accent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(10);
        make.left.equalTo(titleLabel);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(3);
        make.bottom.equalTo(header).offset(-8);
    }];

    self.deviceListTableView.tableHeaderView = header;
}

- (void)setupEmptyLabel {
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"Scanning for devices…\nPower on devices nearby, then pull to refresh";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.emptyLabel.textColor = [BLTheme subtitleColor];
    self.emptyLabel.hidden = YES;
    [self.view addSubview:self.emptyLabel];
    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.equalTo(self.view).offset(32);
        make.right.equalTo(self.view).offset(-32);
    }];
}

- (void)onPullRefresh:(UIRefreshControl *)refresh {
    [self reloadList];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refresh endRefreshing];
    });
}

- (void)onScanUpdated {
    [self reloadList];
}

- (void)reloadList {
    [self refreshShowDevices];
    self.countLabel.text = [NSString stringWithFormat:@"%lu found", (unsigned long)self.showDevices.count];
    self.emptyLabel.hidden = self.showDevices.count > 0;
    [self.deviceListTableView reloadData];
}

- (void)refreshShowDevices {
    [self.showDevices removeAllObjects];
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    for (NSString *did in deviceService.scanDevices) {
        if (!deviceService.manageDevices[did]) {
            [self.showDevices addObject:deviceService.scanDevices[did]];
        }
    }
}

- (void)storeDeviceIndex:(NSInteger)index {
    if (index >= self.showDevices.count) { return; }
    BLDNADevice *device = self.showDevices[index];

    [self showIndicatorOnWindowWithMessage:@"Pairing..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLPairResult *result = [[BLLet sharedLet].controller pairWithDevice:device];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                device.controlId = result.getId;
                device.controlKey = result.getKey;
                [[BLDeviceService sharedDeviceService] addNewDeivce:device];
                [BLStatusBar showTipMessageWithStatus:@"Device paired"];
                [self reloadList];
            } else {
                [BLStatusBar showTipMessageWithStatus:@"Pair failed, try again"];
            }
        });
    });
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showDevices.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DEVICE_LIST_CARD_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UILabel *titleLabel;
    UILabel *macLabel;
    UILabel *typeLabel;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        card = [[UIView alloc] init];
        card.tag = 200;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        UIView *iconBg = [[UIView alloc] init];
        iconBg.backgroundColor = [BLTheme primaryLightColor];
        iconBg.layer.cornerRadius = 16;
        [card addSubview:iconBg];

        UIImageView *icon = [[UIImageView alloc] init];
        icon.tintColor = [BLTheme primaryColor];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        if (@available(iOS 13.0, *)) {
            icon.image = [UIImage systemImageNamed:@"wifi"];
        }
        [iconBg addSubview:icon];

        titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 201;
        titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        titleLabel.textColor = [BLTheme titleColor];
        [card addSubview:titleLabel];

        macLabel = [[UILabel alloc] init];
        macLabel.tag = 202;
        macLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        macLabel.textColor = [BLTheme subtitleColor];
        [card addSubview:macLabel];

        typeLabel = [[UILabel alloc] init];
        typeLabel.tag = 203;
        typeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        typeLabel.textColor = [BLTheme primaryColor];
        [card addSubview:typeLabel];

        UIImageView *chevron = [[UIImageView alloc] init];
        chevron.tintColor = [BLTheme subtitleColor];
        if (@available(iOS 13.0, *)) {
            chevron.image = [UIImage systemImageNamed:@"plus.circle.fill"];
            chevron.tintColor = [BLTheme primaryColor];
        }
        [card addSubview:chevron];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(6, 16, 6, 16));
        }];
        [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(14);
            make.centerY.equalTo(card);
            make.width.height.mas_equalTo(40);
        }];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(iconBg);
            make.width.height.mas_equalTo(20);
        }];
        [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(card).offset(-14);
            make.centerY.equalTo(card);
            make.width.height.mas_equalTo(22);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(card).offset(18);
            make.left.equalTo(iconBg.mas_right).offset(12);
            make.right.equalTo(chevron.mas_left).offset(-8);
        }];
        [macLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(4);
            make.left.right.equalTo(titleLabel);
        }];
        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(macLabel.mas_bottom).offset(2);
            make.left.right.equalTo(titleLabel);
        }];
    } else {
        card = [cell.contentView viewWithTag:200];
        titleLabel = (UILabel *)[card viewWithTag:201];
        macLabel = (UILabel *)[card viewWithTag:202];
        typeLabel = (UILabel *)[card viewWithTag:203];
    }

    BLDNADevice *device = self.showDevices[indexPath.row];
    titleLabel.text = [device getName].length ? [device getName] : @"Unnamed Device";
    macLabel.text = [NSString stringWithFormat:@"MAC  %@", [device getMac] ?: @"—"];
    typeLabel.text = [NSString stringWithFormat:@"Type %ld · Tap to pair", (long)[device getType]];
    titleLabel.textColor = [BLTheme titleColor];
    macLabel.textColor = [BLTheme subtitleColor];
    typeLabel.textColor = [BLTheme primaryColor];

    if (device.lock) {
        titleLabel.textColor = [BLTheme dangerColor];
        macLabel.textColor = [[BLTheme dangerColor] colorWithAlphaComponent:0.8];
        typeLabel.text = [NSString stringWithFormat:@"Locked · %hhu", [device getLock]];
        typeLabel.textColor = [BLTheme dangerColor];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLDNADevice *device = self.showDevices[indexPath.row];
    NSString *name = [device getName].length ? [device getName] : @"this device";
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Device"
                                                                   message:[NSString stringWithFormat:@"Pair and save \"%@\" to My Devices?", name]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf storeDeviceIndex:indexPath.row];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSMutableArray *)showDevices {
    if (!_showDevices) {
        _showDevices = [NSMutableArray array];
    }
    return _showDevices;
}

@end
