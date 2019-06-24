//
//  RecoginzeIRCodeViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/14.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "RecoginzeIRCodeViewController.h"
#import "ACControlViewController.h"
#import "TVControllTableViewController.h"

#import <BLLetCore/BLLetCore.h>
#import <BLLetIRCode/BLLetIRCode.h>

@interface RecoginzeIRCodeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *ResultTxt;
@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) BLIRCode *blircode;
@property (nonatomic, strong) NSMutableArray *tvList;

@end

@implementation RecoginzeIRCodeViewController

+ (instancetype)viewController {
    RecoginzeIRCodeViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blcontroller = [BLLet sharedLet].controller;
    self.blircode = [BLIRCode sharedIrdaCode];
    self.tvList = [NSMutableArray arrayWithCapacity:0];
    
    if (![BLCommonTools isEmpty:self.downloadinfo.name]) {
        self.title = self.downloadinfo.name;
    } else {
        self.title = self.downloadinfo.ircodeid;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)downLoadIRCodeScript:(id)sender {
    NSString *ircodeid = self.downloadinfo.ircodeid;
    self.downloadinfo.savePath = [self.blcontroller.queryIRCodeScriptPath stringByAppendingPathComponent:ircodeid];
    [self downloadIRCodeScript:ircodeid savePath:self.downloadinfo.savePath];
}

- (IBAction)getIRCodeBaseInfo:(id)sender {
    if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_AC) {
        [self queryIRCodeScriptInfoSavePath:self.downloadinfo.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_AC];
    } else if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_TV || self.downloadinfo.devtype == BL_IRCODE_DEVICE_TV_BOX){
        [self queryCloudCodeScriptInfoSavePath:self.downloadinfo.savePath randkey:nil deviceType:BL_IRCODE_DEVICE_TV];
    }
}

- (IBAction)getIRCodeData:(id)sender {
    if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_AC) {
        [self performSegueWithIdentifier:@"controllerView" sender:self.downloadinfo.savePath];
    }else if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_TV || self.downloadinfo.devtype == BL_IRCODE_DEVICE_TV_BOX){
        [self performSegueWithIdentifier:@"TVcontrollerView" sender:self.downloadinfo.savePath];
    }
    
}

- (void)downloadIRCodeScript:(NSString *_Nonnull)urlString savePath:(NSString *_Nonnull)path randkey:(NSString *_Nullable)randkey {
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.blircode downloadIRCodeScriptWithUrl:urlString savePath:path randkey:randkey completionHandler:^(BLDownloadResult * _Nonnull result) {
            NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                NSLog(@"savepath:%@", result.savePath);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.ResultTxt.text = result.savePath;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.ResultTxt.text = [NSString stringWithFormat:@"Download failed:%ld \nMsg:%@", (long)result.status, result.msg];
                });
            }
        }];
    });
}

- (void)downloadIRCodeScript:(NSString *)ircodeid savePath:(NSString *_Nonnull)path {
    NSString *mtag = @"";
    if (self.downloadinfo.devtype == BL_IRCODE_DEVICE_AC) {
        mtag = @"gz";
    }
    
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.blircode downloadIRCodeScriptWithIRCodeid:ircodeid mtag:mtag savePath:path completionHandler:^(BLDownloadResult * _Nonnull result) {
            NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
            [self hideIndicatorOnWindow];
            if ([result succeed]) {
                NSLog(@"savepath:%@", result.savePath);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.ResultTxt.text = result.savePath;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.ResultTxt.text = [NSString stringWithFormat:@"Download failed:%ld \nMsg:%@", (long)result.status, result.msg];
                });
            }
        }];
    });

}

- (void)queryIRCodeScriptInfoSavePath:(NSString *)savePath randkey:(NSString *)randkey deviceType:(NSInteger)devicetype {
    
//    BLController *blcontroller = [BLLet sharedLet].controller;
//    NSString *path = [[blcontroller queryIRCodeScriptPath] stringByAppendingPathComponent:@"奥克斯_5935"];
    
    BLIRCodeInfoResult *result = [self.blircode queryIRCodeInfomationWithScript:savePath deviceType:devicetype];
    NSLog(@"statue:%ld msg:%@", (long)result.error, result.msg);
    if ([result succeed]) {
        NSLog(@"info:%@", result.infomation);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ResultTxt.text = result.infomation;
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ResultTxt.text = [NSString stringWithFormat:@"Query failed:%ld \nMsg:%@", (long)result.status, result.msg];
        });
    }
}

- (void)queryCloudCodeScriptInfoSavePath:(NSString *)savePath randkey:(NSString *)randkey deviceType:(NSInteger)devicetype {
    NSDictionary *infomation =[NSJSONSerialization JSONObjectWithData:[[NSString stringWithContentsOfFile:savePath usedEncoding:nil error:nil] dataUsingEncoding:NSUTF8StringEncoding] options:NSUTF8StringEncoding error:nil] ;
    NSArray *infoList = [infomation objectForKey:@"functionList"];
    NSString *function = @"";
    for (NSDictionary *dic in infoList) {
        function = [function stringByAppendingString:[NSString stringWithFormat:@"%@,",dic[@"function"]]];
    }
    [self.tvList removeAllObjects];
    NSArray *funarray = [self matchString:function toRegexString:@"\\w+"];
    [self.tvList addObjectsFromArray:funarray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ResultTxt.text = function;
    });
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"controllerView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[ACControlViewController class]]) {
            ACControlViewController* opVC = (ACControlViewController *)target;
            opVC.savePath = (NSString *)sender;
            opVC.device = self.device;
        }
    }else if ([segue.identifier isEqualToString:@"TVcontrollerView"]){
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[TVControllTableViewController class]]) {
            TVControllTableViewController* opVC = (TVControllTableViewController *)target;
            opVC.savePath = (NSString *)sender;
            opVC.device = self.device;
            opVC.tvList = self.tvList;
            opVC.devtype = _downloadinfo.devtype;
        }
    }
}


/**
 *  正则匹配返回符合要求的字符串 数组
 *
 *  @param string   需要匹配的字符串
 *  @param regexStr 正则表达式
 *
 *  @return 符合要求的字符串 数组 (按(),分级,正常0)
 */
- (NSArray *)matchString:(NSString *)string toRegexString:(NSString *)regexStr
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray * matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    //match: 所有匹配到的字符,根据() 包含级
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0; i < [match numberOfRanges]; i++) {
            //以正则中的(),划分成不同的匹配部分
            NSString *component = [string substringWithRange:[match rangeAtIndex:i]];
            [array addObject:component];
        }
    }
    return array;
}

@end
