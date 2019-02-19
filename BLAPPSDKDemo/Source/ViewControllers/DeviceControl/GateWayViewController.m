//
//  GateWayViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/31.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "GateWayViewController.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"
#import "DeviceWebControlViewController.h"
#import "SSZipArchive.h"
@interface GateWayViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *subDevice;

@property (nonatomic, strong) NSMutableDictionary *privateDataCache;

@property (nonatomic, copy) NSArray<BLDNADevice *>* subDevicelist;

@property (nonatomic, assign) BOOL isAdd;
@end

@implementation GateWayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [BLLet sharedLet].controller.currentFamilyId = @"00bc30ade0f4a2da1abbb47bc0cc17b2";
    self.subDevicelist = [NSArray array];
    self.privateDataCache = [NSMutableDictionary dictionaryWithCapacity:0];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self write];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subDevicelist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"SUB_DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
    cell.textLabel.text = subDevice.did;
    cell.detailTextLabel.text = subDevice.pid;
    return cell;
}

//点击控制
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
    if (self.isAdd) {
        [self addSubDev:subDevice];
    } else {
        NSString *unzipPath = [[BLLet sharedLet].controller queryUIPath:[subDevice getPid]];
        
        [[BLLet sharedLet].controller addDevice:subDevice];
        //下载子设备脚本
        [[BLLet sharedLet].controller downloadScript:subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {NSLog(@"resultsavePath:%@",result.savePath);}];
        [[BLLet sharedLet].controller downloadUI:subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SSZipArchive unzipFileAtPath:[result getSavePath] toDestination:unzipPath];
                if ([self copyCordovaJsToUIPathWithFileName:DNAKIT_CORVODA_JS_FILE] ) {
                    self.device.pDid = subDevice.did;
                    self.device.pid = subDevice.pid;
                    [self performSegueWithIdentifier:@"DeviceWebControlView" sender:self.device];
                }
            });
            
        }];
    }
    
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLDNADevice *subDevice = self.subDevicelist[indexPath.row];
        [self deleteSubDev:subDevice];
    }
}

- (IBAction)subDevStart:(id)sender {
    [self subDevStart];
}

- (IBAction)subDevStop:(id)sender {
    [self subDevStop];
}

- (IBAction)getNewSubDevList:(id)sender {
    [self getNewSubDevList];
}

- (IBAction)querySubDevList:(id)sender {
    [self querySubDevList];
}



//开始扫描
- (void)subDevStart {
    BLBaseResult *result = [[BLLet sharedLet].controller subDevScanStartWithDid:[self.device getDid] subPid:nil];
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    
}

- (void)subDevStop {
    BLBaseResult *result = [[BLLet sharedLet].controller subDevScanStopWithDid:[self.device getDid]];
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}

- (void)getNewSubDevList {
    self.isAdd = YES;
    BLSubDevListResult *result = [[BLLet sharedLet].controller subDevNewListQueryWithDid:[_device getDid] index:0 count:0 subPid:@"000000000000000000000000d0010100"];
    if ([result succeed]) {
        self.subDevicelist = result.list;
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"list(%lu)", (unsigned long)result.list.count]];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    [self.tableView reloadData];
}



- (void)querySubDevList {
    self.subDevicelist = nil;
    self.isAdd = NO;
    BLSubDevListResult *result = [[BLLet sharedLet].controller subDevListQueryWithDid:[_device getDid] index:0 count:10];
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"list(%lu)", (unsigned long)result.list.count]];
        NSLog(@"result:%@",result);
        if (result.list && ![result.list isKindOfClass:[NSNull class]] && result.list.count > 0) {
            NSLog(@"result.list:+++++++++=%@",result.list);
            
            self.subDevicelist = result.list;
            for (_subDevice in self.subDevicelist) {
                [[BLLet sharedLet].controller addDevice:_subDevice];
                //下载子设备脚本
                [[BLLet sharedLet].controller downloadScript:_subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {NSLog(@"resultsavePath:%@",result.savePath);}];
                NSLog(@"SubDevList:%@",[_subDevice getDid]);
                BLProfileStringResult *ProfileResult = [[BLLet sharedLet].controller queryProfile:[_subDevice getDid]];
                NSLog(@"ProfileResult:%@",ProfileResult.profile);
            }
        }
        
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    [self.tableView reloadData];

}

