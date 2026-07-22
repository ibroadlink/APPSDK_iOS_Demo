//
//  ACControlViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "ACControlViewController.h"

#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import "Tools.h"
#import <BLLetCore/BLLetCore.h>
#import <BLLetIRCode/BLLetIRCode.h>
#import <Masonry/Masonry.h>

@interface ACControlViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UISwitch *powerSwitch;
@property (nonatomic, strong) UITextField *modeTextField;
@property (nonatomic, strong) UITextField *windSpeedTextField;
@property (nonatomic, strong) UITextField *directionTextField;
@property (nonatomic, strong) UITextField *tempTextField;
@property (nonatomic, strong) UITextView *resultText;

@end

@implementation ACControlViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"AC Control";
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self buildUI];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (UILabel *)fieldLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    label.textColor = [BLTheme titleColor];
    return label;
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    scroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"AC IR Control";
    titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    titleLabel.textColor = [BLTheme titleColor];
    [content addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"Set AC parameters, query IR code and send via RM";
    subtitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
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

    UILabel *powerLabel = [self fieldLabel:@"Power"];
    self.powerSwitch = [[UISwitch alloc] init];
    self.powerSwitch.on = YES;
    self.powerSwitch.onTintColor = [BLTheme primaryColor];
    [card addSubview:powerLabel];
    [card addSubview:self.powerSwitch];

    UILabel *modeLabel = [self fieldLabel:@"Mode"];
    self.modeTextField = [BLTheme makeTextFieldWithPlaceholder:@"0-4"];
    self.modeTextField.text = @"1";
    self.modeTextField.tag = 100;
    self.modeTextField.delegate = self;
    [card addSubview:modeLabel];
    [card addSubview:self.modeTextField];

    UILabel *speedLabel = [self fieldLabel:@"Wind Speed"];
    self.windSpeedTextField = [BLTheme makeTextFieldWithPlaceholder:@"0-3"];
    self.windSpeedTextField.text = @"1";
    self.windSpeedTextField.tag = 101;
    self.windSpeedTextField.delegate = self;
    [card addSubview:speedLabel];
    [card addSubview:self.windSpeedTextField];

    UILabel *dirLabel = [self fieldLabel:@"Direction"];
    self.directionTextField = [BLTheme makeTextFieldWithPlaceholder:@"0-1"];
    self.directionTextField.text = @"1";
    self.directionTextField.tag = 102;
    self.directionTextField.delegate = self;
    [card addSubview:dirLabel];
    [card addSubview:self.directionTextField];

    UILabel *tempLabel = [self fieldLabel:@"Temp"];
    self.tempTextField = [BLTheme makeTextFieldWithPlaceholder:@"°C"];
    self.tempTextField.text = @"20";
    self.tempTextField.tag = 103;
    self.tempTextField.delegate = self;
    self.tempTextField.keyboardType = UIKeyboardTypeNumberPad;
    [card addSubview:tempLabel];
    [card addSubview:self.tempTextField];

    UIButton *queryBtn = [BLTheme makePrimaryButtonWithTitle:@"Get IRCode"
                                                      target:self
                                                      action:@selector(queryACIRCodeData:)];
    UIButton *unitBtn = [BLTheme makeSecondaryButtonWithTitle:@"Change To Unit Code"
                                                       target:self
                                                       action:@selector(changeToUnitCode:)];
    UIButton *sendBtn = [BLTheme makePrimaryButtonWithTitle:@"Send IRCode"
                                                     target:self
                                                     action:@selector(sendACIRCodeData:)];
    for (UIButton *btn in @[queryBtn, unitBtn, sendBtn]) {
        [content addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) { make.height.mas_equalTo(44); }];
    }

    UILabel *resultTitle = [[UILabel alloc] init];
    resultTitle.text = @"IR Code Result";
    resultTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    resultTitle.textColor = [BLTheme subtitleColor];
    [content addSubview:resultTitle];

    self.resultText = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.resultText];
    self.resultText.editable = NO;
    self.resultText.selectable = YES;
    [content addSubview:self.resultText];

    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scroll);
        make.width.equalTo(scroll);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(12);
        make.left.equalTo(content).offset(20);
        make.right.equalTo(content).offset(-20);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
        make.left.right.equalTo(titleLabel);
    }];
    [accent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(subtitleLabel.mas_bottom).offset(12);
        make.left.equalTo(titleLabel);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(3);
    }];
    [card mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accent.mas_bottom).offset(16);
        make.left.right.equalTo(titleLabel);
    }];

    CGFloat labelW = 100;
    [powerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card).offset(16);
        make.left.equalTo(card).offset(14);
        make.width.mas_equalTo(labelW);
    }];
    [self.powerSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(powerLabel);
        make.right.equalTo(card).offset(-14);
    }];
    [modeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(powerLabel.mas_bottom).offset(16);
        make.left.width.equalTo(powerLabel);
    }];
    [self.modeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(modeLabel);
        make.left.equalTo(modeLabel.mas_right).offset(8);
        make.right.equalTo(card).offset(-14);
        make.height.mas_equalTo(40);
    }];
    [speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(modeLabel.mas_bottom).offset(16);
        make.left.width.equalTo(powerLabel);
    }];
    [self.windSpeedTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(speedLabel);
        make.left.right.height.equalTo(self.modeTextField);
    }];
    [dirLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(speedLabel.mas_bottom).offset(16);
        make.left.width.equalTo(powerLabel);
    }];
    [self.directionTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(dirLabel);
        make.left.right.height.equalTo(self.modeTextField);
    }];
    [tempLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dirLabel.mas_bottom).offset(16);
        make.left.width.equalTo(powerLabel);
        make.bottom.equalTo(card).offset(-16);
    }];
    [self.tempTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(tempLabel);
        make.left.right.height.equalTo(self.modeTextField);
    }];

    [queryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card.mas_bottom).offset(16);
        make.left.right.equalTo(titleLabel);
    }];
    [unitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(queryBtn.mas_bottom).offset(10);
        make.left.right.equalTo(titleLabel);
    }];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(unitBtn.mas_bottom).offset(10);
        make.left.right.equalTo(titleLabel);
    }];
    [resultTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendBtn.mas_bottom).offset(16);
        make.left.right.equalTo(titleLabel);
    }];
    [self.resultText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(resultTitle.mas_bottom).offset(8);
        make.left.right.equalTo(titleLabel);
        make.height.mas_equalTo(180);
        make.bottom.equalTo(content).offset(-24);
    }];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)queryACIRCodeData:(id)sender {
    [self dismissKeyboard];

    BLQueryIRCodeParams *params = [[BLQueryIRCodeParams alloc] init];
    params.temperature = [self.tempTextField.text integerValue];
    params.state = self.powerSwitch.on;
    params.speed = [self.windSpeedTextField.text integerValue];
    params.mode = [self.modeTextField.text integerValue];
    params.direct = [self.directionTextField.text integerValue];

    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    BLIRCodeDataResult *result = [blircode queryACIRCodeDataWithScript:self.savePath params:params];
    if ([result succeed]) {
        self.resultText.text = result.ircode;
    } else {
        [self showErrorCode:result.error msg:result.msg];
    }
}

