//
//  OperateViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//
#import "OperateViewController.h"
#import "DataPassthoughViewController.h"
#import "DNAControlViewController.h"

#import "SSZipArchive.h"
#import "BLDeviceService.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, OperateAction) {
    OperateActionDataPassthrough,
    OperateActionDNAControl,
    OperateActionScriptDownload,
    OperateActionUIDownload,
    OperateActionFirmwareUpgrade,
    OperateActionDeviceTime,
};

@interface OperateViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *device;

@property (nonatomic, strong) NSArray *operateButtonArray;
@property (nonatomic, strong) NSArray *operateSymbols;

@property (nonatomic, strong) UITableView *operateTableView;

@property (nonatomic, strong) UIView *infoCard;
@property (nonatomic, strong) UILabel *stateBadgeLabel;
@property (nonatomic, strong) UIView *stateDot;
@property (nonatomic, copy) NSString *deviceJSONString;
@property (nonatomic, copy) NSString *firmwareVersionText;
@property (nonatomic, assign) BOOL didLoadFirmwareOnce;

@end

@implementation OperateViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    self.device = deviceService.selectDevice;
    self.title = self.device.getName.length ? self.device.getName : @"Device Detail";
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.operateButtonArray = @[
                                @"Device Passthough",
                                @"Device Control",
                                @"Script Download",
                                @"UI Download",
                                @"Device Firmware Upgrade",
                                @"Device Time Query",
                                ];
    self.operateSymbols = @[
        @"arrow.left.arrow.right",
        @"slider.horizontal.3",
        @"arrow.down.doc",
        @"rectangle.on.rectangle.angled",
        @"arrow.up.circle",
        @"clock",
    ];

    self.operateTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.operateTableView.delegate = self;
    self.operateTableView.dataSource = self;
    self.operateTableView.backgroundColor = [BLTheme backgroundColor];
    self.operateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.operateTableView.showsVerticalScrollIndicator = NO;
    self.operateTableView.contentInset = UIEdgeInsetsMake(4, 0, 20, 0);
    if (@available(iOS 15.0, *)) {
        self.operateTableView.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.operateTableView];
    [self.view addSubview:self.operateTableView];

    self.firmwareVersionText = @"Loading...";
    [self setupSummaryHeader];
    [self rebuildInfoAndResultPanels];
    [self refreshDeviceInfoPanel];
    [self loadDeviceStatusAndFirmwareOnce];
}

