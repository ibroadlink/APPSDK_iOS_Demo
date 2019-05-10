//
//  RestSDKInitViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/3/4.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "ResetSDKInitViewController.h"
#import "BLUserDefaults.h"

#import <BLLetCore/BLLetCore.h>

@interface ResetSDKInitViewController () <UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *packNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *LicenseLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enableCloudCluster;
@property (weak, nonatomic) IBOutlet UITextField *cloudClusterHostField;

@end

@implementation ResetSDKInitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.packNameLabel.delegate = self;
    self.LicenseLabel.delegate = self;
    self.packNameLabel.text = [BLConfigParam sharedConfigParam].packName;
    self.LicenseLabel.text = [BLConfigParam sharedConfigParam].sdkLicense;
    self.cloudClusterHostField.text = [BLConfigParam sharedConfigParam].appServiceHost;
    
    BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
    self.enableCloudCluster.on = [userDefault getAppServiceEnable];
}

- (IBAction)resetTheLicense:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"WARNING" message:@"APP will be restarted" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        BLUserDefaults* userDefault = [BLUserDefaults shareUserDefaults];
        [userDefault setPackName:self.packNameLabel.text];
        [userDefault setLicense:self.LicenseLabel.text];
        [userDefault setAppServiceEnable: (self.enableCloudCluster.isOn ? 1 : 0)];
        [userDefault setAppServiceHost:self.cloudClusterHostField.text];
        
        [userDefault setUserName:nil];
        [userDefault setUserId:nil];
        [userDefault setSessionId:nil];
        
        exit(0);
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
