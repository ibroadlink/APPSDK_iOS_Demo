//
//  RegisterViewController.m
//  BLAPPSDKDemo
//

#import "RegisterViewController.h"
#import "UserViewController.h"
#import "BLUserDefaults.h"
#import "BLTheme.h"
#import "BLLoadingButton.h"
#import <BLLetAccount/BLLetAccount.h>
#import <Masonry/Masonry.h>

@interface RegisterViewController ()
@property (nonatomic, strong) UITextField *countryField;
@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *codeField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *nickNameField;
@property (nonatomic, strong) UIButton *getCodeButton;
@property (nonatomic, strong) BLLoadingButton *registerButton;
@property (nonatomic, strong) BLAccount *account;
@property (nonatomic, assign) NSInteger countdown;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation RegisterViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Register";
    self.account = [BLAccount sharedAccount];
    [self buildUI];
}

- (void)dealloc {
    [self.timer invalidate];
}

- (void)buildUI {
    self.countryField = [BLTheme makeTextFieldWithPlaceholder:@"Country code (e.g. 0086)"];
    self.countryField.text = @"0086";
    self.countryField.keyboardType = UIKeyboardTypeNumberPad;
    self.countryField.delegate = self;

    self.accountField = [BLTheme makeTextFieldWithPlaceholder:@"Phone / Email"];
    self.accountField.keyboardType = UIKeyboardTypeEmailAddress;
    self.accountField.delegate = self;

    self.codeField = [BLTheme makeTextFieldWithPlaceholder:@"Verification code"];
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    self.codeField.delegate = self;

    self.getCodeButton = [BLTheme makeSecondaryButtonWithTitle:@"Get Code"
                                                        target:self
                                                        action:@selector(verificationCodeButtonClick:)];
    [self.getCodeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(50);
    }];

    UIStackView *codeRow = [[UIStackView alloc] initWithArrangedSubviews:@[self.codeField, self.getCodeButton]];
    codeRow.axis = UILayoutConstraintAxisHorizontal;
    codeRow.spacing = 10;

    self.passwordField = [BLTheme makePasswordFieldWithPlaceholder:@"Password"];
    self.passwordField.delegate = self;

    self.nickNameField = [BLTheme makeTextFieldWithPlaceholder:@"Nickname"];
    self.nickNameField.delegate = self;
    self.nickNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;

    self.registerButton = (BLLoadingButton *)[BLTheme makePrimaryButtonWithTitle:@"Create Account"
                                                                         target:self
                                                                         action:@selector(registerButtonClick:)];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Create account"
                          subtitle:@"Register a new BroadLink account"
                         formViews:@[self.countryField, self.accountField, codeRow, self.passwordField, self.nickNameField]
                     primaryButton:self.registerButton
                       footerViews:nil];
}

- (void)verificationCodeButtonClick:(UIButton *)sender {
    [self.view endEditing:YES];
    NSString *phoneHead = self.countryField.text;
    NSString *phoneBody = self.accountField.text;
    if (phoneBody.length == 0) {
        [self showTextOnly:@"Please enter phone or email"];
        return;
    }

    __weak typeof(self) weakSelf = self;
    void (^handler)(BLBaseResult *) = ^(BLBaseResult *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showSDKResult:result successMessage:@"Verification code has been sent"];
            if ([result succeed]) {
                [weakSelf startCountdown];
            }
        });
    };

    if (phoneHead.length > 0) {
        [self.account sendRegVCode:phoneBody countryCode:phoneHead completionHandler:handler];
    } else {
        [self.account sendRegVCode:phoneBody completionHandler:handler];
    }
}

- (void)registerButtonClick:(UIButton *)sender {
    [self.view endEditing:YES];

    NSString *phoneHead = self.countryField.text;
    NSString *phoneBody = self.accountField.text;
    NSString *vCode = self.codeField.text;
    NSString *password = self.passwordField.text;
    NSString *nickName = self.nickNameField.text;

    if (phoneBody.length == 0 || vCode.length == 0 || password.length == 0) {
        [self showTextOnly:@"Please fill in required fields"];
        return;
    }

    __weak typeof(self) weakSelf = self;
    self.registerButton.isLoading = YES;
    [self.account regist:phoneBody
                password:password
                nickname:nickName
                   vcode:vCode
                     sex:BL_ACCOUNT_MALE
                birthday:nil
             countryCode:phoneHead
                 country:nil
                iconPath:nil
       completionHandler:^(BLLoginResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.registerButton.isLoading = NO;
            if ([result succeed]) {
                [[BLUserDefaults shareUserDefaults] applyLoginWithUserName:nickName.length ? nickName : phoneBody
                                                                    userId:[result getUserid]
                                                                 sessionId:[result getLoginsession]];
                [weakSelf showSDKResult:result successMessage:@"Registered successfully"];
                [weakSelf.navigationController pushViewController:[UserViewController viewController] animated:YES];
            } else {
                [weakSelf showSDKResult:result successMessage:nil];
            }
        });
    }];
}

- (void)startCountdown {
    self.countdown = 60;
    self.getCodeButton.enabled = NO;
    [self updateCountdownTitle];
    [self.timer invalidate];
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        weakSelf.countdown -= 1;
        if (weakSelf.countdown <= 0) {
            [timer invalidate];
            weakSelf.getCodeButton.enabled = YES;
            [weakSelf.getCodeButton setTitle:@"Get Code" forState:UIControlStateNormal];
        } else {
            [weakSelf updateCountdownTitle];
        }
    }];
}

- (void)updateCountdownTitle {
    NSString *title = [NSString stringWithFormat:@"%lds", (long)self.countdown];
    [self.getCodeButton setTitle:title forState:UIControlStateNormal];
    [self.getCodeButton setTitle:title forState:UIControlStateDisabled];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSArray *fields = @[self.countryField, self.accountField, self.codeField, self.passwordField, self.nickNameField];
    NSUInteger idx = [fields indexOfObject:textField];
    if (idx != NSNotFound && idx + 1 < fields.count) {
        [fields[idx + 1] becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
