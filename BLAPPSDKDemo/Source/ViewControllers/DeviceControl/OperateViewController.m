//
//  OperateViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//
#import "OperateViewController.h"
#import "GeneralTimerControlView.h"
#import "FastconGroupDeviceViewController.h"

#import "AppMacro.h"
#import "BLStatusBar.h"
#import "SSZipArchive.h"
#import "BLDeviceService.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, OperateAction) {
    OperateActionDeviceStatus,
    OperateActionDeviceTime,
    OperateActionDataPassthrough,
    OperateActionDNAControl,
    OperateActionTimer,
    OperateActionGateway,
    OperateActionFastcon,
    OperateActionFirmwareQuery,
    OperateActionFirmwareUpgrade,
    OperateActionRM,
    OperateActionSP,
    OperateActionA1,
    OperateActionStartLogRedirect,
    OperateActionStopLogRedirect,
    OperateActionFastconGroup,
};

@interface OperateViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *device;

@property (nonatomic, strong) NSArray *operateButtonArray;
@property (nonatomic, strong) NSArray *operateSymbols;

@property (nonatomic, strong) NSString *logfile;
@property (nonatomic, strong) NSDateFormatter *formatter;

@property (weak, nonatomic) IBOutlet UITextView *deviceInfoView;
@property (weak, nonatomic) IBOutlet UITableView *operateTableView;

@property (nonatomic, strong) UIView *infoCard;
@property (nonatomic, strong) UILabel *stateBadgeLabel;
@property (nonatomic, strong) UIView *stateDot;
@property (nonatomic, copy) NSString *deviceJSONString;

@end

@implementation OperateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    self.device = deviceService.selectDevice;
    self.title = self.device.getName.length ? self.device.getName : @"Device Detail";
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.operateButtonArray = @[
                                @"Device Status Query",
                                @"Device Time Query",
                                @"Device Passthough",
                                @"Device Control",
                                @"Timer Task Functions",
                                @"GateWay Functions",
                                @"Fastcon Functions",
                                @"Device Firmware Query",
                                @"Device Firmware Upgrade",
                                @"RM Device Demo",
                                @"SP Device Demo",
                                @"A1 Device Demo",
                                @"Start Log Redirect",
                                @"Stop Log Redirect",
                                @"FastconGroupDevice"
                                ];
    self.operateSymbols = @[
        @"wifi",
        @"clock",
        @"arrow.left.arrow.right",
        @"slider.horizontal.3",
        @"timer",
        @"link",
        @"dot.radiowaves.left.and.right",
        @"info.circle",
        @"arrow.up.circle",
        @"tv",
        @"bolt",
        @"thermometer",
        @"doc.text",
        @"stop.circle",
        @"square.stack.3d.up",
    ];
    
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
    [self setupSummaryHeader];
    [self rebuildInfoAndResultPanels];
    [self refreshDeviceInfoPanel];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [self.formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
}

- (void)deactivateStoryboardLayoutForView:(UIView *)target {
    if (!target) { return; }
    NSMutableArray<NSLayoutConstraint *> *toDeactivate = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.firstItem == target || constraint.secondItem == target) {
            [toDeactivate addObject:constraint];
        }
    }
    for (NSLayoutConstraint *constraint in target.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight ||
            constraint.firstAttribute == NSLayoutAttributeWidth) {
            [toDeactivate addObject:constraint];
        }
    }
    [NSLayoutConstraint deactivateConstraints:toDeactivate];
}

- (void)rebuildInfoAndResultPanels {
    [self deactivateStoryboardLayoutForView:self.deviceInfoView];
    [self deactivateStoryboardLayoutForView:self.resultText];
    [self deactivateStoryboardLayoutForView:self.operateTableView];

    self.deviceInfoView.hidden = YES;

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

    self.resultText.hidden = YES;

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
        make.width.mas_equalTo(56);
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
        make.edges.equalTo(popup.view.mas_safeAreaLayoutGuide).insets(UIEdgeInsetsMake(12, 16, 12, 16));
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopDeviceLogRedirect];
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
        case OperateActionDeviceStatus:
            [self getDeviceState];
            break;
        case OperateActionDeviceTime:
            [self getServerTime];
            break;
        case OperateActionDataPassthrough:
            [self dataPassthough];
            break;
        case OperateActionDNAControl:
            [self dnaControl];
            break;
        case OperateActionTimer:
            [self generalTimerControl];
            break;
        case OperateActionGateway:
            [self gateWayControl];
            break;
        case OperateActionFastcon:
            [self fastconNoConfig];
            break;
        case OperateActionFirmwareQuery:
            [self getFirmwareVersion];
            break;
        case OperateActionFirmwareUpgrade:
            [self upgradeFirmVersion];
            break;
        case OperateActionRM:
            [self rmDeviceController];
            break;
        case OperateActionSP:
            [self SPControl];
            break;
        case OperateActionA1:
            [self A1Control];
            break;
        case OperateActionStartLogRedirect:
            [self startDeviceLogRedirect];
        break;
        case OperateActionStopLogRedirect:
            [self stopDeviceLogRedirect];
            break;
        case OperateActionFastconGroup:
            [self fastconGroupDevice];
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

