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
}

- (void)setupEmptyLabel {
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyLabel.text = @"No nearby devices yet\nPull to refresh after powering on devices";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    self.emptyLabel.textColor = [BLTheme subtitleColor];
    self.emptyLabel.hidden = YES;
    [self.view addSubview:self.emptyLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.emptyLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
        [self.emptyLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32],
    ]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [self.showDevices removeAllObjects];
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    for (int i = 0; i < deviceService.scanDevices.allKeys.count; i++) {
        NSString *did = deviceService.scanDevices.allKeys[i];
        BLDNADevice *manageDevice = [deviceService.manageDevices objectForKey:did];
        if (!manageDevice) {
            [self.showDevices addObject:deviceService.scanDevices[did]];
        }
    }

    self.emptyLabel.hidden = self.showDevices.count > 0;
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
        card.translatesAutoresizingMaskIntoConstraints = NO;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        UIView *iconBg = [[UIView alloc] init];
        iconBg.translatesAutoresizingMaskIntoConstraints = NO;
        iconBg.backgroundColor = [BLTheme primaryLightColor];
        iconBg.layer.cornerRadius = 16;
        iconBg.tag = 204;
        [card addSubview:iconBg];

        UIImageView *icon = [[UIImageView alloc] init];
        icon.translatesAutoresizingMaskIntoConstraints = NO;
        icon.tintColor = [BLTheme primaryColor];
        icon.tag = 205;
        if (@available(iOS 13.0, *)) {
            icon.image = [UIImage systemImageNamed:@"wifi"];
        }
        [iconBg addSubview:icon];

        titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 201;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        titleLabel.textColor = [BLTheme titleColor];
        [card addSubview:titleLabel];

        macLabel = [[UILabel alloc] init];
        macLabel.tag = 202;
        macLabel.translatesAutoresizingMaskIntoConstraints = NO;
        macLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        macLabel.textColor = [BLTheme subtitleColor];
        [card addSubview:macLabel];

        typeLabel = [[UILabel alloc] init];
        typeLabel.tag = 203;
        typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        typeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        typeLabel.textColor = [BLTheme primaryColor];
        [card addSubview:typeLabel];

        chevron = [[UIImageView alloc] init];
        chevron.tag = 206;
        chevron.translatesAutoresizingMaskIntoConstraints = NO;
        chevron.tintColor = [BLTheme subtitleColor];
        if (@available(iOS 13.0, *)) {
            chevron.image = [UIImage systemImageNamed:@"chevron.right"];
        }
        [card addSubview:chevron];

        [NSLayoutConstraint activateConstraints:@[
            [card.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:6],
            [card.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
            [card.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
            [card.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-6],

            [iconBg.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:14],
            [iconBg.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
            [iconBg.widthAnchor constraintEqualToConstant:40],
            [iconBg.heightAnchor constraintEqualToConstant:40],

            [icon.centerXAnchor constraintEqualToAnchor:iconBg.centerXAnchor],
            [icon.centerYAnchor constraintEqualToAnchor:iconBg.centerYAnchor],
            [icon.widthAnchor constraintEqualToConstant:20],
            [icon.heightAnchor constraintEqualToConstant:20],

            [chevron.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-14],
            [chevron.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
            [chevron.widthAnchor constraintEqualToConstant:12],
            [chevron.heightAnchor constraintEqualToConstant:16],

            [titleLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:18],
            [titleLabel.leadingAnchor constraintEqualToAnchor:iconBg.trailingAnchor constant:12],
            [titleLabel.trailingAnchor constraintEqualToAnchor:chevron.leadingAnchor constant:-8],

            [macLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4],
            [macLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
            [macLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],

            [typeLabel.topAnchor constraintEqualToAnchor:macLabel.bottomAnchor constant:2],
            [typeLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
            [typeLabel.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor],
        ]];
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
