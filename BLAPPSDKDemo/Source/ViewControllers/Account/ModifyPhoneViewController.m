//
//  ModifyPhoneViewController.m
//  BLAPPSDKDemo
//

#import "ModifyPhoneViewController.h"
#import "Tools.h"
#import "BLTheme.h"
#import "BLLoadingButton.h"
#import <BLLetAccount/BLLetAccount.h>

@interface ModifyPhoneViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *countryField;
@property (nonatomic, strong) UITextField *phoneField;
@property (nonatomic, strong) BLLoadingButton *nextButton;
@end

@implementation ModifyPhoneViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Change Phone";
    [self buildUI];
}

- (void)buildUI {
    self.countryField = [BLTheme makeTextFieldWithPlaceholder:@"Country code"];
    self.countryField.text = @"0086";
    self.countryField.keyboardType = UIKeyboardTypeNumberPad;
    self.countryField.delegate = self;

    self.phoneField = [BLTheme makeTextFieldWithPlaceholder:@"New phone number"];
    self.phoneField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneField.delegate = self;

    self.nextButton = (BLLoadingButton *)[BLTheme makePrimaryButtonWithTitle:@"Send Code & Continue"
                                                                     target:self
                                                                     action:@selector(next:)];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Update phone"
                          subtitle:@"Verify your new number with a code"
                         formViews:@[self.countryField, self.phoneField]
                     primaryButton:self.nextButton
                       footerViews:nil];
}

- (void)next:(id)sender {
    [self.view endEditing:YES];
    if (self.phoneField.text.length == 0) {
        [self showTextOnly:@"Please enter a phone number"];
        return;
    }

    [self sendModifyPhoneVCode:self.phoneField.text countryCode:self.countryField.text];
    __weak typeof(self) weakSelf = self;
    [Tools presentAlertOn:self
                    title:@"Enter verification code"
                   fields:@[
                       @{@"placeholder": @"Verification code"},
                       @{@"placeholder": @"Current password", @"secure": @YES}
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
            [self showSDKResult:result successMessage:@"Verification code sent"];
        });
    }];
}

- (void)modifyPhone:(NSString *)phone countryCode:(NSString *)countryCode vcode:(NSString *)vcode password:(NSString *)password {
    [[BLAccount sharedAccount] modifyPhone:phone
                               countryCode:countryCode
                                     vcode:vcode
                                  password:password
                               newpassword:password
                         completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.succeed) {
                [self showSDKResult:result successMessage:@"Phone updated"];
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
