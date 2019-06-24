//
//  AKeyToIdentifyViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/15.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "AKeyToIdentifyViewController.h"
#import "ACControlViewController.h"

#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import <BLLetIRCode/BLLetIRCode.h>

@interface AKeyToIdentifyViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *recoginzeTxt;
@property (weak, nonatomic) IBOutlet UITextView *resultTxt;
@property (strong, nonatomic) BLDNADevice *device;

@end

@implementation AKeyToIdentifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recoginzeTxt.delegate = self;
    self.recoginzeTxt.text = @"2600ca008d950c3b0f1410380e3a0d160e160d3b0d150e150e3910150d160d3a0f36101411380d150f3a0e390d3910370f150f38103a0d3a0e1211140f1411121038101310150f3710380e390e150f160d160e1410140f131113101310380e3b0f351137123611ad8e9210370f1511370e390f140f1410380f1311130f39101211130f390f380f150f390f1310380f3810380f380f141038103710380f1411121014101310380f14101310380f3810381013101311121014101211131014101310370f3910361138103710000d05";
}

- (IBAction)identifyTheIRCode:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    
    //采用V3接口
    [blircode recognizeV3IRCodeWithHexString:_recoginzeTxt.text completionHandler:^(BLBaseBodyResult * _Nonnull result) {
        NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
        if ([result succeed]) {

            if (result.respbody) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.resultTxt.text = result.responseBody;
                });
                
                NSArray *downloadInfos = [result.respbody objectForKey:@"downloadinfo"];
                if (![BLCommonTools isEmptyArray:downloadInfos]) {
                    
                    self.randkey = downloadInfos[0][@"fixkey"];
                    self.downloadUrl = downloadInfos[0][@"downloadurl"];
                    NSString *name = downloadInfos[0][@"name"];
                    
                    BLController *blcontroller = [BLLet sharedLet].controller;
                    self.savePath = [blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:name];
                }
            }
        }else{
            [BLStatusBar showTipMessageWithStatus:result.msg];
        }
    }];
}

- (IBAction)downLoadIRCodeScript:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    [self downloadIRCodeScript:self.downloadUrl savePath:self.savePath randkey:self.randkey];
}

- (IBAction)getIRCodeBaseInfo:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    [self queryIRCodeScriptInfoSavePath:self.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_AC];
}

- (IBAction)getIRCodeData:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    if (self.savePath == nil) {
        [BLStatusBar showTipMessageWithStatus:@"identifyTheIRCode first!"];
        return;
    }
    
    ACControlViewController *vc = [ACControlViewController viewController];
    vc.savePath = self.savePath;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)RMLearnBtn:(id)sender {
    [self.recoginzeTxt resignFirstResponder];
    BLController *blcontroller = [BLLet sharedLet].controller;
    
    //进入学习模式
    BLStdData *stdStudyData = [[BLStdData alloc] init];
    [stdStudyData setValue:nil forParam:@"irdastudy"];
    BLStdControlResult *studyResult = [blcontroller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdStudyData action:@"get"];
    if ([studyResult succeed]) {
        for (int i = 0; i < 10; i++) {
            sleep(3);
            
            //获取学习的红码
            BLStdData *stdData = [[BLStdData alloc] init];
            [stdData setValue:nil forParam:@"irda"];
            
            BLStdControlResult *irdaResult = [blcontroller dnaControl:[self.device getDid] stdData:stdData action:@"get"];
            NSDictionary *dic = [[irdaResult getData] toDictionary];
            if ([dic[@"vals"] count] != 0) {
                self.recoginzeTxt.text = dic[@"vals"][0][0][@"val"];
                break;
            } else {
                self.recoginzeTxt.text = @"Can not get learn ircode";
            }
        }
    }
    
}

- (void)downloadIRCodeScript:(NSString *_Nonnull)urlString savePath:(NSString *_Nonnull)path randkey:(NSString *_Nullable)randkey {
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];

    [blircode downloadIRCodeScriptWithUrl:urlString savePath:path randkey:randkey completionHandler:^(BLDownloadResult * _Nonnull result) {
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
        BLIRCode *blircode = [BLIRCode sharedIrdaCode];
        BLIRCodeInfoResult *result = [blircode queryIRCodeInfomationWithScript:savePath deviceType:devicetype];
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
- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}
@end
