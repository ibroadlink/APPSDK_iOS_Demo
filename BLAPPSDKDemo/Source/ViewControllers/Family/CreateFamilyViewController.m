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
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BLFamilyController *manager = delegate.familyController;
    
    BLFamilyInfo *info = [[BLFamilyInfo alloc]init];
    info.familyName = self.familyNameField.text;
//    [manager createNewFamilyWithInfo:info iconImage:nil completionHandler:^(BLFamilyInfoResult * _Nonnull result) {
//        NSLog(@"result:%@",result);
//    }];
    
    [manager createDefaultFamilyWithInfo:self.familyNameField.text country:@"China" province:@"ZheJiang" city:@"HangZhou" completionHandler:^(BLFamilyInfoResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result succeed]) {
                NSLog(@"familyID:%@ version:%@ Name:%@ Description:%@", result.familyInfo.familyId, result.familyInfo.familyVersion, result.familyInfo.familyName, result.familyInfo.familyDescription);
                [BLStatusBar showTipMessageWithStatus:@"Create Family success!"];
                [self performSelector:@selector(goBack) withObject:nil afterDelay:2.0f];
            } else {
                NSLog(@"ERROR :%@", result.msg);
                [BLStatusBar showTipMessageWithStatus:[@"Create Family failed! " stringByAppendingString:result.msg]];
            }
        });
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
