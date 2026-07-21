//
//  ModifyEmailViewController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/25.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "ModifyEmailViewController.h"

#import "Tools.h"
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
    __weak typeof(self) weakSelf = self;
    [Tools presentAlertOn:self
                    title:@"Please input verification code"
                   fields:@[
                       @{@"placeholder": @"Verification code"},
                       @{@"placeholder": @"Password", @"secure": @YES}
                   ]
                  handler:^(NSArray<UITextField *> *textFields) {
                      [weakSelf modifyEmail:weakSelf.emailField.text
                                      vcode:textFields.firstObject.text
                                   password:textFields[1].text];
                  }];
}

- (void)sendModifyEmailVCode:(NSString *)email {
    [[BLAccount sharedAccount] sendModifyVCode:email completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showSDKResult:result successMessage:@"Send verification code success!"];
        });
    }];
}

- (void)modifyEmail:(NSString *)email vcode:(NSString *)vcode password:(NSString *)password {
    
    [[BLAccount sharedAccount] modifyEmail:email vcode:vcode password:password newpassword:password completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed ) {
                [self showSDKResult:result successMessage:@"Modify email success!"];
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
