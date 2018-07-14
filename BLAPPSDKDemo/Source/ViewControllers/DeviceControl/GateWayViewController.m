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

@interface GateWayViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) BLController *blController;

@property (nonatomic, strong) BLDNADevice *subDevice;

@property (nonatomic, strong) NSMutableDictionary *privateDataCache;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray<BLDNADevice *>* subDevicelist;
@end

@implementation GateWayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blController = [BLLet sharedLet].controller;
    _blController.currentFamilyId = @"00bc30ade0f4a2da1abbb47bc0cc17b2";
    _subDevicelist = [NSArray array];
    self.privateDataCache = [NSMutableDictionary dictionaryWithCapacity:0];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view = self.tableView;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(AddSubDevice)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    [self QuerySubDevList];
    [self write];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _subDevicelist.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"SUB_DEVICE_LIST_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    BLDNADevice *subDevice = _subDevicelist[indexPath.row];
    cell.textLabel.text = subDevice.did;
    cell.detailTextLabel.text = subDevice.pid;
    return cell;
}

//点击控制
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BLDNADevice *subDevice = _subDevicelist[indexPath.row];
    [self OtherButton:subDevice];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BLDNADevice *subDevice = _subDevicelist[indexPath.row];
        [self DeleteSubDev:subDevice];
    }
}

- (void)AddSubDevice {
    [self subDevStart];
}

//开始扫描
- (void)subDevStart {
    BLBaseResult *result = [self.blController subDevScanStartWithDid:[self.device getDid] subPid:@"000000000000000000000000d0010100"];
    if ([result succeed]) {
        //获取新的子设备列表
        [self GetNewSubDevList];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    
}

- (void)GetNewSubDevList {
    BLSubDevListResult *result = [_blController subDevNewListQueryWithDid:[_device getDid] index:0 count:0 subPid:@"000000000000000000000000d0010100"];
    if ([result succeed]) {
        if (result.list && ![result.list isKindOfClass:[NSNull class]] && result.list.count > 0) {
            _subDevice = result.list[0];
            //添加子设备
            [self AddSubDev:_subDevice];
            NSLog(@"SubDevList:——————————————————-——%@",result.list);
        }
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
}

- (void)AddSubDev:(BLDNADevice *)subDevice {
    BLBaseResult *result = [_blController subDevAddWithDid:[_device getDid] subDevInfo:subDevice];
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"AddSubDev:%@ success",subDevice.getDid]];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    [self QuerySubDevList];
}

- (void)DeleteSubDev:(BLDNADevice *)subDevice {
    BLBaseResult *result = [_blController subDevDelWithDid:[_device getDid] subDevDid:subDevice.getDid];
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"DeleteSubDev:%@ success",subDevice.getDid]];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    [self QuerySubDevList];
}

- (void)QuerySubDevList {
    _subDevicelist = nil;
    BLSubDevListResult *result = [_blController subDevListQueryWithDid:[_device getDid] index:0 count:10];
    [_blController addDevice:_subDevice];
    if ([result succeed]) {
        NSLog(@"result:%@",result);
        if (result.list && ![result.list isKindOfClass:[NSNull class]] && result.list.count > 0) {
            NSLog(@"result.list:+++++++++=%@",result.list);
            
            _subDevicelist = result.list;
            for (_subDevice in _subDevicelist) {
                [_blController addDevice:_subDevice];
                //下载子设备脚本
                [_blController downloadScript:_subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {NSLog(@"resultsavePath:%@",result.savePath);}];
                NSLog(@"SubDevList:%@",[_subDevice getDid]);
                BLProfileStringResult *ProfileResult = [_blController queryProfile:[_subDevice getDid]];
                NSLog(@"ProfileResult:%@",ProfileResult.profile);
            }
            
        }
        
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    [self.tableView reloadData];

}

//{"prop":"stdctrl","srv":"1.10.1","did":"01A703A5D85021ED3AA6B056DF16E2FF","params":["switch_pair_status"],"vals":[[{"val":1,"idx":0}]],"act":"get","password":"ab0d4322"}
//{"vals":[[{"val":1,"idx":1}]],"did":"00000000000000000000b4430d96b549","password":"ab0d4322","act":"set","prop":"stdctrl","params":["switch_pair"]}
- (void)SwitchPairStatus:(BLDNADevice *)subDevice {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@1 forParam:@"rmpanel_pairstatus"];
    BLStdControlResult *result = [_blController dnaControl:[_device getDid] subDevDid:[subDevice getDid] stdData:stdData action:@"set"];
    NSDictionary *subdic = [[result getData] toDictionary];
    NSLog(@"subDic:%@",subdic);
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}

- (void)SwitchPair:(BLDNADevice *)subDevice {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@1 forParam:@"rmpanel_pair"];
    BLStdControlResult *result = [_blController dnaControl:[_device getDid] subDevDid:[subDevice getDid] stdData:stdData action:@"set"];
    NSDictionary *subdic = [[result getData] toDictionary];
    NSLog(@"subDic:%@",subdic);
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}

- (void)TCController:(BLDNADevice *)subDevice {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@1 forParam:@"pwr"];
    BLStdControlResult *result = [_blController dnaControl:[_device getDid] subDevDid:[subDevice getDid] stdData:stdData action:@"set"];
    NSDictionary *subdic = [[result getData] toDictionary];
    NSLog(@"subDic:%@",subdic);
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}


- (void)OtherButton:(BLDNADevice *)subDevice {
    //控制
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@0 forParam:@"rmpanel_fanoperation"];
    BLStdControlResult *result = [_blController dnaControl:[_device getDid] subDevDid:[subDevice getDid] stdData:stdData action:@"set"];
    NSDictionary *subdic = [[result getData] toDictionary];
    NSLog(@"subDic:%@",subdic);
    [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
}

- (void)write{
    
    __weak typeof(self) weakSelf = self;
    [_blController setSDKRawWithReadBlock:^unsigned char * _Nullable(int sync, unsigned char * _Nullable key) {
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
@end
