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

#import "GCDAsyncUdpSocket.h"

@interface OperateViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *device;

@property (nonatomic, strong) NSArray *operateButtonArray;

@property (nonatomic, strong) NSString *logfile;
@property (nonatomic, strong) NSDateFormatter *formatter;

@property (weak, nonatomic) IBOutlet UITextView *deviceInfoView;
@property (weak, nonatomic) IBOutlet UITableView *operateTableView;

@end

@implementation OperateViewController {
    BOOL isRunning;
    GCDAsyncUdpSocket *udpSocket;
}

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
                                @"Stop Log Redirect"
                                ];
    
    self.operateTableView.delegate = self;
    self.operateTableView.dataSource = self;
    [self setExtraCellLineHidden:self.operateTableView];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [self.formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)viewWillAppear:(BOOL)animated {
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
        case 12:
            [self startDeviceLogRedirect];
        break;
        case 13:
            [self stopDeviceLogRedirect];
            break;
        default:
            break;
    }
}


#pragma mark - private method
- (void)networkState {
    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:self.device.ownerId ? self.device.deviceId : [self.device getDid]];
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
    BLDeviceStatusEnum state = [[BLLet sharedLet].controller queryDeviceState:self.device.ownerId ? self.device.deviceId : self.device.did];
    
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLFirmwareVersionResult *result = [[BLLet sharedLet].controller queryFirmwareVersion:self.device.ownerId ? self.device.deviceId : [self.device getDid]];
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
            BLBaseResult *result = [[BLLet sharedLet].controller upgradeFirmware:self.device.ownerId ? self.device.deviceId : [self.device getDid] url:upgradeFirmwareUrl];
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
    BLBaseBodyResult *result = [[BLLet sharedLet].controller queryDeviceDataWithDid:self.device.ownerId ? self.device.deviceId : [self.device getDid] familyId:@"" startTime:@"2018-03-26_17:00:00" endTime:@"2018-03-27_22:00:00" type:@"fw_spminielec_v1"];
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
        BLDeviceTimeResult *result = [[BLLet sharedLet].controller queryDeviceTime:self.device.ownerId ? self.device.deviceId : self.device.did];
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
    NSString *result = [controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:@"{}" command:@"dev_reset" scriptPath:nil];
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
    BLBaseResult *result = [controller queryDeviceConnectServerInfo:self.device.ownerId ? self.device.deviceId : self.device.did];
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
    [outFile seekToEndOfFile];
    [outFile writeData:[input dataUsingEncoding:NSUTF8StringEncoding]];
    [outFile closeFile];
    
}

- (void)startDeviceLogRedirect {
    
    // START udp echo server
//    int port = 18880;
//
//    NSString *ipaddr = [BLNetworkImp getIPAddress:YES];
//    NSLog(@"IP:%@ Port:%d", ipaddr, port);
//    
//    if (ipaddr && !isRunning) {
//        NSError *error = nil;
//        
//        if (![udpSocket bindToPort:port error:&error])
//        {
//            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Error starting server (bind): %@", error]];
//            return;
//        }
//        if (![udpSocket beginReceiving:&error])
//        {
//            [udpSocket close];
//            
//            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Error starting server (recv): %@", error]];
//            return;
//        }
//        
//        _resultText.text = [NSString stringWithFormat:@"Udp Echo server started on port %hu", [udpSocket localPort]];
//        isRunning = YES;
//        
//        //发送命令给设备
//        NSDictionary *dic = @{
//                              @"enable":@(1),
//                              @"ip":ipaddr,
//                              @"port":@(port)
//                              };
//        NSString *dataStr = [BLCommonTools serializeMessage:dic];
//        
//        NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.did subDevDid:nil dataStr:dataStr command:@"device_log_redirect" scriptPath:nil sendcount:1];
//        
//        NSLog(@"startDeviceLogRedirect result:%@", result);
//    }
}

- (void)stopDeviceLogRedirect {
    // STOP udp echo server
//    if (isRunning) {
//        NSLog(@"Stopped Udp Echo server");
//
//        [udpSocket close];
//        isRunning = false;
//
//        int port = 18880;
//        //发送命令给设备
//        NSDictionary *dic = @{
//                              @"enable":@(0),
//                              @"ip":@"",
//                              @"port":@(port)
//                              };
//        NSString *dataStr = [BLCommonTools serializeMessage:dic];
//
//        NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.did subDevDid:nil dataStr:dataStr command:@"device_log_redirect" scriptPath:nil sendcount:1];
//
//        NSLog(@"stopDeviceLogRedirect result:%@", result);
//    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    if (!isRunning) return;
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        /* If you want to get a display friendly version of the IPv4 or IPv6 address, you could do this:
         
         NSString *host = nil;
         uint16_t port = 0;
         [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
         
         */
        [self writeDeviceLogToFileWithString:msg];
    }
    else
    {
        NSString *errmsg = @"Error converting received data into UTF-8 String";
        [self writeDeviceLogToFileWithString:errmsg];
    }
    
//    [udpSocket sendData:data toAddress:address withTimeout:-1 tag:0];
}


@end
