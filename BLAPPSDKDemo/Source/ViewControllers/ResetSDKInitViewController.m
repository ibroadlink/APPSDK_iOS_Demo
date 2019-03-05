//
//  RestSDKInitViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/3/4.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "ResetSDKInitViewController.h"
#import "AppDelegate.h"
#import "BLUserDefaults.h"
@interface ResetSDKInitViewController () <UITextViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *packNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *LicenseLabel;

@end

@implementation ResetSDKInitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.packNameLabel.delegate = self;
    self.LicenseLabel.delegate = self;
    self.packNameLabel.text = [BLConfigParam sharedConfigParam].packName;
    self.LicenseLabel.text = [BLConfigParam sharedConfigParam].sdkLicense;
}

- (IBAction)resetTheLicense:(id)sender {
    [BLConfigParam sharedConfigParam].packName = self.packNameLabel.text; // set package name
    [BLLet sharedLetWithLicense:self.LicenseLabel.text];               // Init APPSDK
    
    BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
    [userDefault setPackName:[BLConfigParam sharedConfigParam].packName];
    [userDefault setLicense:[BLConfigParam sharedConfigParam].sdkLicense];

    NSString *message = [NSString stringWithFormat:@"Reset The License Success,Lid:%@",[BLConfigParam sharedConfigParam].licenseId];
    [BLStatusBar showTipMessageWithStatus:message];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
