//
//  RetrievePasswordViewController.m
//  BLAPPSDKDemo
//

#import "RetrievePasswordViewController.h"
#import "RestPasswordViewController.h"
#import "BLLoadingButton.h"
#import "BLTheme.h"
#import <BLLetAccount/BLLetAccount.h>

@interface RetrievePasswordViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *accountTextField;
@property (nonatomic, strong) BLLoadingButton *nextButton;
@end

@implementation RetrievePasswordViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Forgot Password";
    [self buildUI];
}

- (void)buildUI {
    self.accountTextField = [BLTheme makeTextFieldWithPlaceholder:@"Phone / Email"];
    self.accountTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.accountTextField.delegate = self;

    self.nextButton = (BLLoadingButton *)[BLTheme makePrimaryButtonWithTitle:@"Send Code"
                                                                     target:self
                                                                     action:@selector(nextAction:)];

    [BLTheme installAuthFormOnView:self.view
                             title:@"Reset password"
                          subtitle:@"We'll send a verification code to your account"
                         formViews:@[self.accountTextField]
                     primaryButton:self.nextButton
                       footerViews:nil];
}

- (void)nextAction:(id)sender {
    [self.accountTextField resignFirstResponder];
    if (self.accountTextField.text.length == 0) {
        [self showTextOnly:@"Please enter phone or email"];
        return;
    }

    __weak typeof(self) weakSelf = self;
    self.nextButton.isLoading = YES;
    [[BLAccount sharedAccount] sendRetriveVCode:self.accountTextField.text completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.nextButton.isLoading = NO;
            if ([result succeed]) {
                RestPasswordViewController *vc = [RestPasswordViewController viewController];
                vc.accountText = weakSelf.accountTextField.text;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            } else {
                [weakSelf showSDKResult:result successMessage:nil];
            }
        });
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self nextAction:nil];
    return YES;
}

@end