- (void)rebuildInfoAndResultPanels {
    // Info card
    UIView *infoCard = [[UIView alloc] init];
    [BLTheme styleCardView:infoCard];
    infoCard.userInteractionEnabled = YES;
    [self.view addSubview:infoCard];
    self.infoCard = infoCard;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDeviceJSONPopup)];
    [infoCard addGestureRecognizer:tap];

    UIView *iconBg = [[UIView alloc] init];
    iconBg.backgroundColor = [BLTheme primaryLightColor];
    iconBg.layer.cornerRadius = 18;
    iconBg.userInteractionEnabled = NO;
    [infoCard addSubview:iconBg];

    UIImageView *icon = [[UIImageView alloc] init];
    icon.tintColor = [BLTheme primaryColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.userInteractionEnabled = NO;
    if (@available(iOS 13.0, *)) {
        icon.image = [UIImage systemImageNamed:@"cpu"];
    }
    [iconBg addSubview:icon];

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.tag = 401;
    nameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    nameLabel.textColor = [BLTheme titleColor];
    nameLabel.userInteractionEnabled = NO;
    [infoCard addSubview:nameLabel];

    UIView *stateDot = [[UIView alloc] init];
    stateDot.layer.cornerRadius = 4;
    stateDot.userInteractionEnabled = NO;
    [infoCard addSubview:stateDot];
    self.stateDot = stateDot;

    UILabel *stateBadge = [[UILabel alloc] init];
    stateBadge.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    stateBadge.userInteractionEnabled = NO;
    [infoCard addSubview:stateBadge];
    self.stateBadgeLabel = stateBadge;

    UIStackView *rows = [[UIStackView alloc] init];
    rows.axis = UILayoutConstraintAxisVertical;
    rows.spacing = 8;
    rows.tag = 410;
    rows.userInteractionEnabled = NO;
    [infoCard addSubview:rows];

    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"Tap to view full JSON";
    hintLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    hintLabel.textColor = [BLTheme subtitleColor];
    hintLabel.userInteractionEnabled = NO;
    [infoCard addSubview:hintLabel];

    [self.view bringSubviewToFront:self.operateTableView];

    [infoCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
    }];
    [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(infoCard).offset(14);
        make.width.height.mas_equalTo(44);
    }];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBg);
        make.width.height.mas_equalTo(22);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconBg.mas_right).offset(12);
        make.top.equalTo(iconBg).offset(2);
        make.right.lessThanOrEqualTo(stateDot.mas_left).offset(-8);
    }];
    [stateBadge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(infoCard).offset(-14);
        make.centerY.equalTo(nameLabel);
    }];
    [stateDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(stateBadge.mas_left).offset(-6);
        make.centerY.equalTo(stateBadge);
        make.width.height.mas_equalTo(8);
    }];
    [rows mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconBg.mas_bottom).offset(14);
        make.left.equalTo(infoCard).offset(14);
        make.right.equalTo(infoCard).offset(-14);
    }];
    [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rows.mas_bottom).offset(12);
        make.left.equalTo(infoCard).offset(14);
        make.bottom.equalTo(infoCard).offset(-12);
    }];

    [self.operateTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoCard.mas_bottom).offset(8);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-8);
    }];

    [stateBadge setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

- (UIView *)infoRowWithTitle:(NSString *)title value:(NSString *)value {
    UIView *row = [[UIView alloc] init];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    titleLabel.textColor = [BLTheme subtitleColor];
    [row addSubview:titleLabel];

    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = value.length ? value : @"--";
    valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightMedium];
    valueLabel.textColor = [BLTheme titleColor];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.numberOfLines = 2;
    valueLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [row addSubview:valueLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(row);
        make.width.mas_equalTo(72);
    }];
    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(8);
        make.right.top.bottom.equalTo(row);
    }];
    return row;
}

- (UIColor *)colorForState:(BLDeviceStatusEnum)state {
    switch (state) {
        case BL_DEVICE_STATE_LAN: return [BLTheme primaryColor];
        case BL_DEVICE_STATE_REMOTE: return [BLTheme accentColor];
        case BL_DEVICE_STATE_OFFLINE: return [BLTheme dangerColor];
        default: return [BLTheme subtitleColor];
    }
}

- (void)refreshDeviceInfoPanel {
    UILabel *nameLabel = [self.infoCard viewWithTag:401];
    UIStackView *rows = [self.infoCard viewWithTag:410];
    for (UIView *sub in rows.arrangedSubviews) {
        [rows removeArrangedSubview:sub];
        [sub removeFromSuperview];
    }

    NSString *name = self.device.getName.length ? self.device.getName : @"Unnamed Device";
    nameLabel.text = name;

    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:[Tools controlDidForDevice:self.device]];
    UIColor *stateColor = [self colorForState:state];
    self.stateBadgeLabel.text = [Tools stringForDeviceState:state];
    self.stateBadgeLabel.textColor = stateColor;
    self.stateDot.backgroundColor = stateColor;

    NSArray *items = @[
        @[@"DID", self.device.getDid ?: @"--"],
        @[@"MAC", self.device.getMac ?: @"--"],
        @[@"Type", [NSString stringWithFormat:@"%lu", (unsigned long)self.device.getType]],
        @[@"PID", self.device.getPid ?: @"--"],
        @[@"LAN IP", self.device.getLanaddr.length ? self.device.getLanaddr : @"--"],
        @[@"Firmware", self.firmwareVersionText.length ? self.firmwareVersionText : @"--"],
    ];
    for (NSArray *item in items) {
        [rows addArrangedSubview:[self infoRowWithTitle:item[0] value:item[1]]];
    }

    NSDictionary *info = [self.device BLS_modelToJSONObject];
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    self.deviceJSONString = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding] ?: @"{}";
}

