//
//  ModifyPhoneViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/4.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "ModifyPhoneViewController.h"
#import "Tools.h"
#import <BLLetAccount/BLLetAccount.h>

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
    [self sendModifyPhoneVCode:self.phoneField.text countryCode:self.countryField.text];
    __weak typeof(self) weakSelf = self;
    [Tools presentAlertOn:self
                    title:@"Please input verification code"
                   fields:@[
                       @{@"placeholder": @"Verification code"},
                       @{@"placeholder": @"Password", @"secure": @YES}
                   ]
                  handler:^(NSArray<UITextField *> *textFields) {
                      [weakSelf modifyPhone:weakSelf.phoneField.text
                                countryCode:weakSelf.countryField.text
                                      vcode:textFields.firstObject.text
                                   password:textFields[1].text];
                  }];
}

- (void)sendModifyPhoneVCode:(NSString *)phone countryCode:(NSString *)countryCode {
    [[BLAccount sharedAccount] sendModifyVCode:phone countryCode:countryCode completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showSDKResult:result successMessage:@"Send verification code success!"];
        });
    }];
}

- (void)modifyPhone:(NSString *)phone countryCode:(NSString *)countryCode vcode:(NSString *)vcode password:(NSString *)password {

    [[BLAccount sharedAccount] modifyPhone:phone countryCode:countryCode vcode:vcode password:password newpassword:password completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed ) {
                [self showSDKResult:result successMessage:@"Modify phone number success!"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self showSDKResult:result successMessage:nil];
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
