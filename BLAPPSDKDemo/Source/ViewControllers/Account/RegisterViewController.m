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
#import "BLTheme.h"

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
    [self applyThemeStyle];
}

- (void)applyThemeStyle {
    self.view.backgroundColor = [BLTheme backgroundColor];
    NSArray *fields = @[self.phoneHeadField, self.phoneBodyField, self.verificationCodeField, self.passwordField, self.nickNameField];
    for (UITextField *field in fields) {
        [BLTheme styleTextField:field];
    }
    [BLTheme styleButtonsInView:self.view];
}

- (IBAction)verificationCodeButtonClick:(UIButton *)sender {
    [self.editField resignFirstResponder];
    
    NSString *phoneHead = self.phoneHeadField.text;
    NSString *phoneBody = self.phoneBodyField.text;
    __weak typeof(self) weakSelf = self;
    if (phoneHead.length > 0) {
        [self.account sendRegVCode:phoneBody countryCode:phoneHead completionHandler:^(BLBaseResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showSDKResult:result successMessage:@"Verification code has been sent"];
            });
        }];
    } else {
        [self.account sendRegVCode:phoneBody completionHandler:^(BLBaseResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showSDKResult:result successMessage:@"Verification code has been sent"];
            });
        }];
    }
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
    [self.account regist:phoneBody
                password:password
                nickname:nickName
                   vcode:vCode
                     sex:BL_ACCOUNT_MALE
                birthday:nil
             countryCode:phoneHead
                 country:nil
                iconPath:nil
       completionHandler:^(BLLoginResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideIndicatorOnWindow];
            if ([result succeed]) {
                //Regist Success => Login Success
                BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
                [userDefault applyLoginWithUserName:nickName
                                             userId:[result getUserid]
                                          sessionId:[result getLoginsession]];
                [weakSelf showSDKResult:result successMessage:@"Regist Success"];
                
                UserViewController *vc = [UserViewController viewController];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            } else {
                [weakSelf showSDKResult:result successMessage:nil];
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
