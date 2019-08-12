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
#import "APConfigTableViewController.h"

@implementation ConfigureViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ssidNameField.delegate = self;
    self.passwordField.delegate = self;
    [self locatemap];
}

- (void)viewWillAppear:(BOOL)animated {
    self.ssidNameField.text = [self getCurrentSSIDInfo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[BLLet sharedLet].controller deviceConfigCancel];
}

- (IBAction)startConfigureButtonClick:(UIButton *)sender {
    [self.ssidNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    NSString *ssidName = self.ssidNameField.text;
    NSString *password = self.passwordField.text;
    

   
    
    if (sender.tag == 101) {
        [self showIndicatorOnWindowWithMessage:@"Configuring..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDate *date = [NSDate date];
            NSLog(@"====Start Config===");
            BLDeviceConfigResult *result = [[BLLet sharedLet].controller deviceConfig:ssidName password:password version:2 timeout:60];
            NSLog(@"====Config over! Spends(%fs)", [date timeIntervalSinceNow]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                if ([result succeed]) {
                    [BLStatusBar showTipMessageWithStatus:@"Configure Wi-Fi success"];
                    self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@) Did(%@) Devaddr(%@) Mac(%@)", (long)result.getError, result.getMsg, result.getDid, result.getDevaddr, result.getMac];
                } else {
                    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
                    self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
                }
                
            });
        });
    }else if (sender.tag == 102) {
        [self showIndicatorOnWindowWithMessage:@"Configuring..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDate *date = [NSDate date];
            NSLog(@"====Start Config===");
            BLDeviceConfigResult *result = [[BLLet sharedLet].controller deviceConfig:ssidName password:password version:3 timeout:60];
            NSLog(@"====Config over! Spends(%fs)", [date timeIntervalSinceNow]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                if ([result succeed]) {
                    [BLStatusBar showTipMessageWithStatus:@"Configure Wi-Fi success"];
                    self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@) Did(%@) Devaddr(%@) Mac(%@)", (long)result.getError, result.getMsg, result.getDid, result.getDevaddr, result.getMac];
                } else {
                    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
                    self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
                }
            });
        });
    }else if (sender.tag == 103) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Make sure you have connect to the device's Ap (maybe like \"BroadlinkProv\")" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"APconfigView" sender:nil];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
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

- (void)locatemap{
    CLLocationManager *locationManager = [[CLLocationManager alloc]init];
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        [locationManager requestAlwaysAuthorization];
        [locationManager requestWhenInUseAuthorization];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 5.0;
        [locationManager startUpdatingLocation];
    }
}


@end
