//
//  JoinFamilyViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/19.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "JoinFamilyViewController.h"

#import "BLNewFamilyManager.h"
#import "BLStatusBar.h"

@interface JoinFamilyViewController () <UITextFieldDelegate>

@end

@implementation JoinFamilyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.familyCodeField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.familyCodeField.text = self.qCode;
}

- (IBAction)joinBtn:(id)sender {
    [self.familyCodeField resignFirstResponder];
    
    BLNewFamilyManager *familyManager = [BLNewFamilyManager sharedFamily];
    
    [familyManager joinFamilyWithQrcode:self.familyCodeField.text completionHandler:^(BLSFamilyInfoResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result succeed]) {
                [BLStatusBar showTipMessageWithStatus:@"Join Family success!"];
                [self performSelector:@selector(goBack) withObject:nil afterDelay:2.0f];
            } else {
                NSLog(@"ERROR :%@", result.msg);
                [BLStatusBar showTipMessageWithStatus:[@"Join Family failed! " stringByAppendingString:result.msg]];
            }
        });
    }];
}

- (IBAction)QRcodeBtn:(id)sender {
    [self performSegueWithIdentifier:@"QcodeView" sender:nil];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}
@end
