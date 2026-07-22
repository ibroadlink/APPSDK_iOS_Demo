//
//  ResetSDKInitViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/3/4.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "ResetSDKInitViewController.h"
#import "BLUserDefaults.h"
#import "BLTheme.h"
#import <BLLetCore/BLLetCore.h>
#import <Masonry/Masonry.h>

@interface ResetSDKInitViewController () <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *packNameField;
@property (nonatomic, strong) UITextView *licenseTextView;
@property (nonatomic, strong) UISwitch *enableCloudClusterSwitch;
@property (nonatomic, strong) UITextField *cloudClusterHostField;

@end

@implementation ResetSDKInitViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Reset License";
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self buildUI];
    [self loadCurrentConfig];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    scroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"SDK Config";
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [content addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Update package name / license, then restart the app";
    subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    subtitleLabel.textColor = [BLTheme subtitleColor];
    subtitleLabel.numberOfLines = 0;
    [content addSubview:subtitleLabel];

    UIView *accent = [[UIView alloc] init];
    accent.backgroundColor = [BLTheme primaryColor];
    accent.layer.cornerRadius = 2;
    [content addSubview:accent];

    UIView *card = [[UIView alloc] init];
    [BLTheme styleCardView:card];
    [content addSubview:card];

    UILabel *packTitle = [self sectionLabel:@"Package Name"];
    [card addSubview:packTitle];

    self.packNameField = [BLTheme makeTextFieldWithPlaceholder:@"Package Name"];
    self.packNameField.delegate = self;
    self.packNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.packNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    [card addSubview:self.packNameField];

    UILabel *licenseTitle = [self sectionLabel:@"License"];
    [card addSubview:licenseTitle];

    self.licenseTextView = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.licenseTextView];
    self.licenseTextView.delegate = self;
    self.licenseTextView.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    self.licenseTextView.returnKeyType = UIReturnKeyDone;
    [card addSubview:self.licenseTextView];

    UILabel *clusterTitle = [self sectionLabel:@"Cloud Cluster"];
    [card addSubview:clusterTitle];

    UIView *switchRow = [[UIView alloc] init];
    [card addSubview:switchRow];

    UILabel *switchLabel = [[UILabel alloc] init];
    switchLabel.text = @"Enable App Service Host";
    switchLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    switchLabel.textColor = [BLTheme titleColor];
    [switchRow addSubview:switchLabel];

    self.enableCloudClusterSwitch = [[UISwitch alloc] init];
    self.enableCloudClusterSwitch.onTintColor = [BLTheme primaryColor];
    [self.enableCloudClusterSwitch addTarget:self action:@selector(cloudClusterSwitchChanged) forControlEvents:UIControlEventValueChanged];
    [switchRow addSubview:self.enableCloudClusterSwitch];

    self.cloudClusterHostField = [BLTheme makeTextFieldWithPlaceholder:@"App Service Host"];
    self.cloudClusterHostField.delegate = self;
    self.cloudClusterHostField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.cloudClusterHostField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.cloudClusterHostField.keyboardType = UIKeyboardTypeURL;
    [card addSubview:self.cloudClusterHostField];

    UIButton *saveButton = [BLTheme makePrimaryButtonWithTitle:@"Save & Restart"
                                                        target:self
                                                        action:@selector(resetTheLicense)];
    [BLTheme styleDangerOutlineButton:saveButton];
    [saveButton setTitleColor:[BLTheme dangerColor] forState:UIControlStateNormal];
    [content addSubview:saveButton];

    UILabel *hint = [[UILabel alloc] init];
    hint.text = @"This clears the login session and exits the app.";
    hint.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    hint.textColor = [BLTheme subtitleColor];
    hint.numberOfLines = 0;
    hint.textAlignment = NSTextAlignmentCenter;
    [content addSubview:hint];

    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scroll);
        make.width.equalTo(scroll);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(16);
        make.left.equalTo(content).offset(20);
        make.right.equalTo(content).offset(-20);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.left.right.equalTo(titleLabel);
    }];
    [accent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(12);
        make.left.equalTo(titleLabel);
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(4);
    }];
    [card mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accent.mas_bottom).offset(20);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
    }];
    [packTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card).offset(16);
        make.left.equalTo(card).offset(16);
        make.right.equalTo(card).offset(-16);
    }];
    [self.packNameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(packTitle.mas_bottom).offset(8);
        make.left.right.equalTo(packTitle);
        make.height.mas_equalTo(48);
    }];
    [licenseTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.packNameField.mas_bottom).offset(16);
        make.left.right.equalTo(packTitle);
    }];
    [self.licenseTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(licenseTitle.mas_bottom).offset(8);
        make.left.right.equalTo(packTitle);
        make.height.mas_equalTo(160);
    }];
    [clusterTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.licenseTextView.mas_bottom).offset(16);
        make.left.right.equalTo(packTitle);
    }];
    [switchRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(clusterTitle.mas_bottom).offset(8);
        make.left.right.equalTo(packTitle);
        make.height.mas_equalTo(36);
    }];
    [switchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(switchRow);
        make.right.lessThanOrEqualTo(self.enableCloudClusterSwitch.mas_left).offset(-12);
    }];
    [self.enableCloudClusterSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(switchRow);
    }];
    [self.cloudClusterHostField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(switchRow.mas_bottom).offset(12);
        make.left.right.equalTo(packTitle);
        make.height.mas_equalTo(48);
        make.bottom.equalTo(card).offset(-16);
    }];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card.mas_bottom).offset(24);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
        make.height.mas_equalTo(50);
    }];
    [hint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(saveButton.mas_bottom).offset(12);
        make.left.equalTo(content).offset(24);
        make.right.equalTo(content).offset(-24);
        make.bottom.equalTo(content).offset(-32);
    }];
}

- (UILabel *)sectionLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    label.textColor = [BLTheme subtitleColor];
    return label;
}

- (void)loadCurrentConfig {
    BLConfigParam *param = [BLConfigParam sharedConfigParam];
    self.packNameField.text = param.packName ?: @"";
    self.licenseTextView.text = param.sdkLicense ?: @"";
    self.cloudClusterHostField.text = param.appServiceHost ?: @"";

    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    self.enableCloudClusterSwitch.on = [userDefault getAppServiceEnable];
    [self cloudClusterSwitchChanged];
}

- (void)cloudClusterSwitchChanged {
    self.cloudClusterHostField.enabled = self.enableCloudClusterSwitch.isOn;
    self.cloudClusterHostField.alpha = self.enableCloudClusterSwitch.isOn ? 1.0 : 0.5;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)resetTheLicense {
    [self dismissKeyboard];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Restart Required"
                                                                   message:@"App will clear login session and exit after saving."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Save & Exit" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
        [userDefault setPackName:self.packNameField.text ?: @""];
        [userDefault setLicense:self.licenseTextView.text ?: @""];
        [userDefault setAppServiceEnable:(self.enableCloudClusterSwitch.isOn ? 1 : 0)];
        [userDefault setAppServiceHost:self.cloudClusterHostField.text ?: @""];
        [userDefault setUserName:nil];
        [userDefault clearLoginSession];
        exit(0);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
