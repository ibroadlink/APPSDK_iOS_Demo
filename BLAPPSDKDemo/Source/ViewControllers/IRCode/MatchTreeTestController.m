//
//  MatchTreeTestController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/4/3.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "MatchTreeTestController.h"
#import "RecoginzeIRCodeViewController.h"

#import "IRCodeMatchTreeInfo.h"
#import "IRCodeDownloadInfo.h"

#import "BLStatusBar.h"
#import <BLLetCore/BLLetCore.h>

@interface MatchTreeTestController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UITableView *ircodeIdTabel;
@property (weak, nonatomic) IBOutlet UITextView *resultText;

@end

@implementation MatchTreeTestController

+ (instancetype)viewController {
    MatchTreeTestController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ircodeIdTabel.delegate = self;
    self.ircodeIdTabel.dataSource = self;
    [self setExtraCellLineHidden:self.ircodeIdTabel];
    
    self.keyLabel.text = self.treeInfo.key;
    self.resultText.text = [self.treeInfo BLS_modelToJSONString];
}

- (NSString *)changeCodeArrayToHexString:(NSArray *)codeList {
    
    if (![BLCommonTools isEmptyArray:codeList]) {
        NSUInteger dataLen = codeList.count;
        char *ircodeByte = (char *)malloc(sizeof(char) * (2 * dataLen));
        if (ircodeByte == NULL) {
            BLLogError(@"ircode data malloc failed!");
        } else {
            for (int i = 0; i < dataLen; i++) {
                ircodeByte[i] = [codeList[i] charValue];
            }
            
            NSData *irdata = [NSData dataWithBytes:ircodeByte length:dataLen];
            return  [BLCommonTools data2hexString:irdata];
        }
        if (ircodeByte) {
            free(ircodeByte);
        }
    }
    
    return nil;
}

- (void)sendIRCode:(NSString *)code {
    NSLog(@"Send IRCode: %@", code);
    //发送红码
    BLStdData *stdStudyData = [[BLStdData alloc] init];
    [stdStudyData setValue:code forParam:@"irda"];
    
    BLController *blcontroller = [BLLet sharedLet].controller;
    BLStdControlResult *studyResult = [blcontroller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdStudyData action:@"set"];
    if ([studyResult succeed]) {
        [BLStatusBar showTipMessageWithStatus:@"Send Success"];
    } else {
        [BLStatusBar showTipMessageWithStatus:studyResult.msg];
    }
}


- (void)showConfirmAlertWithInfo:(NSDictionary *)info {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message" message:@"Does device work as the function ?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *ircodeid = info[@"ircodeid"];
        
        if ([BLCommonTools isEmpty:ircodeid]) {
            //Can not confirm ircodeid, must test chirdren tree info
            NSDictionary *chirdren = info[@"chirdren"];
            TreeInfo *chirdTreeInfo = [TreeInfo BLS_modelWithJSON:chirdren];
            
            MatchTreeTestController *vc = [MatchTreeTestController viewController];
            vc.devtype = self.devtype;
            vc.device = self.device;
            vc.treeInfo = chirdTreeInfo;
            
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            IRCodeDownloadInfo *info = [[IRCodeDownloadInfo alloc] init];
            info.ircodeid = ircodeid;
            info.devtype = self.devtype;
            
            RecoginzeIRCodeViewController *vc = [RecoginzeIRCodeViewController viewController];
            vc.downloadinfo = info;
            vc.device = self.device;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    [alertController addAction:action];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.treeInfo && self.treeInfo.codeList) {
        return self.treeInfo.codeList.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IRCODE_HOT_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    NSDictionary *info = self.treeInfo.codeList[indexPath.row];
    cell.textLabel.text = info[@"ircodeid"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *info = self.treeInfo.codeList[indexPath.row];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    self.resultText.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray *code = info[@"code"];
    NSString *ircode = [self changeCodeArrayToHexString:code];
    if (ircode) {
        [self sendIRCode:ircode];
    }
    
    [self showConfirmAlertWithInfo:info];
}


@end
