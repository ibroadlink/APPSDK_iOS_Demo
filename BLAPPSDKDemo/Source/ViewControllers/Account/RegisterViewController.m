//
//  RegisterViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserViewController.h"

#import <BLLetAccount/BLLetAccount.h>

#import "BLUserDefaults.h"
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
    self.account = [BLAccount sharedAccount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)verificationCodeButtonClick:(UIButton *)sender {
    [self.editField resignFirstResponder];
    
    NSString *phoneHead = self.phoneHeadField.text;
    NSString *phoneBody = self.phoneBodyField.text;
    
    [self.account sendRegVCode:phoneBody countryCode:phoneHead completionHandler:^(BLBaseResult * _Nonnull result) {
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
    
    __weak typeof(self) weakSelf = self;
    [self showIndicatorOnWindow];
    [self.account regist:phoneBody password:password nickname:nickName vcode:vCode sex:BL_ACCOUNT_MALE birthday:nil countryCode:phoneHead iconPath:nil
completionHandler:^(BLLoginResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideIndicatorOnWindow];
            if ([result succeed]) {
                //Regist Success => Login Success
                BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
                [userDefault setUserName:nickName];
                [userDefault setUserId:[result getUserid]];
                [userDefault setSessionId:[result getLoginsession]];
                [BLStatusBar showTipMessageWithStatus:@"Regist Success"];
                
                UserViewController *vc = [UserViewController viewController];
                [self.navigationController pushViewController:vc animated:YES];
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
