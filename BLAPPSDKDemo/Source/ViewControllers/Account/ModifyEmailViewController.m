//
//  ModifyEmailViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/25.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "ModifyEmailViewController.h"

#import "BLStatusBar.h"
#import <BLLetAccount/BLLetAccount.h>

@interface ModifyEmailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation ModifyEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.emailField.delegate = self;
}


- (IBAction)next:(UIButton *)sender {
    
    [self sendModifyEmailVCode:self.emailField.text];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please input verification code"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Verification code";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password";
    }];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSString *vcode = alert.textFields.firstObject.text;
                                                              NSString *password = alert.textFields[1].text;
                                                              [self modifyEmail:self.emailField.text vcode:vcode password:password];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sendModifyEmailVCode:(NSString *)email {
    [[BLAccount sharedAccount] sendModifyVCode:email completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed ) {
                [BLStatusBar showTipMessageWithStatus:@"Send verification code success!"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[result getMsg]?:@""];
            }
        });
    }];
}

- (void)modifyEmail:(NSString *)email vcode:(NSString *)vcode password:(NSString *)password {
    
    [[BLAccount sharedAccount] modifyEmail:email vcode:vcode password:password newpassword:password completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed ) {
                [BLStatusBar showTipMessageWithStatus:@"Modify email success!"];
                [self.navigationController popViewControllerAnimated:YES];
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
