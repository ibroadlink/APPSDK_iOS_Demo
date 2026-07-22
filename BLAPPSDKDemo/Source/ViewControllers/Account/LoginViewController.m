//
//  LoginViewController.m
//  BLAPPSDKDemo
//

#import "LoginViewController.h"
#import "UserViewController.h"
#import "RetrievePasswordViewController.h"
#import "RegisterViewController.h"
#import "BLUserDefaults.h"
#import "BLLoadingButton.h"
#import "BLTheme.h"
#import <BLLetAccount/BLLetAccount.h>

@interface LoginViewController ()
@property (nonatomic, strong) UITextField *userNameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) BLLoadingButton *loginButton;
@end

@implementation LoginViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Sign In";
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 强制登录入口隐藏返回时，同时禁用侧滑返回，避免回到首页
    if (self.navigationItem.hidesBackButton) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.userNameField.text.length == 0) {
        self.userNameField.text = [[BLUserDefaults shareUserDefaults] getUserName];
    }
}

- (void)buildUI {
    self.userNameField = [BLTheme makeTextFieldWithPlaceholder:@"Phone number / email"];
    self.userNameField.keyboardType = UIKeyboardTypeEmailAddress;
    self.userNameField.delegate = self;
    self.userNameField.text = [[BLUserDefaults shareUserDefaults] getUserName];

    self.passwordField = [BLTheme makePasswordFieldWithPlaceholder:@"Password"];
    self.passwordField.delegate = self;

    self.loginButton = (BLLoadingButton *)[BLTheme makePrimaryButtonWithTitle:@"Sign In"
                                                                      target:self
                                                                      action:@selector(loginButtonClick:)];

    UIButton *forgot = [BLTheme makeLinkButtonWithTitle:@"Forgot password?"
                                                 target:self
                                                 action:@selector(forgotPassword)];
    UIButton *registerLink = [BLTheme makeLinkButtonWithTitle:@"Create account"
                                                       target:self
                                                       action:@selector(goRegister)];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Welcome back"
                          subtitle:@"Sign in with your BroadLink account"
                         formViews:@[self.userNameField, self.passwordField]
                     primaryButton:self.loginButton
                       footerViews:@[forgot, registerLink]];
}

- (void)loginButtonClick:(UIButton *)sender {
    [self resignFirstResponderForTextFields:@[self.userNameField, self.passwordField]];

    NSString *userName = self.userNameField.text;
    NSString *password = self.passwordField.text;
    if (userName.length == 0 || password.length == 0) {
        [self showTextOnly:@"Please enter account and password"];
        return;
    }

    __weak typeof(self) weakSelf = self;
    self.loginButton.isLoading = YES;
    [[BLAccount sharedAccount] login:userName password:password completionHandler:^(BLLoginResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.loginButton.isLoading = NO;
            if ([result succeed]) {
                [[BLUserDefaults shareUserDefaults] applyLoginWithUserName:userName
                                                                    userId:[result getUserid]
                                                                 sessionId:[result getLoginsession]];
                [weakSelf.navigationController pushViewController:[UserViewController viewController] animated:YES];
            } else {
                [weakSelf showSDKResult:result successMessage:nil];
            }
        });
    }];
}

- (void)forgotPassword {
    [self.navigationController pushViewController:[RetrievePasswordViewController viewController] animated:YES];
}

- (void)goRegister {
    [self.navigationController pushViewController:[RegisterViewController viewController] animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameField) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self loginButtonClick:self.loginButton];
    }
    return YES;
}

@end
