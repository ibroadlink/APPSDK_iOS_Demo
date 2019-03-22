//
//  ControlViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "ControlViewController.h"

#import "BLStatusBar.h"
#import "DeviceDB.h"
#import <BLLetCore/BLLetCore.h>
#import <BLLetIRCode/BLLetIRCode.h>


@interface ControlViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) BLIRCode *blircode;
@property (weak, nonatomic) IBOutlet UISwitch *powerSwitch;
@property (weak, nonatomic) IBOutlet UITextField *modeTextField;
@property (weak, nonatomic) IBOutlet UITextField *windSpeedTextField;
@property (weak, nonatomic) IBOutlet UITextField *directionTextField;
@property (weak, nonatomic) IBOutlet UITextField *tempTextField;
@property (weak, nonatomic) IBOutlet UITextView *resultText;

@property (strong, nonatomic) UIPickerView *pickerView;
@end

@implementation ControlViewController
int tag = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    _tempTextField.delegate = self;
    _windSpeedTextField.delegate = self;
    _modeTextField.delegate = self;
    _directionTextField.delegate = self;

    self.blcontroller = [BLLet sharedLet].controller;
    self.blircode = [BLIRCode sharedIrdaCode];
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
    
    [_tempTextField resignFirstResponder];
    [_windSpeedTextField resignFirstResponder];
    [_modeTextField resignFirstResponder];
    [_directionTextField resignFirstResponder];
    
    BLQueryIRCodeParams *params = [[BLQueryIRCodeParams alloc] init];
    params.temperature = [_tempTextField.text integerValue];
    params.state = _powerSwitch.on;
    params.speed = [_windSpeedTextField.text integerValue];
    params.mode = [_modeTextField.text integerValue];
    params.direct = [_directionTextField.text integerValue];
    
    BLIRCodeDataResult *result = [self.blircode queryACIRCodeDataWithScript:self.savePath params:params];
    NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
    if ([result succeed]) {
        NSLog(@"data:%@", result.ircode);
        _resultText.text = result.ircode;
    }
}

- (IBAction)changeToUnitCode:(UIButton *)sender {
    
    [_tempTextField resignFirstResponder];
    [_windSpeedTextField resignFirstResponder];
    [_modeTextField resignFirstResponder];
    [_directionTextField resignFirstResponder];
    
    NSString *waveCode = _resultText.text;
    NSString *unitCode = [self.blircode waveCodeChangeToUnitCode:waveCode];
    
    if (unitCode) {
        NSLog(@"unitCode:%@", unitCode);
        _resultText.text = unitCode;
    } else {
        _resultText.text = @"Change Wave Code To Unit Code Failed!";
    }
}


- (IBAction)sendACIRCodeData:(id)sender {
    
    [_tempTextField resignFirstResponder];
    [_windSpeedTextField resignFirstResponder];
    [_modeTextField resignFirstResponder];
    [_directionTextField resignFirstResponder];
    
    //发送红码
    BLStdData *stdStudyData = [[BLStdData alloc] init];
    [stdStudyData setValue:_resultText.text forParam:@"irda"];
    BLStdControlResult *studyResult = [self.blcontroller dnaControl:[self.device getDid] stdData:stdStudyData action:@"set"];
    if ([studyResult succeed]) {
        [BLStatusBar showTipMessageWithStatus:@"发送成功"];
    }else{
        [BLStatusBar showTipMessageWithStatus:studyResult.msg];
    }
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
    }else if (textField.tag == 101) {
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
    }else if (textField.tag == 102) {
        [textField resignFirstResponder];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"风向" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"自动" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.directionTextField.text = @"0";
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"固定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.directionTextField.text = @"1";
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (textField.tag == 103) {
        
    }

}

@end
