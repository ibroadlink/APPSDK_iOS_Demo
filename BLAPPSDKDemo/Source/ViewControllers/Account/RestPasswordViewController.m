//
//  RestPasswordViewController.m
//  BLAPPSDKDemo
//

#import "RestPasswordViewController.h"
#import "LoginViewController.h"
#import "BLLoadingButton.h"
#import "BLTheme.h"
#import <BLLetAccount/BLLetAccount.h>

@interface RestPasswordViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *VCodeTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) BLLoadingButton *restPasswordButton;
@end

@implementation RestPasswordViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Set New Password";
    [self buildUI];
}

- (void)buildUI {
    self.VCodeTextField = [BLTheme makeTextFieldWithPlaceholder:@"Verification code"];
    self.VCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.VCodeTextField.delegate = self;

    self.passwordTextField = [BLTheme makePasswordFieldWithPlaceholder:@"New password"];
    self.passwordTextField.delegate = self;

    self.restPasswordButton = (BLLoadingButton *)[BLTheme makePrimaryButtonWithTitle:@"Update Password"
                                                                             target:self
                                                                             action:@selector(restPasswordAction:)];

    NSString *hint = self.accountText.length
        ? [NSString stringWithFormat:@"Enter the code sent to %@", self.accountText]
        : @"Enter the code and your new password";

    [BLTheme installAuthFormOnView:self.view
                             title:@"New password"
                          subtitle:hint
                         formViews:@[self.VCodeTextField, self.passwordTextField]
                     primaryButton:self.restPasswordButton
                       footerViews:nil];
}

- (void)restPasswordAction:(id)sender {
    [self resignFirstResponderForTextFields:@[self.VCodeTextField, self.passwordTextField]];
    if (self.VCodeTextField.text.length == 0 || self.passwordTextField.text.length == 0) {
        [self showTextOnly:@"Please enter code and new password"];
        return;
    }

    __weak typeof(self) weakSelf = self;
    self.restPasswordButton.isLoading = YES;
    [[BLAccount sharedAccount] retrivePassword:self.accountText
                                         vcode:self.VCodeTextField.text
                                   newPassword:self.passwordTextField.text
                             completionHandler:^(BLLoginResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.restPasswordButton.isLoading = NO;
            if ([result succeed]) {
                [weakSelf showSDKResult:result successMessage:@"Password updated"];
                UIViewController *target = nil;
                for (UIViewController *controller in weakSelf.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[LoginViewController class]]) {
                        target = controller;
                        break;
                    }
                }
                if (target) {
                    [weakSelf.navigationController popToViewController:target animated:YES];
                } else {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            } else {
                [weakSelf showSDKResult:result successMessage:nil];
            }
        });
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.VCodeTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self restPasswordAction:nil];
    }
    return YES;
}

@end
