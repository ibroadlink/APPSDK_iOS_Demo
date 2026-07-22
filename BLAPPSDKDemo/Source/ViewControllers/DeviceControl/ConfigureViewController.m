//
//  ConfigureViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "ConfigureViewController.h"
#import "APConfigTableViewController.h"
#import "BLStatusBar.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>
#import "BLTheme.h"
#import <Masonry/Masonry.h>

@interface ConfigureViewController ()

@property (nonatomic, strong) UITextField *ssidNameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextView *resultText;
@property (nonatomic, strong) UIButton *smartConfig2Button;
@property (nonatomic, strong) UIButton *smartConfig3Button;
@property (nonatomic, strong) UIButton *apConfigButton;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL didLoadSSIDOnce;
@property (nonatomic, assign) BOOL didScheduleSSIDLoad;
@property (nonatomic, assign) BOOL didPrewarmKeyboard;

@end

@implementation ConfigureViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Network Config";
    [self buildUI];
    [self setupDismissKeyboardGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scheduleDeferredSSIDLoad];
    [self prewarmKeyboardIfNeeded];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[BLLet sharedLet].controller deviceConfigCancel];
}

- (void)buildUI {
    self.ssidNameField = [BLTheme makeTextFieldWithPlaceholder:@"Wi-Fi SSID"];
    self.ssidNameField.delegate = self;
    self.ssidNameField.returnKeyType = UIReturnKeyNext;
    [self tuneTextField:self.ssidNameField];

    self.passwordField = [BLTheme makeTextFieldWithPlaceholder:@"Wi-Fi Password"];
    self.passwordField.delegate = self;
    self.passwordField.returnKeyType = UIReturnKeyDone;
    [self tuneTextField:self.passwordField];
    // 明文输入，避免系统「储存密码」提示
    self.passwordField.secureTextEntry = NO;
    self.ssidNameField.textContentType = UITextContentTypeNickname;
    self.passwordField.textContentType = UITextContentTypeNickname;
    if (@available(iOS 12.0, *)) {
        self.passwordField.passwordRules = nil;
    }

    self.smartConfig2Button = [BLTheme makePrimaryButtonWithTitle:@"SmartConfig v2"
                                                           target:self
                                                           action:@selector(startConfigureButtonClick:)];
    self.smartConfig2Button.tag = 101;

    self.smartConfig3Button = [BLTheme makePrimaryButtonWithTitle:@"SmartConfig v3"
                                                           target:self
                                                           action:@selector(startConfigureButtonClick:)];
    self.smartConfig3Button.tag = 102;

    self.apConfigButton = [BLTheme makeSecondaryButtonWithTitle:@"AP Config"
                                                         target:self
                                                         action:@selector(startConfigureButtonClick:)];
    self.apConfigButton.tag = 103;
    [self.apConfigButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
    }];

    UIStackView *configRow = [[UIStackView alloc] initWithArrangedSubviews:@[self.smartConfig2Button, self.smartConfig3Button]];
    configRow.axis = UILayoutConstraintAxisHorizontal;
    configRow.spacing = 12;
    configRow.distribution = UIStackViewDistributionFillEqually;

    UILabel *resultTitle = [[UILabel alloc] init];
    resultTitle.text = @"Result";
    resultTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    resultTitle.textColor = [BLTheme subtitleColor];

    self.resultText = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.resultText];
    self.resultText.selectable = NO;
    self.resultText.text = @"Configure result will appear here.";
    [self.resultText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(140);
    }];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Wi-Fi Setup"
                          subtitle:@"Put the device into pairing mode, then start configuring"
                         formViews:@[self.ssidNameField, self.passwordField, configRow, self.apConfigButton, resultTitle, self.resultText]
                     primaryButton:nil
                       footerViews:nil];
}

- (void)tuneTextField:(UITextField *)textField {
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.smartDashesType = UITextSmartDashesTypeNo;
    textField.smartQuotesType = UITextSmartQuotesTypeNo;
    textField.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
    textField.inputAssistantItem.leadingBarButtonGroups = @[];
    textField.inputAssistantItem.trailingBarButtonGroups = @[];
}

- (void)setupDismissKeyboardGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)scheduleDeferredSSIDLoad {
    if (self.didScheduleSSIDLoad) { return; }
    self.didScheduleSSIDLoad = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.view.window) { return; }
        if (self.ssidNameField.isFirstResponder || self.passwordField.isFirstResponder) { return; }
        [self requestLocationIfNeededAndLoadSSID];
    });
}

