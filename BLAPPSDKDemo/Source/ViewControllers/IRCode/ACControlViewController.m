//
//  ControlViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "ACControlViewController.h"

#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import <BLLetCore/BLLetCore.h>
#import <BLLetIRCode/BLLetIRCode.h>


@interface ACControlViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *powerSwitch;
@property (weak, nonatomic) IBOutlet UITextField *modeTextField;
@property (weak, nonatomic) IBOutlet UITextField *windSpeedTextField;
@property (weak, nonatomic) IBOutlet UITextField *directionTextField;
@property (weak, nonatomic) IBOutlet UITextField *tempTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultText;

@property (strong, nonatomic) UIPickerView *pickerView;
@end

@implementation ACControlViewController

+ (instancetype)viewController {
    ACControlViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tempTextField.delegate = self;
    self.windSpeedTextField.delegate = self;
    self.modeTextField.delegate = self;
    self.directionTextField.delegate = self;
}

//    /*空调开关状态*/
//    state
//    0,       /*关闭*/
//    1        /*开启*/
//
//    /*空调模式*/
//    mode
//    0,       /*自动*/
//    1,       /*制冷*/
//    2,       /*除湿*/
//    3,       /*通风*/
//    4        /*加热*/
//
//    /*空调风速*/
//    speed
//    0,        /*自动*/
//    1,        /*低速*/
//    2,        /*中速*/
//    3         /*高速*/

- (IBAction)queryACIRCodeData:(id)sender {
    
    [self.tempTextField resignFirstResponder];
    [self.windSpeedTextField resignFirstResponder];
    [self.modeTextField resignFirstResponder];
    [self.directionTextField resignFirstResponder];
    
    BLQueryIRCodeParams *params = [[BLQueryIRCodeParams alloc] init];
    params.temperature = [self.tempTextField.text integerValue];
    params.state = self.powerSwitch.on;
    params.speed = [self.windSpeedTextField.text integerValue];
    params.mode = [self.modeTextField.text integerValue];
    params.direct = [self.directionTextField.text integerValue];
    
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    BLIRCodeDataResult *result = [blircode queryACIRCodeDataWithScript:self.savePath params:params];
    NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
    if ([result succeed]) {
        NSLog(@"data:%@", result.ircode);
        self.resultText.text = result.ircode;
    }
}

- (IBAction)changeToUnitCode:(UIButton *)sender {
    
    [self.tempTextField resignFirstResponder];
    [self.windSpeedTextField resignFirstResponder];
    [self.modeTextField resignFirstResponder];
    [self.directionTextField resignFirstResponder];
    
    NSString *waveCode = self.resultText.text;
    
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    NSString *unitCode = [blircode waveCodeChangeToUnitCode:waveCode];
    
    if (unitCode) {
        NSLog(@"unitCode:%@", unitCode);
        self.resultText.text = unitCode;
    } else {
        self.resultText.text = @"Change Wave Code To Unit Code Failed!";
    }
}


- (IBAction)sendACIRCodeData:(id)sender {
    
    [self.tempTextField resignFirstResponder];
    [self.windSpeedTextField resignFirstResponder];
    [self.modeTextField resignFirstResponder];
    [self.directionTextField resignFirstResponder];
    
    if (!self.device) {
        [self showSelectRMDevice];
    } else {
        [self sendACIRCodeWithDevice];
    }
    
}

- (void)showSelectRMDevice {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    
    if (deviceService.manageDevices.allKeys.count == 0) {
        [BLStatusBar showTipMessageWithStatus:@"Please add device to sdk first!"];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please RM Device" preferredStyle:UIAlertControllerStyleActionSheet];
        [deviceService.manageDevices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull did, BLDNADevice * _Nonnull dev, BOOL * _Nonnull stop) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:did style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.device = dev;
                [self sendACIRCodeWithDevice];
            }];
            [alert addAction:action];
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)sendACIRCodeWithDevice {
    //发送红码
    BLStdData *stdStudyData = [[BLStdData alloc] init];
    [stdStudyData setValue:self.resultText.text forParam:@"irda"];
    
    BLController *blcontroller = [BLLet sharedLet].controller;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLStdControlResult *studyResult = [blcontroller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdStudyData action:@"set"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([studyResult succeed]) {
                
                [BLStatusBar showTipMessageWithStatus:@"Send success!"];
            } else {
                [BLStatusBar showTipMessageWithStatus:studyResult.msg];
            }
        });
        
    });
    
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 100) {
        [textField resignFirstResponder];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"模式" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"自动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"0";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"制冷" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"1";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"除湿" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"2";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"通风" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"3";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"加热" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.modeTextField.text = @"4";
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (textField.tag == 101) {
        [textField resignFirstResponder];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"风速" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"自动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.windSpeedTextField.text = @"0";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"低速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.windSpeedTextField.text = @"1";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"中速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.windSpeedTextField.text = @"2";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"高速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.windSpeedTextField.text = @"3";
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (textField.tag == 102) {
        [textField resignFirstResponder];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"风向" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"自动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.directionTextField.text = @"0";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"固定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.directionTextField.text = @"1";
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (textField.tag == 103) {
        
    }

}

@end
