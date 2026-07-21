//
//  ConfigureViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "ConfigureViewController.h"
#import "BLStatusBar.h"
#import "AppDelegate.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>
#import "APConfigTableViewController.h"
#import "BLTheme.h"

@interface ConfigureViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL didLoadSSIDOnce;
@property (nonatomic, assign) BOOL didScheduleSSIDLoad;
@property (nonatomic, assign) BOOL didPrewarmKeyboard;
@property (nonatomic, assign) BOOL didFixResultLayout;

@end

@implementation ConfigureViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ssidNameField.delegate = self;
    self.passwordField.delegate = self;
    [self applyThemeStyle];
    [self fixResultTextLayoutForKeyboard];
    [self setupDismissKeyboardGesture];
    // 定位/读 SSID 延后，避免与首次点击输入框、拉起键盘抢主线程
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scheduleDeferredSSIDLoad];
    [self prewarmKeyboardIfNeeded];
}

- (void)applyThemeStyle {
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self styleConfigTextField:self.ssidNameField];
    [self styleConfigTextField:self.passwordField];

    // 结果区保持轻量，避免 TextKit 复杂排版参与键盘动画
    self.resultText.backgroundColor = [BLTheme inputBackgroundColor];
    self.resultText.textColor = [BLTheme titleColor];
    self.resultText.font = [UIFont systemFontOfSize:13];
    self.resultText.editable = NO;
    self.resultText.selectable = NO;
    self.resultText.scrollEnabled = YES;
    self.resultText.layer.cornerRadius = 8;
    self.resultText.layer.masksToBounds = YES;

    self.ssidNameField.placeholder = self.ssidNameField.placeholder.length ? self.ssidNameField.placeholder : @"Wi-Fi SSID";
    self.passwordField.placeholder = self.passwordField.placeholder.length ? self.passwordField.placeholder : @"Wi-Fi Password";
    [self disablePasswordSavePromptForFields];

    [BLTheme styleButtonsInView:self.view];
}

- (void)disablePasswordSavePromptForFields {
    // 普通明文输入，避免密码框样式和「储存密码」提示
    self.passwordField.secureTextEntry = NO;
    self.ssidNameField.textContentType = UITextContentTypeNickname;
    self.passwordField.textContentType = UITextContentTypeNickname;
    if (@available(iOS 12.0, *)) {
        self.passwordField.passwordRules = nil;
    }
}

- (void)styleConfigTextField:(UITextField *)textField {
    if (!textField) { return; }
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [BLTheme titleColor];
    textField.font = [UIFont systemFontOfSize:15];
    textField.layer.cornerRadius = 0;
    textField.layer.masksToBounds = NO;
    textField.leftView = nil;
    textField.leftViewMode = UITextFieldViewModeNever;
    textField.rightView = nil;
    textField.rightViewMode = UITextFieldViewModeNever;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    textField.smartDashesType = UITextSmartDashesTypeNo;
    textField.smartQuotesType = UITextSmartQuotesTypeNo;
    textField.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
    // 减少键盘上方快捷栏 / Emoji Search 相关 RTI 开销
    textField.inputAssistantItem.leadingBarButtonGroups = @[];
    textField.inputAssistantItem.trailingBarButtonGroups = @[];
}

/// Storyboard 把 resultText 顶到底部安全区，键盘弹出时会整页重算导致首点卡顿
- (void)fixResultTextLayoutForKeyboard {
    if (self.didFixResultLayout || !self.resultText) { return; }
    self.didFixResultLayout = YES;

    UITextView *result = self.resultText;
    NSMutableArray<NSLayoutConstraint *> *toDeactivate = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        BOOL involvesResult = (constraint.firstItem == result || constraint.secondItem == result);
        if (!involvesResult) { continue; }
        if (constraint.firstAttribute == NSLayoutAttributeBottom ||
            constraint.secondAttribute == NSLayoutAttributeBottom) {
            [toDeactivate addObject:constraint];
        }
    }
    [NSLayoutConstraint deactivateConstraints:toDeactivate];
    [result.heightAnchor constraintEqualToConstant:160].active = YES;
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

/// 后台预热键盘，降低「第一次点击输入框」的系统冷启动耗时
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[BLLet sharedLet].controller deviceConfigCancel];
}

- (IBAction)startConfigureButtonClick:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSString *ssidName = self.ssidNameField.text;
    NSString *password = self.passwordField.text;

    if (sender.tag == 101) {
        [self showIndicatorOnWindowWithMessage:@"Configuring..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDate *date = [NSDate date];
            NSLog(@"====Start Config===");
            BLDeviceConfigResult *result = [[BLLet sharedLet].controller deviceConfig:ssidName password:password version:2 timeout:60];
            NSLog(@"====Config over! Spends(%fs)", [date timeIntervalSinceNow]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                if ([result succeed]) {
                    [BLStatusBar showTipMessageWithStatus:@"Configure Wi-Fi success"];
                    self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@) Did(%@) Devaddr(%@) Mac(%@)", (long)result.getError, result.getMsg, result.getDid, result.getDevaddr, result.getMac];
                } else {
                    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
                    self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
                }
            });
        });
    } else if (sender.tag == 102) {
        [self showIndicatorOnWindowWithMessage:@"Configuring..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDate *date = [NSDate date];
            NSLog(@"====Start Config===");
            BLAPConfigResult *apconfigResult = [[BLLet sharedLet].controller deviceAPConfig:@"12345678901234567890123456789012" password:password type:3];
            BLDeviceConfigResult *result = [[BLLet sharedLet].controller deviceConfig:ssidName password:password version:3 timeout:60];
            NSLog(@"====Config over! Spends(%fs)", [date timeIntervalSinceNow]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                if ([result succeed]) {
                    [BLStatusBar showTipMessageWithStatus:@"Configure Wi-Fi success"];
                    self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@) Did(%@) Devaddr(%@) Mac(%@)", (long)result.getError, result.getMsg, result.getDid, result.getDevaddr, result.getMac];
                } else {
                    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
                    self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
                }
            });
        });
    } else if (sender.tag == 103) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Make sure you have connect to the device's Ap (maybe like \"BroadlinkProv\")" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"APconfigView" sender:nil];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

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

    NSLog(@"无法读取 Wi-Fi SSID：定位权限未开启（status=%d）。请在系统设置中允许定位。", status);
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
    if (self.ssidNameField.isFirstResponder || self.passwordField.isFirstResponder) {
        return;
    }
    [self refreshSSIDIfAuthorized];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (@available(iOS 14.0, *)) {
        return;
    }
    if (self.ssidNameField.isFirstResponder || self.passwordField.isFirstResponder) {
        return;
    }
    [self refreshSSIDIfAuthorized];
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.ssidNameField) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

@end
