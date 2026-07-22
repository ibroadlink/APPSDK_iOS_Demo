//
//  EndpointDetailController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/1.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "EndpointDetailController.h"
#import "OperateViewController.h"
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>
#import <Masonry/Masonry.h>

@interface EndpointDetailController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextView *detailTextView;
@property (nonatomic, strong) UIButton *deviceControlBtn;

@end

@implementation EndpointDetailController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Endpoint Detail";
    self.view.backgroundColor = [BLTheme backgroundColor];
    [self buildUI];
    [self bindData];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)buildUI {
    self.nameField = [BLTheme makeTextFieldWithPlaceholder:@"Friendly name"];
    self.nameField.delegate = self;

    UILabel *detailTitle = [[UILabel alloc] init];
    detailTitle.text = @"Endpoint Info";
    detailTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    detailTitle.textColor = [BLTheme subtitleColor];

    self.detailTextView = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.detailTextView];
    self.detailTextView.editable = NO;
    self.detailTextView.selectable = YES;
    [self.detailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(180);
    }];

    self.deviceControlBtn = [BLTheme makeSecondaryButtonWithTitle:@"Device Control"
                                                          target:self
                                                          action:@selector(buttonClick:)];
    self.deviceControlBtn.tag = 100;

    UIButton *saveButton = [BLTheme makePrimaryButtonWithTitle:@"Save / Modify"
                                                        target:self
                                                        action:@selector(buttonClick:)];
    saveButton.tag = 101;

    UIButton *deleteButton = [BLTheme makeSecondaryButtonWithTitle:@"Delete"
                                                            target:self
                                                            action:@selector(buttonClick:)];
    deleteButton.tag = 102;
    [BLTheme styleDangerOutlineButton:deleteButton];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Endpoint"
                          subtitle:@"View details, rename, or remove this family device"
                         formViews:@[self.nameField, detailTitle, self.detailTextView, self.deviceControlBtn, saveButton, deleteButton]
                     primaryButton:nil
                       footerViews:nil];
}

- (void)bindData {
    self.deviceControlBtn.hidden = !self.isNeedDeviceControl;
    self.detailTextView.text = [self.endpoint BLS_modelToJSONString];
    self.nameField.text = self.endpoint.friendlyName;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)buttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
            [self showDeviceControlView];
            break;
        case 101:
            [self ModifyEndPointInfo];
            break;
        case 102:
            [self deleteEndpoint];
            break;
        default:
            break;
    }
}

- (void)showDeviceControlView {
    [BLDeviceService sharedDeviceService].selectDevice = [self.endpoint toDNADevice];
    OperateViewController *vc = [OperateViewController viewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)ModifyEndPointInfo {
    NSString *name = self.nameField.text;
    if ([BLCommonTools isEmpty:name]) {
        [BLStatusBar showTipMessageWithStatus:@"Please input new name"];
        return;
    }

    NSDictionary *dic = @{
        @"attributeName": @"friendlyName",
        @"attributeValue": name
    };
    NSArray *attributes = @[dic];

    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];

    [manager modifyEndpoint:self.endpoint.endpointId attributes:attributes completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self showErrorCode:result.status msg:result.msg];
            }
        });
    }];
}

- (void)deleteEndpoint {
    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];

    [manager delEndpoint:self.endpoint.endpointId completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });

        if ([result succeed]) {
            BLDNADevice *device = [self.endpoint toDNADevice];

            if (![BLCommonTools isEmpty:device.pDid]) {
                [[BLLet sharedLet].controller subDevDelWithDid:device.pDid subDevDid:device.did];
            }
            [[BLDeviceService sharedDeviceService] removeDevice:device.did];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorCode:result.status msg:result.msg];
            });
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

@end
