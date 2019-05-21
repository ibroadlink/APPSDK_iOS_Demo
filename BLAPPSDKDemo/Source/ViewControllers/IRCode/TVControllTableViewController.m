//
//  TVControllTableViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/15.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "TVControllTableViewController.h"
#import <BLLetIRCode/BLLetIRCode.h>

#import "AppDelegate.h"
#import "BLStatusBar.h"
@interface TVControllTableViewController ()
@property (nonatomic, strong) BLController *blcontroller;
@property (nonatomic, strong) BLIRCode *blircode;
@end

@implementation TVControllTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blcontroller = [BLLet sharedLet].controller;
    self.blircode = [BLIRCode sharedIrdaCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tvList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"TVControllCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.textLabel.text = _tvList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取的ircode使用RM发射接口发射
    NSString *ircode = [self queryTVIRCodeDataWithScript:self.savePath funcname:self.tvList[indexPath.row]];
    NSLog(@"ircode: %@", ircode);
    //发送红码
    BLStdData *stdStudyData = [[BLStdData alloc] init];
    [stdStudyData setValue:ircode forParam:@"irda"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLStdControlResult *studyResult = [self.blcontroller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdStudyData action:@"set"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([studyResult succeed]) {
                [BLStatusBar showTipMessageWithStatus:@"Send Success"];
            }else{
                [BLStatusBar showTipMessageWithStatus:studyResult.msg];
            }
        });
        
    });
    
}

- (NSString *)queryTVIRCodeDataWithScript:(NSString *_Nonnull)savePath funcname:(NSString *_Nonnull)funcname {
    NSDictionary *infomation =[NSJSONSerialization JSONObjectWithData:[[NSString stringWithContentsOfFile:savePath usedEncoding:nil error:nil] dataUsingEncoding:NSUTF8StringEncoding] options:NSUTF8StringEncoding error:nil] ;
    NSArray *infoList = [infomation objectForKey:@"functionList"];

    for (NSDictionary *info in infoList) {
        if (funcname == info[@"function"]) {
            NSArray *dataArray = [info objectForKey:@"code"];
            if (![BLCommonTools isEmptyArray:dataArray]) {
                char *ircodeByte = NULL;
                NSUInteger dataLen = dataArray.count;
                ircodeByte = (char *)malloc(sizeof(char) * (2 * dataLen));
                if (ircodeByte == NULL) {
                    BLLogError(@"ircode data malloc failed!");
                } else {
                    for (int i = 0; i < dataLen; i++) {
                        ircodeByte[i] = [dataArray[i] charValue];
                    }
                    
                    NSData *irdata = [NSData dataWithBytes:ircodeByte length:dataLen];
                    return  [BLCommonTools data2hexString:irdata];
                }
                if (ircodeByte) {
                    free(ircodeByte);
                }
            }
        }
        
    }
    
    return nil;
}

@end
