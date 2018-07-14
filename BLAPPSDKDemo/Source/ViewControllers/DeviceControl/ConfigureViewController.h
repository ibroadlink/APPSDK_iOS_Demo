//
//  ConfigureViewController.h
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "BaseViewController.h"

@interface ConfigureViewController : BaseViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ssidNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)startConfigureButtonClick:(id)sender;
@end