- (void)showDeviceJSONPopup {
    [self showTextPopupWithTitle:@"Device JSON" content:self.deviceJSONString];
}

- (void)showResult:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showTextPopupWithTitle:@"Result" content:text ?: @""];
    });
}

- (void)showTextPopupWithTitle:(NSString *)title content:(NSString *)content {
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self presentTextPopupWithTitle:title content:content];
        }];
        return;
    }
    [self presentTextPopupWithTitle:title content:content];
}

- (void)presentTextPopupWithTitle:(NSString *)title content:(NSString *)content {
    UIViewController *popup = [[UIViewController alloc] init];
    popup.view.backgroundColor = [BLTheme backgroundColor];
    popup.title = title;
    popup.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                            target:self
                                                                                            action:@selector(dismissTextPopup)];

    UITextView *textView = [[UITextView alloc] init];
    [BLTheme styleResultTextView:textView];
    textView.text = content;
    textView.editable = NO;
    textView.selectable = YES;
    [popup.view addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        // Masonry 不能用 edges.equalTo(mas_safeAreaLayoutGuide)，会把 left 错绑到 bottom
        make.top.equalTo(popup.view.mas_safeAreaLayoutGuideTop).offset(12);
        make.left.equalTo(popup.view).offset(16);
        make.right.equalTo(popup.view).offset(-16);
        make.bottom.equalTo(popup.view.mas_safeAreaLayoutGuideBottom).offset(-12);
    }];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:popup];
    if (@available(iOS 15.0, *)) {
        nav.sheetPresentationController.detents = @[
            [UISheetPresentationControllerDetent mediumDetent],
            [UISheetPresentationControllerDetent largeDetent]
        ];
        nav.sheetPresentationController.prefersGrabberVisible = YES;
    } else {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dismissTextPopup {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissDeviceJSONPopup {
    [self dismissTextPopup];
}

- (void)setupSummaryHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    header.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Operations";
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [header addSubview:titleLabel];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [header addSubview:accent];

    [accent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(header).offset(4);
        make.centerY.equalTo(header);
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(16);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(accent.mas_right).offset(10);
        make.centerY.equalTo(header);
    }];

    self.operateTableView.tableHeaderView = header;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self refreshDeviceInfoPanel];
}

- (void)loadDeviceStatusAndFirmwareOnce {
    if (self.didLoadFirmwareOnce) {
        return;
    }
    self.didLoadFirmwareOnce = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLFirmwareVersionResult *result = [[BLLet sharedLet].controller queryFirmwareVersion:[Tools controlDidForDevice:self.device]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result succeed]) {
                NSString *version = [result getVersion];
                self.firmwareVersionText = version.length ? version : @"--";
            } else {
                self.firmwareVersionText = result.getMsg.length ? result.getMsg : @"Query failed";
            }
            [self refreshDeviceInfoPanel];
        });
    });
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.operateButtonArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"OPERATE_CARD_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *card;
    UILabel *titleLabel;
    UIImageView *iconView;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        card = [[UIView alloc] init];
        card.tag = 300;
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        UIView *iconBg = [[UIView alloc] init];
        iconBg.tag = 301;
        iconBg.backgroundColor = [BLTheme primaryLightColor];
        iconBg.layer.cornerRadius = 12;
        [card addSubview:iconBg];

        iconView = [[UIImageView alloc] init];
        iconView.tag = 302;
        iconView.tintColor = [BLTheme primaryColor];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [iconBg addSubview:iconView];

        titleLabel = [[UILabel alloc] init];
        titleLabel.tag = 303;
        titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        titleLabel.textColor = [BLTheme titleColor];
        [card addSubview:titleLabel];

        UIImageView *chevron = [[UIImageView alloc] init];
        chevron.tintColor = [BLTheme subtitleColor];
        if (@available(iOS 13.0, *)) {
            chevron.image = [UIImage systemImageNamed:@"chevron.right"];
        }
        [card addSubview:chevron];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(4, 0, 4, 0));
        }];
        [iconBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(card).offset(12);
            make.centerY.equalTo(card);
            make.width.height.mas_equalTo(32);
        }];
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(iconBg);
            make.width.height.mas_equalTo(16);
        }];
        [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(card).offset(-12);
            make.centerY.equalTo(card);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(14);
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconBg.mas_right).offset(12);
            make.right.equalTo(chevron.mas_left).offset(-8);
            make.centerY.equalTo(card);
        }];
    } else {
        card = [cell.contentView viewWithTag:300];
        titleLabel = (UILabel *)[card viewWithTag:303];
        iconView = (UIImageView *)[[card viewWithTag:301] viewWithTag:302];
    }

    titleLabel.text = self.operateButtonArray[indexPath.row];
    if (@available(iOS 13.0, *)) {
        NSString *symbol = (indexPath.row < self.operateSymbols.count) ? self.operateSymbols[indexPath.row] : @"circle.fill";
        iconView.image = [UIImage systemImageNamed:symbol];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch ((OperateAction)indexPath.row) {
        case OperateActionDeviceTime:
            [self getServerTime];
            break;
        case OperateActionScriptDownload:
            [self downloadScript];
            break;
        case OperateActionUIDownload:
            [self downloadUI];
            break;
        case OperateActionDataPassthrough:
            [self dataPassthough];
            break;
        case OperateActionDNAControl:
            [self dnaControl];
            break;
        case OperateActionFirmwareUpgrade:
            [self upgradeFirmVersion];
            break;
        default:
            break;
    }
}


