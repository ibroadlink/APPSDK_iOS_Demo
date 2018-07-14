//
//  ModifyPhoneViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/4.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "ModifyPhoneViewController.h"
#import "BLUserDefaults.h"
#import "BLStatusBar.h"
#import "AppDelegate.h"

@interface ModifyPhoneViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *countryField;

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@end

@implementation ModifyPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.countryField.delegate = self;
    self.phoneField.delegate = self;
}



- (IBAction)next:(id)sender {
    //发送修改手机号验证码
    [self sendModifyPhoneVCode:self.phoneField.text];
    //修改手机号
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请输入验证码"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"验证码";
    }];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self modifyPhone:self.phoneField.text vcode:alert.textFields.firstObject.text];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sendModifyPhoneVCode:(NSString *)phone {
    [[BLAccount sharedAccount] sendModifyVCode:phone countryCode:@"86" completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed ) {
                [BLStatusBar showTipMessageWithStatus:@"验证码发送成功"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[result getMsg]?:@""];
            }
        });
        
    }];
}

- (void)modifyPhone:(NSString *)phone vcode:(NSString *)vcode {
    BLUserDefaults *userDefault = [BLUserDefaults shareUserDefaults];
    NSString *password = [userDefault getPassword];
    [[BLAccount sharedAccount] modifyPhone:phone countryCode:self.countryField.text vcode:vcode password:password newpassword:password completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed ) {
                [BLStatusBar showTipMessageWithStatus:@"手机号修改成功"];
                [self.navigationController popViewControllerAnimated:YES];
                self.navigationController.interactivePopGestureRecognizer.enabled = NO;
            } else {
                [BLStatusBar showTipMessageWithStatus:[result getMsg]?:@""];
            }
        });
        
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
