//
//  CodeLoginViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/4.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "CodeLoginViewController.h"
#import "UserViewController.h"

#import "AppDelegate.h"
#import "BLUserDefaults.h"
#import "BLTheme.h"
#import <BLLetAccount/BLLetAccount.h>


@interface CodeLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumtxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordtxt;
@property (nonatomic,strong)BLAccount *account;
@end

@implementation CodeLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneNumtxt.delegate = self;
    self.passwordtxt.delegate = self;
    
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    self.phoneNumtxt.text = [userDefault getUserName];
    
    self.account = [BLAccount sharedAccount];
    [self applyThemeStyle];
}

- (void)applyThemeStyle {
    self.view.backgroundColor = [BLTheme backgroundColor];
    [BLTheme styleTextField:self.phoneNumtxt];
    [BLTheme styleTextField:self.passwordtxt];
    self.phoneNumtxt.placeholder = self.phoneNumtxt.placeholder.length ? self.phoneNumtxt.placeholder : @"Phone / Email";
    self.passwordtxt.placeholder = self.passwordtxt.placeholder.length ? self.passwordtxt.placeholder : @"Verification code";

    [BLTheme styleButtonsInView:self.view];
}

- (IBAction)getCodebtn:(id)sender {
    __weak typeof(self) weakSelf = self;
    [_account sendFastVCode:self.phoneNumtxt.text countryCode:@"0086" completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showSDKResult:result successMessage:@"Verification code has been sent"];
        });
    }];
}

- (IBAction)codeLoginbtn:(id)sender {
    [self.phoneNumtxt resignFirstResponder];
    [self.passwordtxt resignFirstResponder];
    
    __weak typeof(self) weakSelf = self;
    [self showIndicatorOnWindowWithMessage:@"Logging..."];
    [_account fastLoginWithPhoneOrEmail:self.phoneNumtxt.text countrycode:@"0086" vcode:self.passwordtxt.text logintry:nil completionHandler:^(BLLoginResult * _Nonnull result) {
        if ([result succeed]) {
            BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
            [userDefault applyLoginWithUserName:weakSelf.phoneNumtxt.text
                                         userId:[result getUserid]
                                      sessionId:[result getLoginsession]];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                [weakSelf hideIndicatorOnWindow];
                
                UserViewController *vc = [UserViewController viewController];
                [weakSelf.navigationController pushViewController:vc animated:YES];
                
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideIndicatorOnWindow];
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
