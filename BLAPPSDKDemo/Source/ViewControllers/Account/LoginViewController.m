//
//  LoginViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "LoginViewController.h"
#import "UserViewController.h"

#import "BLUserDefaults.h"
#import "BLStatusBar.h"
#import <BLLetAccount/BLLetAccount.h>

#import "BLLoadingButton.h"
#import "BLTheme.h"
#import <YYCategories/UIColor+YYAdd.h>
#import <YYCategories/UIImage+YYAdd.h>
#import <YYCategories/YYCategories.h>

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userNameField.delegate = self;
    self.passwordField.delegate = self;
    [self viewInit];
}

- (void)viewDidAppear:(BOOL)animated {
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    self.userNameField.text = [userDefault getUserName];
}

- (void)viewInit {
    self.view.backgroundColor = [BLTheme backgroundColor];
    [BLTheme styleTextField:self.userNameField];
    [BLTheme styleTextField:self.passwordField];
    [BLTheme stylePrimaryButton:self.loginButton];
    self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"icon_password_eye_show"] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"icon_password_eye_hidden"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(passwordShowAction:) forControlEvents:UIControlEventTouchUpInside];
    button.selected = NO;
    button.frame = CGRectMake(0, 0, 40, 40);
    
    self.passwordField.secureTextEntry = YES;
    self.passwordField.rightView = button;
    self.passwordField.rightViewMode = UITextFieldViewModeAlways;
    self.userNameField.placeholder = @"Phone number / email";
    self.passwordField.placeholder = @"Password";
    
}

- (IBAction)loginButtonClick:(UIButton *)sender {
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    
    BLAccount *account = [BLAccount sharedAccount];
    __weak typeof(self) weakSelf = self;
    self.loginButton.isLoading = YES;
    [account login:userName password:password completionHandler:^(BLLoginResult * _Nonnull result) {

        if ([result succeed]) {
            BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
            [userDefault setUserName:userName];
            [userDefault setUserId:[result getUserid]];
            [userDefault setSessionId:[result getLoginsession]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loginButton.isLoading = NO;
                
                UserViewController *vc = [UserViewController viewController];
                [self.navigationController pushViewController:vc animated:YES];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loginButton.isLoading = NO;
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            });
        }
    }];
    
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)passwordShowAction:(UIButton *)button {
    button.selected = !button.selected;
    self.passwordField.secureTextEntry = !button.selected;
}

@end
