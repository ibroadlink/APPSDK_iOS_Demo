//
//  CreateFamilyViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/7.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "CreateFamilyViewController.h"
#import "BLStatusBar.h"
#import "AppDelegate.h"
#import "BLNewFamilyManager.h"

@interface CreateFamilyViewController () <UITextFieldDelegate>

@end

@implementation CreateFamilyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.familyNameField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createBtnClick:(UIButton *)sender {
    NSLog(@"create family");
    [self.familyNameField resignFirstResponder];
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    
    [self showIndicatorOnWindow];
    [manager createDefaultFamilyWithInfo:self.familyNameField.text country:@"China" province:@"ZheJiang" city:@"HangZhou" completionHandler:^(BLSFamilyCreateResult * _Nonnull result) {
        
        if ([result succeed]) {
            BLSFamilyInfo *familyInfo = result.data;
            NSLog(@"familyID:%@ Name:%@ Description:%@", familyInfo.familyid, familyInfo.name, familyInfo.desc);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [BLStatusBar showTipMessageWithStatus:@"Create Family success!"];
                [self performSelector:@selector(goBack) withObject:nil afterDelay:2.0f];
            });
            
        } else {
            NSLog(@"ERROR :%@", result.msg);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [BLStatusBar showTipMessageWithStatus:[@"Create Family failed! " stringByAppendingString:result.msg]];
            });
            
        }
    }];
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
