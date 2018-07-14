//
//  RegisterViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"

@interface RegisterViewController () <UITextFieldDelegate>

@property (weak, nonatomic) UITextField *editField;
@property (nonatomic,strong) BLAccount *account;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phoneHeadField.delegate = self;
    self.phoneBodyField.delegate = self;
    self.verificationCodeField.delegate = self;
    self.passwordField.delegate = self;
    self.nickNameField.delegate = self;
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _account = delegate.account;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)verificationCodeButtonClick:(UIButton *)sender {
    [self.editField resignFirstResponder];
    
    NSString *phoneHead = self.phoneHeadField.text;
    NSString *phoneBody = self.phoneBodyField.text;
    
    [_account sendRegVCode:phoneBody countryCode:phoneHead completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result succeed]) {
                [BLStatusBar showTipMessageWithStatus:@"Verification code has been sent"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            }
        });
    }];
}

- (IBAction)registerButtonClick:(UIButton *)sender {
    [self.editField resignFirstResponder];
    
    NSString *phoneHead = self.phoneHeadField.text;
    NSString *phoneBody = self.phoneBodyField.text;
    NSString *vCode = self.verificationCodeField.text;
    NSString *password = self.passwordField.text;
    NSString *nickName = self.nickNameField.text;
    
    [_account regist:phoneBody password:password nickname:nickName vcode:vCode sex:BL_ACCOUNT_MALE birthday:nil countryCode:phoneHead iconPath:nil
completionHandler:^(BLLoginResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result succeed]) {
                [BLStatusBar showTipMessageWithStatus:@"Regist Success"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            }
        });
  }];
}

#pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.editField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}
@end
