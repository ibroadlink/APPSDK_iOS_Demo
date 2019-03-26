//
//  OperateViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//
#import "OperateViewController.h"
#import "GeneralTimerControlView.h"

#import "AppMacro.h"
#import "BLStatusBar.h"
#import "SSZipArchive.h"
#import "BLDeviceService.h"

@interface OperateViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *device;

@property (nonatomic, strong) NSArray *operateButtonArray;

@property (weak, nonatomic) IBOutlet UITextView *deviceInfoView;
@property (weak, nonatomic) IBOutlet UITableView *operateTableView;

@end

@implementation OperateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    self.device = deviceService.selectDevice;
    
    NSDictionary *info = [self.device BLS_modelToJSONObject];
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
    self.deviceInfoView.text = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];

    self.operateButtonArray = @[
                                @"Device Status Query",
                                @"Device Time Query",
                                @"Device Passthough",
                                @"Device Control",
                                @"Timer Task Functions",
                                @"GateWay Functions",
                                @"Fastcon Functions",
                                @"Device Firmware Query",
                                @"Device Firmware Upgrade",
                                @"RM Device Demo",
                                @"SP Device Demo",
                                @"A1 Device Demo"
                                ];
    
    self.operateTableView.delegate = self;
    self.operateTableView.dataSource = self;
    [self setExtraCellLineHidden:self.operateTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - table delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.operateButtonArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"OPERATE TABLEVIEW";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.operateButtonArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self getDeviceState];
            break;
        case 1:
            [self getServerTime];
            break;
        case 2:
            [self dataPassthough];
            break;
        case 3:
            [self dnaControl];
            break;
        case 4:
            [self generalTimerControl];
            break;
        case 5:
            [self gateWayControl];
            break;
        case 6:
            [self fastconNoConfig];
            break;
        case 7:
            [self getFirmwareVersion];
            break;
        case 8:
            [self upgradeFirmVersion];
            break;
        case 9:
            [self rmDeviceController];
            break;
        case 10:
            [self SPControl];
            break;
        case 11:
            [self A1Control];
            break;
        default:
            break;
    }
}


#pragma mark - private method
- (void)networkState {
    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:[_device getDid]];
    NSString *stateString = @"State UnKown";
    switch (state) {
        case BL_DEVICE_STATE_LAN:
            stateString = @"LAN";
            break;
        case BL_DEVICE_STATE_REMOTE:
            stateString = @"REMOTE";
            break;
        case BL_DEVICE_STATE_OFFLINE:
            stateString = @"OFFLINE";
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *netstateLabel = (UILabel *)[self.view viewWithTag:105];
        netstateLabel.text = [NSString stringWithFormat:@"NetState:%@", stateString];
    });
}

- (void)getDeviceState {
    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:self.device.did];
    
    NSString *stateString = @"State UnKown";
    switch (state) {
        case BL_DEVICE_STATE_LAN:
            stateString = @"LAN";
            break;
        case BL_DEVICE_STATE_REMOTE:
            stateString = @"REMOTE";
            break;
        case BL_DEVICE_STATE_OFFLINE:
            stateString = @"OFFLINE";
            break;
        default:
            break;
    }
    
    _resultText.text = [NSString stringWithFormat:@"state: %ld - %@", (long)state, stateString];
}

- (void)getFirmwareVersion {
    BLFirmwareVersionResult *result = [[BLLet sharedLet].controller queryFirmwareVersion:[_device getDid]];
    if ([result succeed]) {
        _resultText.text = [NSString stringWithFormat:@"Firmware Version:%@", [result getVersion]];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)upgradeFirmVersion {
    //Get URL From Servers
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"upgradeFirmware" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"upgrade Firmware Url";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *upgradeFirmwareUrl = alertController.textFields.firstObject.text;
        BLBaseResult *result = [[BLLet sharedLet].controller upgradeFirmware:[self.device getDid] url:upgradeFirmwareUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
        });
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)dataPassthough {
    [self performSegueWithIdentifier:@"DataPassthoughView" sender:nil];
}

- (void)dnaControl {
    //是否下载了脚本，需要先下载脚本才能控制设备
    [self isDownloadScript];
    [self performSegueWithIdentifier:@"DNAControlView" sender:nil];
}

- (void)SPControl {
    if ([self isDownloadScript]) {
        NSString *ProfileStr = [self getDeviceProfile];
        if([ProfileStr isEqualToString:SMART_SP]){
            [self performSegueWithIdentifier:@"SPminiControlView" sender:nil];
        }else{
            [BLStatusBar showTipMessageWithStatus:@"Not SP device"];
        }
    }
}

