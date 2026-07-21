//
//  OperateViewController.m
//  BLAPPSDKDemo
//
//  Created by 朱俊杰 on 16/8/1.
//  Copyright © 2016年 BroadLink. All rights reserved.
//
#import "OperateViewController.h"
#import "GeneralTimerControlView.h"
#import "FastconGroupDeviceViewController.h"

#import "AppMacro.h"
#import "BLStatusBar.h"
#import "SSZipArchive.h"
#import "BLDeviceService.h"
#import "Tools.h"

typedef NS_ENUM(NSInteger, OperateAction) {
    OperateActionDeviceStatus,
    OperateActionDeviceTime,
    OperateActionDataPassthrough,
    OperateActionDNAControl,
    OperateActionTimer,
    OperateActionGateway,
    OperateActionFastcon,
    OperateActionFirmwareQuery,
    OperateActionFirmwareUpgrade,
    OperateActionRM,
    OperateActionSP,
    OperateActionA1,
    OperateActionStartLogRedirect,
    OperateActionStopLogRedirect,
    OperateActionFastconGroup,
};

@interface OperateViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *device;

@property (nonatomic, strong) NSArray *operateButtonArray;

@property (nonatomic, strong) NSString *logfile;
@property (nonatomic, strong) NSDateFormatter *formatter;

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
                                @"A1 Device Demo",
                                @"Start Log Redirect",
                                @"Stop Log Redirect",
                                @"FastconGroupDevice"
                                ];
    
    self.operateTableView.delegate = self;
    self.operateTableView.dataSource = self;
    [self setExtraCellLineHidden:self.operateTableView];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [self.formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopDeviceLogRedirect];
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
    switch ((OperateAction)indexPath.row) {
        case OperateActionDeviceStatus:
            [self getDeviceState];
            break;
        case OperateActionDeviceTime:
            [self getServerTime];
            break;
        case OperateActionDataPassthrough:
            [self dataPassthough];
            break;
        case OperateActionDNAControl:
            [self dnaControl];
            break;
        case OperateActionTimer:
            [self generalTimerControl];
            break;
        case OperateActionGateway:
            [self gateWayControl];
            break;
        case OperateActionFastcon:
            [self fastconNoConfig];
            break;
        case OperateActionFirmwareQuery:
            [self getFirmwareVersion];
            break;
        case OperateActionFirmwareUpgrade:
            [self upgradeFirmVersion];
            break;
        case OperateActionRM:
            [self rmDeviceController];
            break;
        case OperateActionSP:
            [self SPControl];
            break;
        case OperateActionA1:
            [self A1Control];
            break;
        case OperateActionStartLogRedirect:
            [self startDeviceLogRedirect];
        break;
        case OperateActionStopLogRedirect:
            [self stopDeviceLogRedirect];
            break;
        case OperateActionFastconGroup:
            [self fastconGroupDevice];
            break;
        default:
            break;
    }
}


#pragma mark - private method
- (void)networkState {
    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:[Tools controlDidForDevice:self.device]];
    NSString *stateString = [Tools stringForDeviceState:state];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel *netstateLabel = (UILabel *)[self.view viewWithTag:105];
        netstateLabel.text = [NSString stringWithFormat:@"NetState:%@", stateString];
    });
}

- (void)getDeviceState {
    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:[Tools controlDidForDevice:self.device]];
    NSString *stateString = [Tools stringForDeviceState:state];
    _resultText.text = [NSString stringWithFormat:@"state: %ld - %@", (long)state, stateString];
}

- (void)getFirmwareVersion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLFirmwareVersionResult *result = [[BLLet sharedLet].controller queryFirmwareVersion:[Tools controlDidForDevice:self.device]];
        if ([result succeed]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultText.text = [NSString stringWithFormat:@"Firmware Version:%@", [result getVersion]];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
            });
            
        }
    });
    
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BLBaseResult *result = [[BLLet sharedLet].controller upgradeFirmware:[Tools controlDidForDevice:self.device] url:upgradeFirmwareUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
            });
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
    if ([Tools copyCordovaJsNamed:DNAKIT_CORVODA_JS_FILE forPid:self.device.pid]) {
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
    BLBaseBodyResult *result = [[BLLet sharedLet].controller queryDeviceDataWithDid:[Tools controlDidForDevice:self.device] familyId:@"" startTime:@"2018-03-26_17:00:00" endTime:@"2018-03-27_22:00:00" type:@"fw_spminielec_v1"];
    if ([result succeed]) {
        _resultText.text = [NSString stringWithFormat:@"responseBody : %@", result.responseBody];
    } else {
        _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    NSLog(@"queryDeviceDataResult%@",result.responseBody);
}

//获取设备服务器时间
- (void)getServerTime {
    self.resultText.text = @"Query Device Time .....";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BLDeviceTimeResult *result = [[BLLet sharedLet].controller queryDeviceTime:[Tools controlDidForDevice:self.device]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result succeed]) {
                self.resultText.text = [NSString stringWithFormat:@"Time:%@ diff:%ld", result.time, (long)result.difftime];
            } else {
                self.resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
            }
        });
    });
}

//设备复位
- (void)deviceReset {
    BLController *controller = [BLLet sharedLet].controller;
    NSString *result = [controller dnaControl:[Tools controlDidForDevice:self.device] subDevDid:nil dataStr:@"{}" command:@"dev_reset" scriptPath:nil];
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
    BLBaseResult *result = [controller queryDeviceConnectServerInfo:[Tools controlDidForDevice:self.device]];
    NSLog(@"result: %ld", (long)result.status);
    
    _resultText.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
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

- (BOOL)createDeviceLogFile {
    
    //将NSlog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"DeviceLog"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [self.formatter stringFromDate:[NSDate date]];
    self.logfile = [logDirectory stringByAppendingFormat:@"/%@-%@.log", self.device.did, dateStr];
    
    BOOL isSuccess = [fileManager createFileAtPath:self.logfile contents:nil attributes:nil];
    if (isSuccess) {
        NSLog(@"createStressTestLogFile success");
    } else {
        NSLog(@"createStressTestLogFile fail");
    }
    
    return isSuccess;
}

- (void)writeDeviceLogToFileWithString:(NSString *)log {
    
    if ([BLCommonTools isEmpty:log]) {
        return;
    }
    
    NSString *input = [NSString stringWithFormat:@"\n%@\n", log];
    
    NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:self.logfile];
    if (!outFile) {
        return;
    }
    [outFile seekToEndOfFile];
    [outFile writeData:[input dataUsingEncoding:NSUTF8StringEncoding]];
    [outFile closeFile];
    
}

- (void)startDeviceLogRedirect {
}

- (void)stopDeviceLogRedirect {
}

- (void)fastconGroupDevice {
    [self performSegueWithIdentifier:@"FastconGroupDeviceViewController" sender:nil];
}
@end
