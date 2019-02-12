//
//  RestPasswordViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2018/6/27.
//  Copyright © 2018年 BroadLink. All rights reserved.
//

#import "RestPasswordViewController.h"
#import <BLLetAccount/BLLetAccount.h>

#import "BLStatusBar.h"
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
    // Do any additional setup after loading the view.
    [self viewInit];
}

- (void)viewInit {
    self.VCodeTextField.delegate = self;
    self.passwordTextField.delegate = self;
    [self.restPasswordButton setTitle:@"修改密码" forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)restPasswordAction:(id)sender {
    self.restPasswordButton.isLoading = YES;
    [[BLAccount sharedAccount] retrivePassword:_accountText vcode:self.VCodeTextField.text newPassword:self.passwordTextField.text completionHandler:^(BLLoginResult * _Nonnull result) {
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.restPasswordButton.isLoading = NO;
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                UIViewController *target = nil;
                for (UIViewController * controller in self.navigationController.viewControllers) { //遍历
                    if ([controller isKindOfClass:[loginVC class]]) { //这里判断是否为你想要跳转的页面
                        target = controller;
                    }
                }
                if (target) {
                    [self.navigationController popToViewController:target animated:YES]; //跳转
                }

            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.restPasswordButton.isLoading = NO;
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
@end
