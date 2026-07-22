//
//  ModifyEmailViewController.m
//  BLAPPSDKDemo
//

#import "ModifyEmailViewController.h"
#import "Tools.h"
#import "BLTheme.h"
#import "BLLoadingButton.h"
#import <BLLetAccount/BLLetAccount.h>

@interface ModifyEmailViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) BLLoadingButton *nextButton;
@end

@implementation ModifyEmailViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Change Email";
    [self buildUI];
}

- (void)buildUI {
    self.emailField = [BLTheme makeTextFieldWithPlaceholder:@"New email address"];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.delegate = self;

    self.nextButton = (BLLoadingButton *)[BLTheme makePrimaryButtonWithTitle:@"Send Code & Continue"
                                                                     target:self
                                                                     action:@selector(next:)];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Update email"
                          subtitle:@"Verify your new email with a code"
                         formViews:@[self.emailField]
                     primaryButton:self.nextButton
                       footerViews:nil];
}

- (void)next:(UIButton *)sender {
    [self.emailField resignFirstResponder];
    if (self.emailField.text.length == 0) {
        [self showTextOnly:@"Please enter an email"];
        return;
    }

    [self sendModifyEmailVCode:self.emailField.text];
    __weak typeof(self) weakSelf = self;
    [Tools presentAlertOn:self
                    title:@"Enter verification code"
                   fields:@[
                       @{@"placeholder": @"Verification code"},
                       @{@"placeholder": @"Current password", @"secure": @YES}
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
            [self showSDKResult:result successMessage:@"Verification code sent"];
        });
    }];
}

- (void)modifyEmail:(NSString *)email vcode:(NSString *)vcode password:(NSString *)password {
    [[BLAccount sharedAccount] modifyEmail:email
                                     vcode:vcode
                                  password:password
                               newpassword:password
                         completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed) {
                [self showSDKResult:result successMessage:@"Email updated"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self showSDKResult:result successMessage:nil];
            }
        });
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