- (void)addSubDev:(BLDNADevice *)subDevice {
    BLBaseResult *result = [[BLLet sharedLet].controller subDevAddWithDid:[_device getDid] subDevInfo:subDevice];
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"AddSubDev:%@ success",subDevice.getDid]];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    [self querySubDevList];
}

- (void)deleteSubDev:(BLDNADevice *)subDevice {
    BLBaseResult *result = [[BLLet sharedLet].controller subDevDelWithDid:[_device getDid] subDevDid:subDevice.getDid];
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"DeleteSubDev:%@ success",subDevice.getDid]];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    [self querySubDevList];
}

//{"prop":"stdctrl","srv":"1.10.1","did":"01A703A5D85021ED3AA6B056DF16E2FF","params":["switch_pair_status"],"vals":[[{"val":1,"idx":0}]],"act":"get","password":"ab0d4322"}
//{"vals":[[{"val":1,"idx":1}]],"did":"00000000000000000000b4430d96b549","password":"ab0d4322","act":"set","prop":"stdctrl","params":["switch_pair"]}
- (void)switchPairStatus:(BLDNADevice *)subDevice {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@1 forParam:@"rmpanel_pairstatus"];
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[_device getDid] subDevDid:[subDevice getDid] stdData:stdData action:@"set"];
    NSDictionary *subdic = [[result getData] toDictionary];
    NSLog(@"subDic:%@",subdic);
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}

- (void)switchPair:(BLDNADevice *)subDevice {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@1 forParam:@"rmpanel_pair"];
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[_device getDid] subDevDid:[subDevice getDid] stdData:stdData action:@"set"];
    NSDictionary *subdic = [[result getData] toDictionary];
    NSLog(@"subDic:%@",subdic);
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}

- (void)tCController:(BLDNADevice *)subDevice {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@1 forParam:@"pwr"];
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[_device getDid] subDevDid:[subDevice getDid] stdData:stdData action:@"set"];
    NSDictionary *subdic = [[result getData] toDictionary];
    NSLog(@"subDic:%@",subdic);
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}


- (void)otherButton:(BLDNADevice *)subDevice {
    //控制
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@0 forParam:@"rmpanel_fanoperation"];
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[_device getDid] subDevDid:[subDevice getDid] stdData:stdData action:@"set"];
    NSDictionary *subdic = [[result getData] toDictionary];
    NSLog(@"subDic:%@",subdic);
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}

- (void)write{
    
    __weak typeof(self) weakSelf = self;
    [[BLLet sharedLet].controller setSDKRawWithReadBlock:^unsigned char * _Nullable(int sync, unsigned char * _Nullable key) {
        NSLog(@"%d,%s",sync,key);
        NSString *pKey = [NSString stringWithUTF8String:(const char *)key];
        NSString *pData = [weakSelf.privateDataCache objectForKey:pKey];
        if (pData) {
            return (unsigned char *)pData.UTF8String;
        }
        
        return NULL;
    } writeBlock:^unsigned char * _Nullable(int sync, unsigned char * _Nullable key, unsigned char * _Nullable data) {
        NSLog(@"%d,%s,%s",sync,key,data);
        
        NSString *pKey = [NSString stringWithUTF8String:(const char *)key];
        NSString *pData =  [NSString stringWithUTF8String:(const char *)data];
        [weakSelf.privateDataCache setObject:pData forKey:pKey];
        
        return NULL;
    }];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"DeviceWebControlView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[DeviceWebControlViewController class]]) {
            DeviceWebControlViewController* vc = (DeviceWebControlViewController *)target;
            BLDNADevice *subDevice = (BLDNADevice *)sender;
            vc.selectDevice = subDevice;
        }
    }
}

@end
