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
#import "BLStatusBar.h"
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getCodebtn:(id)sender {

    [_account sendFastVCode:self.phoneNumtxt.text countryCode:@"0086" completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        });
    }];
}

- (IBAction)codeLoginbtn:(id)sender {
    [self.phoneNumtxt resignFirstResponder];
    [self.passwordtxt resignFirstResponder];
    
    __weak typeof(self) weakSelf = self;
    [self showIndicatorOnWindowWithMessage:@"Logging..."];
    [_account fastLoginWithPhoneOrEmail:self.phoneNumtxt.text countrycode:@"0086" vcode:self.passwordtxt.text completionHandler:^(BLLoginResult * _Nonnull result) {
        if ([result succeed]) {
            BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
            [userDefault setUserName:self.phoneNumtxt.text];
            [userDefault setUserId:[result getUserid]];
            [userDefault setSessionId:[result getLoginsession]];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                [weakSelf hideIndicatorOnWindow];
                
                UserViewController *vc = [UserViewController viewController];
                [self.navigationController pushViewController:vc animated:YES];
                
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideIndicatorOnWindow];
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
