//
//  RetrievePasswordViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2018/6/27.
//  Copyright © 2018年 BroadLink. All rights reserved.
//

#import "RetrievePasswordViewController.h"
#import <BLLetAccount/BLLetAccount.h>

#import "BLLoadingButton.h"
#import "RestPasswordViewController.h"

@interface RetrievePasswordViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet BLLoadingButton *nextButton;

@end

@implementation RetrievePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewInit];
}

- (void)viewInit {
    self.accountTextField.delegate = self;
}

- (IBAction)nextAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    self.nextButton.isLoading = YES;
    [[BLAccount sharedAccount] sendRetriveVCode:self.accountTextField.text completionHandler:^(BLBaseResult * _Nonnull result) {
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.nextButton.isLoading = NO;
                [weakSelf performSegueWithIdentifier:@"retrievePassword" sender:weakSelf.accountTextField.text];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.nextButton.isLoading = NO;
                [weakSelf showSDKResult:result successMessage:nil];
            });
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"retrievePassword"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[RestPasswordViewController class]]) {
            RestPasswordViewController* opVC = (RestPasswordViewController *)target;
            opVC.accountText = (NSString *)sender;
        }
    }
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