#pragma mark - private method
- (void)networkState {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshDeviceInfoPanel];
    });
}

- (void)downloadScript {
    [self showIndicatorOnWindowWithMessage:@"Querying script version..."];
    NSString *pid = self.device.pid;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLQueryResourceVersionResult *versionResult = [[BLLet sharedLet].controller queryScriptVersion:pid];
        NSString *versionInfo = nil;
        if ([versionResult succeed]) {
            BLResourceVersion *info = [versionResult.versions firstObject];
            versionInfo = [NSString stringWithFormat:@"Script Pid:%@\nVersion:%@", info.pid ?: @"--", info.version ?: @"--"];
        } else {
            versionInfo = [NSString stringWithFormat:@"Script Version Query Failed\nCode(%ld) Msg(%@)",
                           (long)versionResult.getError, versionResult.getMsg ?: @""];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self showIndicatorOnWindowWithMessage:@"Script Downloading..."];
        });

        [[BLLet sharedLet].controller downloadScript:pid completionHandler:^(BLDownloadResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                NSMutableString *text = [NSMutableString stringWithString:versionInfo ?: @""];
                [text appendString:@"\n\n"];
                if ([result succeed]) {
                    [text appendFormat:@"ScriptPath:%@", [result getSavePath]];
                    [self showResult:text];
                    [self showTextOnly:@"Script downloaded"];
                } else {
                    [text appendFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
                    [self showResult:text];
                    [self showTextOnly:result.getMsg.length ? result.getMsg : @"Script download failed"];
                }
            });
        }];
    });
}

- (void)downloadUI {
    [self showIndicatorOnWindowWithMessage:@"Querying UI version..."];
    NSString *pid = self.device.pid;
    NSString *unzipPath = [[BLLet sharedLet].controller queryUIPath:pid];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLQueryResourceVersionResult *versionResult = [[BLLet sharedLet].controller queryUIVersion:pid];
        NSString *versionInfo = nil;
        if ([versionResult succeed]) {
            BLResourceVersion *info = [versionResult.versions firstObject];
            versionInfo = [NSString stringWithFormat:@"UI Pid:%@\nVersion:%@", info.pid ?: @"--", info.version ?: @"--"];
        } else {
            versionInfo = [NSString stringWithFormat:@"UI Version Query Failed\nCode(%ld) Msg(%@)",
                           (long)versionResult.getError, versionResult.getMsg ?: @""];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self showIndicatorOnWindowWithMessage:@"UI Downloading..."];
        });

        [[BLLet sharedLet].controller downloadUI:pid completionHandler:^(BLDownloadResult * _Nonnull result) {
            if ([result succeed]) {
                BOOL isUnzip = [SSZipArchive unzipFileAtPath:[result getSavePath] toDestination:unzipPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideIndicatorOnWindow];
                    NSString *text = [NSString stringWithFormat:@"%@\n\nisUnzip:%d\nDownload File:%@\nUIPath:%@",
                                      versionInfo ?: @"", isUnzip, [result getSavePath], unzipPath];
                    [self showResult:text];
                    [self showTextOnly:isUnzip ? @"UI downloaded" : @"UI unzip failed"];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideIndicatorOnWindow];
                    NSString *text = [NSString stringWithFormat:@"%@\n\nCode(%ld) Msg(%@)",
                                      versionInfo ?: @"", (long)result.getError, result.getMsg];
                    [self showResult:text];
                    [self showTextOnly:result.getMsg.length ? result.getMsg : @"UI download failed"];
                });
            }
        }];
    });
}

