//
//  AKeyToIdentifyViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/15.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "AKeyToIdentifyViewController.h"
#import <BLLetIRCode/BLLetIRCode.h>

#import "ControlViewController.h"
#import "BLStatusBar.h"
#import "DeviceDB.h"

@interface AKeyToIdentifyViewController ()
@property (weak, nonatomic) IBOutlet UILabel *RecoginzeTxt;
@property (weak, nonatomic) IBOutlet UILabel *resultTxt;
@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) BLIRCode *blircode;
@property (nonatomic, weak)NSTimer *stateTimer;
@end

@implementation AKeyToIdentifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blcontroller = [BLLet sharedLet].controller;
    self.blircode = [BLIRCode sharedIrdaCode];
}

- (void)dealloc {
    [_stateTimer invalidate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_stateTimer invalidate];
}

- (IBAction)identifyTheIRCode:(id)sender {
    [self.blircode recognizeIRCodeWithHexString:_RecoginzeTxt.text completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"response:%@", result.responseBody);
            if (result.responseBody) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultTxt.text = result.responseBody;
                });
                NSData *responseData = [result.responseBody dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                NSArray *downloadInfos = [responseDic objectForKey:@"downloadinfo"];
                if (downloadInfos && downloadInfos.count > 0) {
                    
                    self.randkey = downloadInfos[0][@"fixkey"];
                    self.downloadUrl = downloadInfos[0][@"downloadurl"];
                    NSString *name = downloadInfos[0][@"name"];
                    self.savePath = [self.blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:name];
                }
            }
        }else{
            [BLStatusBar showTipMessageWithStatus:result.msg];
        }


    }];
}
- (IBAction)downLoadIRCodeScript:(id)sender {
    [self downloadIRCodeScript:self.downloadUrl savePath:self.savePath randkey:self.randkey];
}

- (IBAction)getIRCodeBaseInfo:(id)sender {
    [self queryIRCodeScriptInfoSavePath:self.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_AC];
}
- (IBAction)getIRCodeData:(id)sender {
    if (self.savePath == nil) {
        [BLStatusBar showTipMessageWithStatus:@"identifyTheIRCode first!"];
        return;
    }
    [self performSegueWithIdentifier:@"controllerView" sender:self.savePath];
}

- (IBAction)RMLearnBtn:(id)sender {
    NSArray *myDeviceList = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];
    for (BLDNADevice *device in myDeviceList) {
        //RM的pid，这里需要替换你使用的RM设备的pid
        if ([device.pid isEqualToString:@"00000000000000000000000037270000"]) {
            BLStdData *stdStudyData = [[BLStdData alloc] init];
            [stdStudyData setValue:nil forParam:@"irdastudy"];
            //进入学习模式
            BLStdControlResult *studyResult = [self.blcontroller dnaControl:[device getDid] stdData:stdStudyData action:@"get"];
            if ([studyResult succeed]) {
                 if (![_stateTimer isValid]) {
                     _stateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
                         BLStdData *stdData = [[BLStdData alloc] init];
                         [stdData setValue:nil forParam:@"irda"];
                         //获取学习的红码
                         BLStdControlResult *irdaResult = [self.blcontroller dnaControl:[device getDid] stdData:stdData action:@"get"];
                         NSDictionary *dic = [[irdaResult getData] toDictionary];
                         if ([dic[@"vals"] count] != 0) {
                             self.RecoginzeTxt.text = dic[@"vals"][0][0][@"val"];
                             [self.stateTimer invalidate];
                         }else{
                             self.RecoginzeTxt.text = @"未学习红码";
                         }
                     }];
                 }
            }
        }
    }
    
}

- (void)downloadIRCodeScript:(NSString *_Nonnull)urlString savePath:(NSString *_Nonnull)path randkey:(NSString *_Nullable)randkey {
    [self.blircode downloadIRCodeScriptWithUrl:urlString savePath:path randkey:randkey completionHandler:^(BLDownloadResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"savepath:%@", result.savePath);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTxt.text = result.savePath;
            });
            
        }else{
            [BLStatusBar showTipMessageWithStatus:result.msg];
        }

    }];
}

- (void)queryIRCodeScriptInfoSavePath:(NSString *)savePath randkey:(NSString *)randkey deviceType:(NSInteger)devicetype {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLIRCodeInfoResult *result = [self.blircode queryIRCodeInfomationWithScript:savePath deviceType:devicetype];
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {
            NSLog(@"info:%@", result.infomation);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultTxt.text = result.infomation;
            });
            
        }else{
            [BLStatusBar showTipMessageWithStatus:result.msg];
        }
    });
    

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"controllerView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[ControlViewController class]]) {
            ControlViewController* opVC = (ControlViewController *)target;
            opVC.savePath = (NSString *)sender;
        }
    }
}
@end