- (void)getDeviceState {
    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:[Tools controlDidForDevice:self.device]];
    NSString *stateString = [Tools stringForDeviceState:state];
    [self showResult:[NSString stringWithFormat:@"state: %ld - %@", (long)state, stateString]];
}

- (void)getFirmwareVersion {
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLFirmwareVersionResult *result = [[BLLet sharedLet].controller queryFirmwareVersion:[Tools controlDidForDevice:self.device]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                [self showResult:[NSString stringWithFormat:@"Firmware Version:%@", [result getVersion]]];
            } else {
                [self showResult:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            }
        });
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
    [self performSegueWithIdentifier:@"DataPassthoughView" sender:nil];
}

- (void)dnaControl {
    //是否下载了脚本，需要先下载脚本才能控制设备
    [self isDownloadScript];
    [self performSegueWithIdentifier:@"DNAControlView" sender:nil];
}

- (void)SPControl {
    if ([self isDownloadScript]) {
        NSString *ProfileStr = [self getDeviceProfile];
        if([ProfileStr isEqualToString:SMART_SP]){
            [self performSegueWithIdentifier:@"SPminiControlView" sender:nil];
        }else{
            [BLStatusBar showTipMessageWithStatus:@"Not SP device"];
        }
    }
}

- (void)A1Control {
    if ([self isDownloadScript]) {
        NSString *ProfileStr = [self getDeviceProfile];
        if([ProfileStr isEqualToString:SMART_A1]){
            [self performSegueWithIdentifier:@"A1ControlView" sender:nil];
        }else{
            [BLStatusBar showTipMessageWithStatus:@"Not A1 device"];
        }
    }
}

- (void)gateWayControl {
    if ([self isDownloadScript]) {
        [self performSegueWithIdentifier:@"GateWayControlView" sender:nil];
    }
}

- (void)rmDeviceController {
    if ([self isDownloadScript]) {
        NSString *ProfileStr = [self getDeviceProfile];
        if([ProfileStr isEqualToString:SMART_RM]){
            [self performSegueWithIdentifier:@"RMminiControlView" sender:nil];
        } else {
            [BLStatusBar showTipMessageWithStatus:@"Not RM device"];
        }
    }
}

- (void)webViewControl {
    if ([Tools copyCordovaJsNamed:DNAKIT_CORVODA_JS_FILE forPid:self.device.pid]) {
        [self performSegueWithIdentifier:@"DeviceWebControlView" sender:nil];
    }
}

- (void)generalTimerControl {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please input query device did or sdid" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Device did or sdid";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *did = alertController.textFields.firstObject.text;
        dispatch_async(dispatch_get_main_queue(), ^{
            GeneralTimerControlView *vc = [GeneralTimerControlView viewController];
            vc.sdid = did;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)fastconNoConfig {
    [self performSegueWithIdentifier:@"fastconControlView" sender:nil];
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

- (NSString *)getDeviceProfile {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:self.device.pid];
    if ([result succeed]) {
        NSString *profileStr = [result getProfile];
        NSDictionary *dic = [BLCommonTools deserializeMessageJSON:profileStr];
        NSArray *srvStrArray = dic[@"srvs"];
        if (![BLCommonTools isEmptyArray:srvStrArray]) {
            return srvStrArray.firstObject;
        }
    }
    return nil;
}

- (BOOL)isDownloadScript {
    NSString *profileFile = [[BLLet sharedLet].controller queryScriptFileName:[self.device getPid]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:profileFile]) {
        [BLStatusBar showTipMessageWithStatus:@"Please download script first!"];
        return NO;
    }
    return YES;
}

- (BOOL)createDeviceLogFile {
    
    //将NSlog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"DeviceLog"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [self.formatter stringFromDate:[NSDate date]];
    self.logfile = [logDirectory stringByAppendingFormat:@"/%@-%@.log", self.device.did, dateStr];
    
    BOOL isSuccess = [fileManager createFileAtPath:self.logfile contents:nil attributes:nil];
    if (isSuccess) {
        NSLog(@"createStressTestLogFile success");
    } else {
        NSLog(@"createStressTestLogFile fail");
    }
    
    return isSuccess;
}

- (void)writeDeviceLogToFileWithString:(NSString *)log {
    
    if ([BLCommonTools isEmpty:log]) {
        return;
    }
    
    NSString *input = [NSString stringWithFormat:@"\n%@\n", log];
    
    NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:self.logfile];
    if (!outFile) {
        return;
    }
    [outFile seekToEndOfFile];
    [outFile writeData:[input dataUsingEncoding:NSUTF8StringEncoding]];
    [outFile closeFile];
    
}

- (void)startDeviceLogRedirect {
}

- (void)stopDeviceLogRedirect {
}

- (void)fastconGroupDevice {
    [self performSegueWithIdentifier:@"FastconGroupDeviceViewController" sender:nil];
}
@end