- (void)A1Control {
    if ([self isDownloadScript]) {
        NSString *ProfileStr = [self getDeviceProfile];
        if([ProfileStr isEqualToString:SMART_A1]){
            [self performSegueWithIdentifier:@"A1ControlView" sender:nil];
        }else{
            [BLStatusBar showTipMessageWithStatus:@"Not A1 device"];
        }
    }
}

- (void)gateWayControl {
    if ([self isDownloadScript]) {
        [self performSegueWithIdentifier:@"GateWayControlView" sender:nil];
    }
}

- (void)rmDeviceController {
    if ([self isDownloadScript]) {
        NSString *ProfileStr = [self getDeviceProfile];
        if([ProfileStr isEqualToString:SMART_RM]){
            [self performSegueWithIdentifier:@"RMminiControlView" sender:nil];
        } else {
            [BLStatusBar showTipMessageWithStatus:@"Not RM device"];
        }
    }
}

- (void)webViewControl {
    if ([self copyCordovaJsToUIPathWithFileName:DNAKIT_CORVODA_JS_FILE] ) {
        [self performSegueWithIdentifier:@"DeviceWebControlView" sender:nil];
    }
}

- (void)generalTimerControl {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please input query device did or sdid" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Device did or sdid";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *did = alertController.textFields.firstObject.text;
        dispatch_async(dispatch_get_main_queue(), ^{
            GeneralTimerControlView *vc = [GeneralTimerControlView viewController];
            vc.sdid = did;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)fastconNoConfig {
    [self performSegueWithIdentifier:@"fastconControlView" sender:nil];
}

//查询设备数据上报
- (void)queryDeviceData {
    BLBaseBodyResult *result = [[BLLet sharedLet].controller queryDeviceDataWithDid:[_device getDid] familyId:@"" startTime:@"2018-03-26_17:00:00" endTime:@"2018-03-27_22:00:00" type:@"fw_spminielec_v1"];
    if ([result succeed]) {
        _resultText.text = [NSString stringWithFormat:@"responseBody : %@", result.responseBody];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    NSLog(@"queryDeviceDataResult%@",result.responseBody);
}

//获取设备服务器时间
- (void)getServerTime {
    BLDeviceTimeResult *result = [[BLLet sharedLet].controller queryDeviceTime:self.device.did];
    if ([result succeed]) {
        _resultText.text = [NSString stringWithFormat:@"Time:%@ diff:%ld", result.time, (long)result.difftime];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

//设备复位
- (void)deviceReset {
    BLController *controller = [BLLet sharedLet].controller;
    NSString *result = [controller dnaControl:self.device.did subDevDid:nil dataStr:@"{}" command:@"dev_reset" scriptPath:nil];
    NSLog(@"result: %@", result);
    
    BLBaseResult *baseResult = [BLBaseResult BLS_modelWithJSON:result];
    if ([baseResult succeed]) {
        //复位成功
        [[BLDeviceService sharedDeviceService] removeDevice:self.device.did];
        [BLDeviceService sharedDeviceService].selectDevice = nil;
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)baseResult.getError, baseResult.getMsg];
    }
}

//获取设备连接服务器信息
- (void)getDeviceServiceConnectInfo {
    BLController *controller = [BLLet sharedLet].controller;
    BLBaseResult *result = [controller queryDeviceConnectServerInfo:self.device.did];
    NSLog(@"result: %ld", (long)result.status);
    
    _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
}

- (BOOL)copyCordovaJsToUIPathWithFileName:(NSString*)fileName {
    NSString *uiPath = [[[BLLet sharedLet].controller queryUIPath:[_device getPid]] stringByDeletingLastPathComponent];  //  ../Let/ui/
    NSString *fullPathFileName = [uiPath stringByAppendingPathComponent:fileName];  // ../Let/ui/fileName
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPathFileName] == NO) {
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:path toPath:fullPathFileName error:&error];
        if (success) {
            NSLog(@"%@ copy success",fileName);
            return YES;
        } else {
            NSLog(@"%@ copy failed",fileName);
            return NO;
        }
    }
    
    return YES;
}

- (NSString *)getDeviceProfile {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:self.device.pid];
    if ([result succeed]) {
        NSString *profileStr = [result getProfile];
        NSDictionary *dic = [BLCommonTools deserializeMessageJSON:profileStr];
        NSArray *srvStrArray = dic[@"srvs"];
        if (![BLCommonTools isEmptyArray:srvStrArray]) {
            return srvStrArray.firstObject;
        }
    }
    return nil;
}

- (BOOL)isDownloadScript {
    NSString *profileFile = [[BLLet sharedLet].controller queryScriptFileName:[self.device getPid]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:profileFile]) {
        [BLStatusBar showTipMessageWithStatus:@"Please download script first!"];
        return NO;
    }
    return YES;
}


@end
