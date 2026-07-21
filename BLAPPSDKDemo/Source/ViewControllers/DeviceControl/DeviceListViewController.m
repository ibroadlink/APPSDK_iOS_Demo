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
#import "BLUserDefaults.h"
#import "BLTheme.h"
#import <Masonry/Masonry.h>

@interface DeviceListViewController ()

@property (strong, nonatomic) NSMutableArray *showDevices;
@property (strong, nonatomic) UILabel *emptyLabel;

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    self.deviceListTableView.delegate = self;
    self.deviceListTableView.dataSource = self;
    self.deviceListTableView.backgroundColor = [BLTheme backgroundColor];
    self.deviceListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.deviceListTableView.contentInset = UIEdgeInsetsMake(8, 0, 16, 0);
    [self setExtraCellLineHidden:self.deviceListTableView];
    [self setupEmptyLabel];

    NSArray *addedList = [[BLLet sharedLet].controller queryDeviceAddedList];
    for (BLDNADevice *device in addedList) {
        NSLog(@"deviceid:%@",device.deviceId);
    }
    [self refreshShowDevices];
}

- (void)setupEmptyLabel {
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"No nearby devices yet\nPull to refresh after powering on devices";
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshShowDevices];
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
    self.emptyLabel.hidden = self.showDevices.count > 0;
}

- (void)storeDeviceIndex:(NSInteger)index {
    if (index < self.showDevices.count) {
        BLDNADevice *device = self.showDevices[index];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Pair Device,Get RemoteControl Id and Key
            BLPairResult *result = [[BLLet sharedLet].controller pairWithDevice:device];
            if ([result succeed]) {
                device.controlId = result.getId;
                device.controlKey = result.getKey;
                BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
                [deviceService addNewDeivce:device];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Pair Success,%ld,%@",(long)result.getId,result.getKey]];
                    [self refreshShowDevices];
                    [self.deviceListTableView reloadData];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [BLStatusBar showTipMessageWithStatus:@"Pair Fail,Try again!!!"];
                });
            }
        });
    }
}

#pragma mark - tabel delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showDevices.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"DEVICE_LIST_CARD_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UILabel *titleLabel;
    UILabel *macLabel;
    UILabel *typeLabel;
    UIImageView *chevron;

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
        iconBg.tag = 204;
        [card addSubview:iconBg];

        UIImageView *icon = [[UIImageView alloc] init];
        icon.tintColor = [BLTheme primaryColor];
        icon.tag = 205;
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

        chevron = [[UIImageView alloc] init];
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
            make.width.height.mas_equalTo(40);
        }];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(iconBg);
            make.width.height.mas_equalTo(20);
        }];
        [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(card).offset(-14);
            make.centerY.equalTo(card);
            make.width.mas_equalTo(12);
            make.height.mas_equalTo(16);
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
    titleLabel.text = [device getName];
    macLabel.text = [NSString stringWithFormat:@"MAC  %@", [device getMac]];
    typeLabel.text = [NSString stringWithFormat:@"Type %ld", (long)[device getType]];
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
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Action" message:@"Add device info to local db?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *bindAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf storeDeviceIndex:indexPath.row];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:bindAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSMutableArray *)showDevices {
    if (!_showDevices) {
        _showDevices = [NSMutableArray arrayWithCapacity:0];
    }
    return _showDevices;
}

@end
