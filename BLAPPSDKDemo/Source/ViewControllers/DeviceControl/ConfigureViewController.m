//
//  ConfigureViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "ConfigureViewController.h"
#import "BLStatusBar.h"
#import "AppDelegate.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ssidNameField.delegate = self;
    self.passwordField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.ssidNameField.text = [self getCurrentSSIDInfo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BLController *controller = delegate.let.controller;
    
    [controller deviceConfigCancel];
}

- (IBAction)startConfigureButtonClick:(id)sender {
    [self.ssidNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    NSString *ssidName = self.ssidNameField.text;
    NSString *password = self.passwordField.text;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BLController *controller = delegate.let.controller;
   
    [self showIndicatorOnWindowWithMessage:@"Configuring..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDate *date = [NSDate date];
        NSLog(@"====Start Config===");
        BLDeviceConfigResult *result = [controller deviceConfig:ssidName password:password version:2 timeout:75];
        NSLog(@"====Config over! Spends(%fs)", [date timeIntervalSinceNow]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                [BLStatusBar showTipMessageWithStatus:@"Configure Wi-Fi success"];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            }
        });
    });
}

- (NSString *)getCurrentSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    
    return [info objectForKey:@"SSID"];
}
#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}
@end
