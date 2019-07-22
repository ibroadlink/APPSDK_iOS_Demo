//
//  LightDeviceControlController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/7/10.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "LightDeviceControlController.h"

@interface LightDeviceControlController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *lightControlSlider;
@property (weak, nonatomic) IBOutlet UITextField *timeField;

@property (assign, nonatomic) NSUInteger currentValue;
@property (assign, nonatomic) NSUInteger sendTime;
@property (assign, nonatomic) NSUInteger diffTime;

@end

@implementation LightDeviceControlController

+ (instancetype)viewController {
    LightDeviceControlController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sendTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.diffTime = 50;
    
    self.timeField.keyboardType = UIKeyboardTypeNumberPad; //键盘模式
    [self initSlider];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryCurrentLightValue];
}

- (IBAction)buttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
            [self minusValue];
            break;
        case 101:
            [self plusValue];
            break;
        case 103:
            [self confirmDiffTime];
            break;
        default:
            break;
    }
}

- (void)initSlider {
    
    self.lightControlSlider.minimumValue = 1.0;
    self.lightControlSlider.maximumValue = 100.0;
    self.lightControlSlider.value = 20.0;
    [self.lightControlSlider setContinuous:YES];
    
    [self.lightControlSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)queryCurrentLightValue {
    
    BLController *controller = [BLLet sharedLet].controller;
    
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setParams:@[] values:@[]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLStdControlResult *result = [controller dnaControl:self.device.did stdData:stdData action:@"get"];
        if ([result succeed]) {
            BLStdData *retData = result.data;
            self.currentValue = [[retData valueForParam:@"brightness"] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lightControlSlider.value = self.currentValue;
            });
        }
    });
}

- (void)plusValue {
    
    if (self.currentValue == 100) {
        return;
    }
    
    [self sendDeviceControlWithValue:++self.currentValue];
    self.lightControlSlider.value = self.currentValue;
}

- (void)minusValue {
    
    if (self.currentValue == 1) {
        return;
    }
    
    [self sendDeviceControlWithValue:--self.currentValue];
    self.lightControlSlider.value = self.currentValue;
}

- (void)confirmDiffTime {
    
    [self.timeField resignFirstResponder];
    NSString *input = self.timeField.text;
    
    if (![BLCommonTools isEmpty:input]) {
        self.diffTime = [input integerValue];
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    NSUInteger currentValue = (NSUInteger)slider.value;
    
    if (self.currentValue == currentValue) {
        return;
    }
    self.currentValue = currentValue;
    
    NSUInteger nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
    if (nowTime > self.sendTime + self.diffTime) {
        self.sendTime = nowTime;
        [self sendDeviceControlWithValue:currentValue];
    }
}

- (void)sendDeviceControlWithValue:(NSUInteger)value {
    BLController *controller = [BLLet sharedLet].controller;
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:[NSNumber numberWithUnsignedInteger:value] forParam:@"brightness"];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLStdControlResult *result = [controller dnaControl:self.device.did stdData:stdData action:@"set"];
        if ([result succeed]) {
            NSLog(@"Set Value : %lu success", (unsigned long)value);
        } else {
            NSLog(@"Set Value : %lu failed", (unsigned long)value);
        }
    });
}

- (void)setCurrentValue:(NSUInteger)currentValue {
    _currentValue = currentValue;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *value = [NSString stringWithFormat:@"当前亮度：%lu", (unsigned long)self.currentValue];
        self.currentValueLabel.text = value;
    });
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 退出键盘
    [textField resignFirstResponder];
    return YES;
}

@end
