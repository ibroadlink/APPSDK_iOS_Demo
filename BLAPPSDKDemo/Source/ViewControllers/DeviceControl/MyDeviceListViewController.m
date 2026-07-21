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
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface MyDeviceListViewController ()
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) NSTimer *refreshTimer;
@end

@implementation MyDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Devices";
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.MyDeviceTable.delegate = self;
    self.MyDeviceTable.dataSource = self;
    self.MyDeviceTable.backgroundColor = [BLTheme backgroundColor];
    self.MyDeviceTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.MyDeviceTable.contentInset = UIEdgeInsetsMake(8, 0, 24, 0);
    self.MyDeviceTable.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.MyDeviceTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.MyDeviceTable];
    [self setupHeader];
    [self setupEmptyLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.MyDeviceTable reloadData];
    [self updateEmptyState];
    __weak typeof(self) weakSelf = self;
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf.MyDeviceTable reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)setupHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 78)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Paired Devices";
    titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Tap a device to open control & diagnostics";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    [header addSubview:subtitleLabel];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [header addSubview:accent];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(header).offset(8);
        make.left.equalTo(header).offset(20);
        make.right.equalTo(header).offset(-20);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
        make.left.right.equalTo(titleLabel);
    }];
    [accent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(10);
        make.left.equalTo(titleLabel);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(3);
        make.bottom.equalTo(header).offset(-8);
    }];

    self.MyDeviceTable.tableHeaderView = header;
}

- (void)setupEmptyLabel {
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"No paired devices yet\nProbe in LAN and add a device first";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.emptyLabel.textColor = [BLTheme subtitleColor];
    self.emptyLabel.hidden = YES;
    [self.view addSubview:self.emptyLabel];
    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
}

- (void)updateEmptyState {
    BOOL empty = [BLDeviceService sharedDeviceService].manageDevices.count == 0;
    self.emptyLabel.hidden = !empty;
    self.MyDeviceTable.hidden = empty;
}

- (NSArray<NSString *> *)deviceIds {
    return [BLDeviceService sharedDeviceService].manageDevices.allKeys;
}

- (UIColor *)colorForState:(BLDeviceStatusEnum)state {
    switch (state) {
        case BL_DEVICE_STATE_LAN: return [BLTheme primaryColor];
        case BL_DEVICE_STATE_REMOTE: return [BLTheme accentColor];
        case BL_DEVICE_STATE_OFFLINE: return [BLTheme dangerColor];
        default: return [BLTheme subtitleColor];
    }
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceIds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MY_DEVICE_CARD_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UILabel *titleLabel;
    UILabel *macLabel;
    UILabel *typeLabel;
    UILabel *stateLabel;
    UIView *stateDot;

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
        iconBg.tag = 210;
        [card addSubview:iconBg];

        UIImageView *icon = [[UIImageView alloc] init];
        icon.tintColor = [BLTheme primaryColor];
        icon.tag = 211;
        if (@available(iOS 13.0, *)) {
            icon.image = [UIImage systemImageNamed:@"cpu"];
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

        stateDot = [[UIView alloc] init];
        stateDot.tag = 205;
        stateDot.layer.cornerRadius = 4;
        [card addSubview:stateDot];

        stateLabel = [[UILabel alloc] init];
        stateLabel.tag = 204;
        stateLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
        [card addSubview:stateLabel];

        UIImageView *chevron = [[UIImageView alloc] init];
        chevron.tag = 206;
        chevron.tintColor = [BLTheme subtitleColor];
        if (@available(iOS 13.0, *)) {
            chevron.image = [UIImage systemImageNamed:@"chevron.right"];
        }
        [card addSubview:chevron];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(6, 16, 6, 16));
        }];
        [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(14);
            make.centerY.equalTo(card);
            make.width.height.mas_equalTo(44);
        }];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(iconBg);
            make.width.height.mas_equalTo(22);
        }];
        [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(card).offset(-14);
            make.centerY.equalTo(card);
            make.width.mas_equalTo(12);
            make.height.mas_equalTo(16);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(card).offset(16);
            make.left.equalTo(iconBg.mas_right).offset(12);
            make.right.lessThanOrEqualTo(stateDot.mas_left).offset(-8);
        }];
        [stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(chevron.mas_left).offset(-8);
            make.centerY.equalTo(titleLabel);
        }];
        [stateDot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(stateLabel.mas_left).offset(-6);
            make.centerY.equalTo(stateLabel);
            make.width.height.mas_equalTo(8);
        }];
        [macLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(4);
            make.left.equalTo(titleLabel);
            make.right.equalTo(chevron.mas_left).offset(-8);
        }];
        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(macLabel.mas_bottom).offset(2);
            make.left.right.equalTo(macLabel);
        }];
        [stateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    } else {
        card = [cell.contentView viewWithTag:200];
        titleLabel = (UILabel *)[card viewWithTag:201];
        macLabel = (UILabel *)[card viewWithTag:202];
        typeLabel = (UILabel *)[card viewWithTag:203];
        stateLabel = (UILabel *)[card viewWithTag:204];
        stateDot = [card viewWithTag:205];
    }

    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    NSString *did = self.deviceIds[indexPath.row];
    BLDNADevice *device = [deviceService.manageDevices objectForKey:did];
    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:[Tools controlDidForDevice:device]];
    UIColor *stateColor = [self colorForState:state];

    titleLabel.text = [device getName].length ? [device getName] : @"Unnamed Device";
    macLabel.text = [NSString stringWithFormat:@"MAC  %@", [device getMac] ?: @"--"];
    typeLabel.text = [NSString stringWithFormat:@"Type %ld", (long)[device getType]];
    stateLabel.text = [Tools stringForDeviceState:state];
    stateLabel.textColor = stateColor;
    stateDot.backgroundColor = stateColor;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    NSString *did = self.deviceIds[indexPath.row];
    BLDNADevice *device = [deviceService.manageDevices objectForKey:did];
    deviceService.selectDevice = device;
    [self performSegueWithIdentifier:@"OperateView" sender:device];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
        NSString *did = self.deviceIds[indexPath.row];
        [deviceService removeDevice:did];
        [self.MyDeviceTable reloadData];
        [self updateEmptyState];
    }
}

@end
