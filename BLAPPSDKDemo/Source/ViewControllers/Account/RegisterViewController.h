//
//  RegisterViewController.h
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface RegisterViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextField *phoneHeadField;
@property (weak, nonatomic) IBOutlet UITextField *phoneBodyField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *nickNameField;

- (IBAction)verificationCodeButtonClick:(UIButton *)sender;
- (IBAction)registerButtonClick:(UIButton *)sender;
@end
