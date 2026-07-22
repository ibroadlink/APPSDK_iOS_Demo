//
//  CreateFamilyViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/7.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "CreateFamilyViewController.h"
#import "BLStatusBar.h"
#import "BLTheme.h"
#import <BLSFamily/BLSFamily.h>

@interface CreateFamilyViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *familyNameField;

@end

@implementation CreateFamilyViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Create Family";
    self.view.backgroundColor = [BLTheme backgroundColor];

    self.familyNameField = [BLTheme makeTextFieldWithPlaceholder:@"Family name"];
    self.familyNameField.delegate = self;

    UIButton *createButton = [BLTheme makePrimaryButtonWithTitle:@"Create"
                                                          target:self
                                                          action:@selector(createBtnClick)];

    [BLTheme installAuthFormOnView:self.view
                             title:@"New Home"
                          subtitle:@"Create a family to manage rooms and devices"
                         formViews:@[self.familyNameField]
                     primaryButton:createButton
                       footerViews:nil];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createBtnClick {
    [self.familyNameField resignFirstResponder];
    if (self.familyNameField.text.length == 0) {
        [self showTextOnly:@"Please enter a family name"];
        return;
    }

    BLSFamilyManager *manager = [BLSFamilyManager sharedFamily];
    [self showIndicatorOnWindow];
    [manager createDefaultFamilyWithInfo:self.familyNameField.text country:@"China" province:@"ZheJiang" city:@"HangZhou" completionHandler:^(BLSFamilyCreateResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                [BLStatusBar showTipMessageWithStatus:@"Create Family success!"];
                [self performSelector:@selector(goBack) withObject:nil afterDelay:1.0f];
            } else {
                [self showErrorCode:result.error msg:result.msg];
            }
        });
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
