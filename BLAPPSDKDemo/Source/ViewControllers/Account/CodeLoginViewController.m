//
//  CodeLoginViewController.m
//  BLAPPSDKDemo
//

#import "CodeLoginViewController.h"
#import "UserViewController.h"
#import "BLUserDefaults.h"
#import "BLTheme.h"
#import "BLLoadingButton.h"
#import <BLLetAccount/BLLetAccount.h>
#import <Masonry/Masonry.h>

@interface CodeLoginViewController ()
@property (nonatomic, strong) UITextField *accountField;
@property (nonatomic, strong) UITextField *codeField;
@property (nonatomic, strong) UIButton *getCodeButton;
@property (nonatomic, strong) BLLoadingButton *loginButton;
@property (nonatomic, strong) BLAccount *account;
@property (nonatomic, assign) NSInteger countdown;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation CodeLoginViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Code Login";
    self.account = [BLAccount sharedAccount];
    [self buildUI];
}

- (void)dealloc {
    [self.timer invalidate];
}

- (void)buildUI {
    self.accountField = [BLTheme makeTextFieldWithPlaceholder:@"Phone / Email"];
    self.accountField.keyboardType = UIKeyboardTypeEmailAddress;
    self.accountField.delegate = self;
    self.accountField.text = [[BLUserDefaults shareUserDefaults] getUserName];

    self.codeField = [BLTheme makeTextFieldWithPlaceholder:@"Verification code"];
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    self.codeField.delegate = self;

    self.getCodeButton = [BLTheme makeSecondaryButtonWithTitle:@"Get Code"
                                                        target:self
                                                        action:@selector(getCodebtn:)];
    [self.getCodeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(50);
    }];

    UIStackView *codeRow = [[UIStackView alloc] initWithArrangedSubviews:@[self.codeField, self.getCodeButton]];
    codeRow.axis = UILayoutConstraintAxisHorizontal;
    codeRow.spacing = 10;
    codeRow.alignment = UIStackViewAlignmentFill;

    self.loginButton = (BLLoadingButton *)[BLTheme makePrimaryButtonWithTitle:@"Sign In"
                                                                      target:self
                                                                      action:@selector(codeLoginbtn:)];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Quick sign in"
                          subtitle:@"Login with a one-time verification code"
                         formViews:@[self.accountField, codeRow]
                     primaryButton:self.loginButton
                       footerViews:nil];
}

- (void)getCodebtn:(id)sender {
    NSString *account = self.accountField.text;
    if (account.length == 0) {
        [self showTextOnly:@"Please enter phone or email"];
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self.account sendFastVCode:account countryCode:@"0086" completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showSDKResult:result successMessage:@"Verification code has been sent"];
            if ([result succeed]) {
                [weakSelf startCountdown];
            }
        });
    }];
}

- (void)codeLoginbtn:(id)sender {
    [self resignFirstResponderForTextFields:@[self.accountField, self.codeField]];
    if (self.accountField.text.length == 0 || self.codeField.text.length == 0) {
        [self showTextOnly:@"Please enter account and code"];
        return;
    }

    __weak typeof(self) weakSelf = self;
    self.loginButton.isLoading = YES;
    [self.account fastLoginWithPhoneOrEmail:self.accountField.text
                                countrycode:@"0086"
                                      vcode:self.codeField.text
                                   logintry:nil
                          completionHandler:^(BLLoginResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.loginButton.isLoading = NO;
            if ([result succeed]) {
                [[BLUserDefaults shareUserDefaults] applyLoginWithUserName:weakSelf.accountField.text
                                                                    userId:[result getUserid]
                                                                 sessionId:[result getLoginsession]];
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
    [textField resignFirstResponder];
    return YES;
}

@end
