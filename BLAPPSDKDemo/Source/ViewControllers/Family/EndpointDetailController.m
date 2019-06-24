//
//  EndpointDetailController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/3/1.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "EndpointDetailController.h"
#import "OperateViewController.h"

#import "BLDeviceService.h"
#import "BLStatusBar.h"

@interface EndpointDetailController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *detailInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *deviceControlBtn;

- (IBAction)buttonClick:(UIButton *)sender;


@end

@implementation EndpointDetailController

+ (EndpointDetailController *)viewController {
    EndpointDetailController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"EndpointDetailController"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.deviceControlBtn.hidden = !self.isNeedDeviceControl;
    self.detailInfoLabel.text = [self.endpoint BLS_modelToJSONString];
    self.nameField.text = self.endpoint.friendlyName;
    self.nameField.delegate = self;
}


- (IBAction)buttonClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
            [self showDeviceControlView];
            break;
        case 101:
            [self ModifyEndPointInfo];
            break;
        case 102:
            [self deleteEndpoint];
            break;
        default:
            break;
    }
    
}

- (void)showDeviceControlView {
    [BLDeviceService sharedDeviceService].selectDevice = [self.endpoint toDNADevice];
    [self performSegueWithIdentifier:@"OperateView" sender:nil];
}

- (void)ModifyEndPointInfo {
    
    NSString *name = self.nameField.text;
    if ([BLCommonTools isEmpty:name]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Please input new name"]];
         return;
    }
    
    NSDictionary *dic = @{
                          @"attributeName": @"friendlyName",
                          @"attributeValue": name
                          };
    NSArray *attributes = @[dic];
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];

    [manager modifyEndpoint:self.endpoint.endpointId attributes:attributes completionHandler:^(BLBaseResult * _Nonnull result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Modify Endpoint Failed. Code:%ld MSG:%@", (long)result.status, result.msg]];
            }
        });
        
    }];
}

- (void)deleteEndpoint {
    
    BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
    [self showIndicatorOnWindow];

    [manager delEndpoint:self.endpoint.endpointId completionHandler:^(BLBaseResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
        });

        if ([result succeed]) {
            BLDNADevice *device = [self.endpoint toDNADevice];

            if (![BLCommonTools isEmpty:device.pDid]) {
                //子设备需要从网关里删除信息
                BLSubdevBaseResult *baseResult = [[BLLet sharedLet].controller subDevDelWithDid:device.pDid subDevDid:device.did];
                NSLog(@"subDevDel Code:%ld MSG:%@", (long)baseResult.status, baseResult.msg);
            }
            [[BLDeviceService sharedDeviceService] removeDevice:device.did];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Delete Endpoint Failed. Code:%ld MSG:%@", (long)result.status, result.msg]];
            });
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

@end
