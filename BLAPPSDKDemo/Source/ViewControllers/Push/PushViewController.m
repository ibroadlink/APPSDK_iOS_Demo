//
//  PushViewController.m
//  BLAPPSDKDemo
//
//  Created by hongkun.bai on 2019/4/28.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "PushViewController.h"
#import "BLSNotificationService.h"
#import "BLDeviceService.h"

@interface PushViewController ()
@property (weak, nonatomic) IBOutlet UITextView *deviceInfoView;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (nonatomic, strong) BLDNADevice *device;
@end

@implementation PushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (instancetype)viewController {
    PushViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (IBAction)buttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
            [self reportToken];
            break;
        case 101:
            [self pushSetting];
            break;
        case 102:
            [self userLogout];
            break;
        case 103:
            [self showDeviceList];
            break;
        case 104:
            [self showDeviceList];
            break;
            
        default:
            break;
    }
}

- (void)reportToken {
    [[BLSNotificationService sharedInstance] registerDeviceCompletionHandler:^(NSString * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultTextView.text = result;
        });
        
    }];
}

- (void)pushSetting {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Enable" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BLSNotificationService sharedInstance] setAllPushState:YES completionHandler:^(NSString * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTextView.text = result;
            });
        }];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Disable" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BLSNotificationService sharedInstance] setAllPushState:NO completionHandler:^(NSString * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTextView.text = result;
            });
        }];
    }]];
    [alertView addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertView animated:YES completion:nil];
    
}

- (void)userLogout {
    [[BLSNotificationService sharedInstance] userLogoutCompletionHandler:^(NSString * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultTextView.text = result;
        });
    }];
}


//选择设备
- (void)showDeviceList {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Please Select Device" preferredStyle:UIAlertControllerStyleActionSheet];
    [deviceService.manageDevices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull did, BLDNADevice * _Nonnull dev, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@%@",dev.name,did] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.device = dev;
            if (self.device) {
                NSString *profile = [self getDeviceProfile];
                [self showCatDialog:profile];
            }
        }];
        [alertController addAction:action];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//显示修改srvs
- (void)showCatDialog:(NSString *)profile {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Input category" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = profile;
        textField.placeholder = @"srvs";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *srvs = alertController.textFields.firstObject.text;
        NSArray *categorys = [NSArray arrayWithObject:srvs];
        //查询模板
        [[BLSNotificationService sharedInstance] queryCategory:categorys TemplateWithCompletionHandler:^(NSString * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
            
               self.resultTextView.text = result;
            });
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//获取profile
- (NSString *)getDeviceProfile {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:self.device.pid];
    if ([result succeed]) {
        NSString *profileStr = [result getProfile];
        self.deviceInfoView.text = profileStr;
        NSDictionary *dic = [BLCommonTools deserializeMessageJSON:profileStr];
        NSArray *srvStrArray = dic[@"srvs"];
        if (![BLCommonTools isEmptyArray:srvStrArray]) {
            return srvStrArray.firstObject;
        }
    }
    return nil;
}

- (void)queryLinkageList {
    [[BLSNotificationService sharedInstance] queryLinkageInfoWithCompletionHandler:^(NSString * _Nonnull result) {
        
    }];
}

@end
