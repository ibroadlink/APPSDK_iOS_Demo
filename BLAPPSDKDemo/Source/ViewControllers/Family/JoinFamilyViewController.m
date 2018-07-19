//
//  JoinFamilyViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2018/7/19.
//  Copyright © 2018 BroadLink. All rights reserved.
//

#import "JoinFamilyViewController.h"
#import "AppDelegate.h"

@interface JoinFamilyViewController () <UITextFieldDelegate>

@end

@implementation JoinFamilyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.familyCodeField.delegate = self;
}


- (IBAction)joinBtn:(id)sender {
    [self.familyCodeField resignFirstResponder];
    [[BLFamilyController sharedManager] joinFamilyWithQrcode:self.familyCodeField.text completionHandler:^(BLBaseResult * _Nonnull result) {
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
