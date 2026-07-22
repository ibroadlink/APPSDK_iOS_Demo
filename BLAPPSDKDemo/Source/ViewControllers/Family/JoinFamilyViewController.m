//
//  JoinFamilyViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/19.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "JoinFamilyViewController.h"
#import "QRCodeViewController.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>

@interface JoinFamilyViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *familyCodeField;

@end

@implementation JoinFamilyViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Join Family";
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.familyCodeField = [BLTheme makeTextFieldWithPlaceholder:@"Invite code / QR content"];
    self.familyCodeField.delegate = self;

    UIButton *joinButton = [BLTheme makePrimaryButtonWithTitle:@"Join"
                                                        target:self
                                                        action:@selector(joinBtn)];
    UIButton *scanLink = [BLTheme makeLinkButtonWithTitle:@"Scan QR Code"
                                                   target:self
                                                   action:@selector(QRcodeBtn)];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Join a Home"
                          subtitle:@"Enter invite code or scan a QR code"
                         formViews:@[self.familyCodeField]
                     primaryButton:joinButton
                       footerViews:@[scanLink]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.qCode.length) {
        self.familyCodeField.text = self.qCode;
    }
}

- (void)joinBtn {
    [self.familyCodeField resignFirstResponder];
    if (self.familyCodeField.text.length == 0) {
        [self showTextOnly:@"Please enter invite code"];
        return;
    }

    BLSFamilyManager *familyManager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    [familyManager joinFamilyWithQrcode:self.familyCodeField.text completionHandler:^(BLSFamilyInfoResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                [BLStatusBar showTipMessageWithStatus:@"Join Family success!"];
                [self performSelector:@selector(goBack) withObject:nil afterDelay:1.0f];
            } else {
                [self showErrorCode:result.error msg:result.msg];
            }
        });
    }];
}

- (void)QRcodeBtn {
    [self.navigationController pushViewController:[QRCodeViewController viewController] animated:YES];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
