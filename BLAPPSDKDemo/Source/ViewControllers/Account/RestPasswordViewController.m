//
//  RestPasswordViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2018/6/27.
//  Copyright © 2018年 BroadLink. All rights reserved.
//

#import "RestPasswordViewController.h"
#import <BLLetAccount/BLLetAccount.h>

#import "BLLoadingButton.h"
#import "LoginViewController.h"

@interface RestPasswordViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *VCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet BLLoadingButton *restPasswordButton;
@end

@implementation RestPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
}

- (void)viewInit {
    self.VCodeTextField.delegate = self;
    self.passwordTextField.delegate = self;
    [self.restPasswordButton setTitle:@"修改密码" forState:UIControlStateNormal];
}

- (IBAction)restPasswordAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    self.restPasswordButton.isLoading = YES;
    [[BLAccount sharedAccount] retrivePassword:_accountText vcode:self.VCodeTextField.text newPassword:self.passwordTextField.text completionHandler:^(BLLoginResult * _Nonnull result) {
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.restPasswordButton.isLoading = NO;
                UIViewController *target = nil;
                for (UIViewController *controller in weakSelf.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[LoginViewController class]]) {
                        target = controller;
                    }
                }
                if (target) {
                    [weakSelf.navigationController popToViewController:target animated:YES];
                }

            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.restPasswordButton.isLoading = NO;
                [weakSelf showSDKResult:result successMessage:nil];
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
@end