- (IBAction)changeToUnitCode:(UIButton *)sender {
    [self dismissKeyboard];

    NSString *waveCode = self.resultText.text;
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    NSString *unitCode = [blircode waveCodeChangeToUnitCode:waveCode];

    if (unitCode) {
        self.resultText.text = unitCode;
    } else {
        self.resultText.text = @"Change Wave Code To Unit Code Failed!";
    }
}

- (IBAction)sendACIRCodeData:(id)sender {
    [self dismissKeyboard];

    if (!self.device) {
        [self showSelectRMDevice];
    } else {
        [self sendACIRCodeWithDevice];
    }
}

- (void)showSelectRMDevice {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];

    if (deviceService.manageDevices.allKeys.count == 0) {
        [BLStatusBar showTipMessageWithStatus:@"Please add device to sdk first!"];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please RM Device" preferredStyle:UIAlertControllerStyleActionSheet];
        [deviceService.manageDevices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull did, BLDNADevice * _Nonnull dev, BOOL * _Nonnull stop) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:did style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.device = dev;
                [self sendACIRCodeWithDevice];
            }];
            [alert addAction:action];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)sendACIRCodeWithDevice {
    BLStdData *stdStudyData = [[BLStdData alloc] init];
    [stdStudyData setValue:self.resultText.text forParam:@"irda"];

    BLController *blcontroller = [BLLet sharedLet].controller;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLStdControlResult *studyResult = [blcontroller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdStudyData action:@"set"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([studyResult succeed]) {
                [BLStatusBar showTipMessageWithStatus:@"Send success!"];
            } else {
                [self showErrorCode:studyResult.error msg:studyResult.msg];
            }
        });
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 100) {
        [textField resignFirstResponder];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"模式" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"自动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"0";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"制冷" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"1";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"除湿" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"2";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"通风" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"3";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"加热" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"4";
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (textField.tag == 101) {
        [textField resignFirstResponder];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"风速" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"自动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.windSpeedTextField.text = @"0";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"低速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.windSpeedTextField.text = @"1";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"中速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.windSpeedTextField.text = @"2";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"高速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.windSpeedTextField.text = @"3";
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (textField.tag == 102) {
        [textField resignFirstResponder];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"风向" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"自动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.directionTextField.text = @"0";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"固定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.directionTextField.text = @"1";
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