- (void)upgradeFirmVersion {
    //Get URL From Servers
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"upgradeFirmware" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"upgrade Firmware Url";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *upgradeFirmwareUrl = alertController.textFields.firstObject.text;
        [self showIndicatorOnWindow];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BLBaseResult *result = [[BLLet sharedLet].controller upgradeFirmware:[Tools controlDidForDevice:self.device] url:upgradeFirmwareUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self showResult:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            });
        });
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)dataPassthough {
    DataPassthoughViewController *vc = [DataPassthoughViewController viewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dnaControl {
    //是否下载了脚本，需要先下载脚本才能控制设备
    if (![self isDownloadScript]) {
        return;
    }
    DNAControlViewController *vc = [DNAControlViewController viewController];
    [self.navigationController pushViewController:vc animated:YES];
}

//查询设备数据上报
- (void)queryDeviceData {
    BLBaseBodyResult *result = [[BLLet sharedLet].controller queryDeviceDataWithDid:[Tools controlDidForDevice:self.device] familyId:@"" startTime:@"2018-03-26_17:00:00" endTime:@"2018-03-27_22:00:00" type:@"fw_spminielec_v1"];
    if ([result succeed]) {
        [self showResult:[NSString stringWithFormat:@"responseBody : %@", result.responseBody]];
    } else {
        [self showResult:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    NSLog(@"queryDeviceDataResult%@",result.responseBody);
}

//获取设备服务器时间
- (void)getServerTime {
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLDeviceTimeResult *result = [[BLLet sharedLet].controller queryDeviceTime:[Tools controlDidForDevice:self.device]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                [self showResult:[NSString stringWithFormat:@"Time:%@ diff:%ld", result.time, (long)result.difftime]];
            } else {
                [self showResult:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            }
        });
    });
}

//设备复位
- (void)deviceReset {
    BLController *controller = [BLLet sharedLet].controller;
    NSString *result = [controller dnaControl:[Tools controlDidForDevice:self.device] subDevDid:nil dataStr:@"{}" command:@"dev_reset" scriptPath:nil];
    NSLog(@"result: %@", result);
    
    BLBaseResult *baseResult = [BLBaseResult BLS_modelWithJSON:result];
    if ([baseResult succeed]) {
        //复位成功
        [[BLDeviceService sharedDeviceService] removeDevice:self.device.did];
        [BLDeviceService sharedDeviceService].selectDevice = nil;
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self showResult:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)baseResult.getError, baseResult.getMsg]];
    }
}

//获取设备连接服务器信息
- (void)getDeviceServiceConnectInfo {
    BLController *controller = [BLLet sharedLet].controller;
    BLBaseResult *result = [controller queryDeviceConnectServerInfo:[Tools controlDidForDevice:self.device]];
    NSLog(@"result: %ld", (long)result.status);
    
    [self showResult:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}

- (BOOL)isDownloadScript {
    NSString *profileFile = [[BLLet sharedLet].controller queryScriptFileName:self.device.pid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:profileFile]) {
        [self showTextOnly:@"Please download script first!"];
        return NO;
    }
    return YES;
}

@end
