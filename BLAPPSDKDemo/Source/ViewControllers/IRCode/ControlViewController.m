//
//  ControlViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/9.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "ControlViewController.h"
#import "AppDelegate.h"
#import "DeviceDB.h"

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
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.blcontroller = delegate.let.controller;
    self.blircode = delegate.let.ircode;
}

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
        //发送红码
        NSArray *myDeviceList = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
        for (BLDNADevice *device in myDeviceList) {
            //RM的pid
            if ([device.pid isEqualToString:@"00000000000000000000000037270000"]) {
                BLStdData *stdStudyData = [[BLStdData alloc] init];
                [stdStudyData setValue:result.ircode forParam:@"irda"];
                BLStdControlResult *studyResult = [self.blcontroller dnaControl:[device getDid] stdData:stdStudyData action:@"set"];
                if ([studyResult succeed]) {
                    [BLStatusBar showTipMessageWithStatus:@"发送成功"];
                }else{
                    [BLStatusBar showTipMessageWithStatus:studyResult.msg];
                }
            }
        }
        
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
@end
