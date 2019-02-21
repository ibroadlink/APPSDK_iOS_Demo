//
//  FamilyDetailViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/17.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "FamilyDetailViewController.h"
#import "OperateViewController.h"
#import "ControlViewController.h"

#import "BLNewFamilyManager.h"

#import "BLStatusBar.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FamilyDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *familyIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyCreateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyCreateUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyMasterLabel;

- (IBAction)buttonClick:(UIButton *)sender;
- (IBAction)barButtonClick:(UIBarButtonItem *)sender;

@end

@implementation FamilyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSubViews];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubViews {
    
    if (self.familyInfo) {
        self.familyIdLabel.text = [@"FamilyId:" stringByAppendingString:self.familyInfo.familyid];
        self.familyNameLabel.text = [@"FamilyName:" stringByAppendingString:self.familyInfo.name];
        self.familyAddressLabel.text = [@"FamilyAddress:" stringByAppendingString:[NSString stringWithFormat:@"%@ %@ %@", self.familyInfo.countryCode, self.familyInfo.provinceCode, self.familyInfo.cityCode]];
        self.familyCreateTimeLabel.text = [@"FamilyCreateTime:" stringByAppendingString:self.familyInfo.createTime];
        self.familyCreateUserLabel.text = [@"FamilyCreateUser:" stringByAppendingString:self.familyInfo.createUser];
        self.familyMasterLabel.text = [@"FamilyMaster:" stringByAppendingString:self.familyInfo.master];
    }
    
}


//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        BLFamilyController *familyController = [BLFamilyController sharedManager];
//        BLModuleInfo *blmoduleInfo = self.deviceGroupArray[indexPath.section][indexPath.row];
//
//        [familyController delModuleWithId:blmoduleInfo.moduleId fromFamilyId:self.familyId familyVersion:self.familyAllInfo.familyBaseInfo.familyVersion completionHandler:^(BLModuleControlResult * _Nonnull result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if ([result succeed]) {
//                    NSLog(@"Del module success:%ld Msg:%@", (long)result.error, result.msg);
//                    [BLStatusBar showTipMessageWithStatus:@"Del Module Success"];
//                    [self queryFamilyAllInfoWithId:self.familyId];
//                } else {
//                    NSLog(@"Del module error:%ld Msg:%@", (long)result.error, result.msg);
//                    [BLStatusBar showTipMessageWithStatus:[@"Del Module Failed! " stringByAppendingString:result.msg]];
//                }
//            });
//        }];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    BLModuleInfo *blmoduleInfo = self.deviceGroupArray[indexPath.section][indexPath.row];
//    if (blmoduleInfo.moduleDevs.count > 0) {
//        BLModuleIncludeDev *moduleDevice = blmoduleInfo.moduleDevs[0];
//        BLDNADevice *device = [delegate.let.controller getDevice:moduleDevice.did];
//
//        if (blmoduleInfo.moduleType == BLSDKModuleType_RM_AC) {
//            NSString *extend = blmoduleInfo.extend;
//            NSData *jsonData = [extend dataUsingEncoding:NSUTF8StringEncoding];
//            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//            NSString *codeUrl = dic[@"codeUrl"];
//            NSString *savePath = [delegate.let.controller.queryIRCodeScriptPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gz",blmoduleInfo.moduleId]];
//            NSMutableDictionary *paramDic = [BLCommonTools getURLParameters:codeUrl];
//            [[BLIRCode sharedIrdaCode] downloadIRCodeScriptWithUrl:codeUrl savePath:savePath randkey:paramDic[@"mkey"] completionHandler:^(BLDownloadResult * _Nonnull result) {}];
//            [self performSegueWithIdentifier:@"controllerView" sender:savePath];
//        } else {
//            [self performSegueWithIdentifier:@"OperateView" sender:device];
//        }
//    }
//
//}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"OperateView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[OperateViewController class]]) {
            OperateViewController* opVC = (OperateViewController *)target;
            opVC.device = (BLDNADevice *)sender;
        }
    }else if ([segue.identifier isEqualToString:@"controllerView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[ControlViewController class]]) {
            ControlViewController* opVC = (ControlViewController *)target;
            opVC.savePath = (NSString *)sender;
        }
    }else if ([segue.identifier isEqualToString:@"controllerView"]) {
        
    }else if ([segue.identifier isEqualToString:@"RoomListView"]) {
        
    }
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
            [self modifyFamilyInfo];
            break;
        case 101:
            [self showMemberListView];
            break;
        case 102:
            [self showRoomListView];
            break;
        case 103:
            [self showEndpointListView];
            break;
        default:
            break;
    }
    
}

- (IBAction)barButtonClick:(UIBarButtonItem *)sender {
}

- (void)modifyFamilyInfo {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Modify Family Name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Please input new family name";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alertController.textFields.firstObject.text;
        BLSFamilyInfo *info = self.familyInfo;
        info.name = name;
        
        [self showIndicatorOnWindow];
        BLNewFamilyManager *manager = [BLNewFamilyManager sharedFamily];
        [manager modifyFamilyInfo:info completionHandler:^(BLBaseResult * _Nonnull result) {
            if ([result succeed]) {
                self.familyInfo.name = name;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self initSubViews];
            });
        }];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showMemberListView {
    [self performSegueWithIdentifier:@"MemberListView" sender:nil];
}

- (void)showRoomListView {
    [self performSegueWithIdentifier:@"RoomListView" sender:nil];
}

- (void)showEndpointListView {
    [self performSegueWithIdentifier:@"EndpointListView" sender:nil];
}

@end