- (void)prewarmKeyboardIfNeeded {
    if (self.didPrewarmKeyboard) { return; }
    self.didPrewarmKeyboard = YES;

    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !self.view.window) { return; }
        if (self.ssidNameField.isFirstResponder || self.passwordField.isFirstResponder) { return; }

        UITextField *warmup = [[UITextField alloc] initWithFrame:CGRectMake(0, -200, 1, 1)];
        warmup.hidden = YES;
        warmup.autocorrectionType = UITextAutocorrectionTypeNo;
        warmup.inputAssistantItem.leadingBarButtonGroups = @[];
        warmup.inputAssistantItem.trailingBarButtonGroups = @[];
        [self.view addSubview:warmup];
        [warmup becomeFirstResponder];
        dispatch_async(dispatch_get_main_queue(), ^{
            [warmup resignFirstResponder];
            [warmup removeFromSuperview];
        });
    });
}

- (void)startConfigureButtonClick:(UIButton *)sender {
    [self.view endEditing:YES];

    NSString *ssidName = self.ssidNameField.text;
    NSString *password = self.passwordField.text;

    if (sender.tag == 101) {
        [self showIndicatorOnWindowWithMessage:@"Configuring..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BLDeviceConfigResult *result = [[BLLet sharedLet].controller deviceConfig:ssidName password:password version:2 timeout:60];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self presentConfigResult:result];
            });
        });
    } else if (sender.tag == 102) {
        [self showIndicatorOnWindowWithMessage:@"Configuring..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[BLLet sharedLet].controller deviceAPConfig:@"12345678901234567890123456789012" password:password type:3];
            BLDeviceConfigResult *result = [[BLLet sharedLet].controller deviceConfig:ssidName password:password version:3 timeout:60];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self presentConfigResult:result];
            });
        });
    } else if (sender.tag == 103) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Connect to device AP"
                                                                                 message:@"Make sure you are connected to the device hotspot (e.g. BroadlinkProv), then continue."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            APConfigTableViewController *vc = [APConfigTableViewController viewController];
            [self.navigationController pushViewController:vc animated:YES];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)presentConfigResult:(BLDeviceConfigResult *)result {
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:@"Configure Wi-Fi success"];
        self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)\nDid(%@)\nDevaddr(%@)\nMac(%@)",
                                (long)result.getError, result.getMsg, result.getDid, result.getDevaddr, result.getMac];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

#pragma mark - SSID

- (void)requestLocationIfNeededAndLoadSSID {
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }

    CLAuthorizationStatus status = [self currentLocationAuthorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        [self refreshSSIDIfAuthorized];
        return;
    }

    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
        return;
    }

    NSLog(@"无法读取 Wi-Fi SSID：定位权限未开启（status=%d）", status);
}

- (void)refreshSSIDIfAuthorized {
    if (self.ssidNameField.isFirstResponder || self.passwordField.isFirstResponder) {
        return;
    }

    CLAuthorizationStatus status = [self currentLocationAuthorizationStatus];
    if (status != kCLAuthorizationStatusAuthorizedWhenInUse &&
        status != kCLAuthorizationStatusAuthorizedAlways) {
        return;
    }

    if (@available(iOS 14.0, *)) {
        __weak typeof(self) weakSelf = self;
        [NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork * _Nullable currentNetwork) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) { return; }
                if (self.ssidNameField.isFirstResponder || self.passwordField.isFirstResponder) {
                    return;
                }
                if (self.ssidNameField.text.length == 0 || !self.didLoadSSIDOnce) {
                    self.ssidNameField.text = currentNetwork.SSID ?: @"";
                    self.didLoadSSIDOnce = YES;
                }
            });
        }];
        return;
    }

    if (self.ssidNameField.text.length == 0 || !self.didLoadSSIDOnce) {
        self.ssidNameField.text = [self getCurrentSSIDInfo] ?: @"";
        self.didLoadSSIDOnce = YES;
    }
}

- (CLAuthorizationStatus)currentLocationAuthorizationStatus {
    if (@available(iOS 14.0, *)) {
        if (self.locationManager) {
            return self.locationManager.authorizationStatus;
        }
    }
    return [CLLocationManager authorizationStatus];
}

- (NSString *)getCurrentSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSDictionary *info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info.count > 0) {
            break;
        }
    }
    return info[@"SSID"];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager API_AVAILABLE(ios(14.0)) {
    if (self.ssidNameField.isFirstResponder || self.passwordField.isFirstResponder) { return; }
    [self refreshSSIDIfAuthorized];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (@available(iOS 14.0, *)) { return; }
    if (self.ssidNameField.isFirstResponder || self.passwordField.isFirstResponder) { return; }
    [self refreshSSIDIfAuthorized];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.ssidNameField) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
