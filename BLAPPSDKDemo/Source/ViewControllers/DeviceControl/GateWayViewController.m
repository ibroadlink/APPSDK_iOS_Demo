//
//  GateWayViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/31.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "GateWayViewController.h"
#import "DeviceWebControlViewController.h"

#import <BLSFamily/BLSFamily.h>
#import "BLDeviceService.h"
#import "BLStatusBar.h"
#import "SSZipArchive.h"
#import "AppMacro.h"
#import "BLFamilyDefult.h"
#import "Tools.h"

@interface GateWayViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) BLDNADevice *subDevice;

@property (nonatomic, strong) NSMutableDictionary *privateDataCache;

@property (nonatomic, strong) NSMutableArray<BLDNADevice *>* subDevicelist;

@property (nonatomic, assign) BOOL isAdd;

@property (nonatomic, strong) NSString *spid;
@end

@implementation GateWayViewController

+ (GateWayViewController *)viewController {
    return [Tools viewControllerFromMainStoryboard:[self class]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    
    self.subDevicelist = [NSMutableArray arrayWithCapacity:0];
    self.privateDataCache = [NSMutableDictionary dictionaryWithCapacity:0];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSString *familyId = [BLFamilyDefult sharedFamily].currentFamilyInfo.familyid;
    if (familyId.length > 0) {
        [BLConfigParam sharedConfigParam].familyId = familyId;
    }
    
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
        [[BLLet sharedLet].controller addDevice:subDevice];
        [self showIndicatorOnWindowWithMessage:@"Download Script and UI..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *scriptFile = [[BLLet sharedLet].controller queryScriptFileName:subDevice.pid];
            NSString *uiPath = [[BLLet sharedLet].controller queryUIPath:subDevice.pid];
            NSString *uiFile = [uiPath stringByAppendingString:subDevice.pid];
            __block BOOL isDownloadScript = YES;
            __block BOOL isDownloadUI = YES;
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            dispatch_group_t group = dispatch_group_create();
            
            if (![fileManager fileExistsAtPath:scriptFile]) {
                dispatch_group_enter(group);
                //下载子设备脚本
                [[BLLet sharedLet].controller downloadScript:subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {
                    dispatch_group_leave(group);
                    if ([result succeed]) {
                        isDownloadScript = YES;
                        NSLog(@"downloadScript savepath:%@", result.savePath);
                    } else {
                        isDownloadScript = NO;
                        NSLog(@"downloadScript failed: %@", result.msg);
                    }
                }];
            }
            
            if (![fileManager fileExistsAtPath:uiFile]) {
                dispatch_group_enter(group);
                [[BLLet sharedLet].controller downloadUI:subDevice.pid completionHandler:^(BLDownloadResult * _Nonnull result) {
                    
                    if ([result succeed]) {
                        isDownloadUI = YES;
                        NSLog(@"downloadUI savepath:%@", result.savePath);
                        
                        [SSZipArchive unzipFileAtPath:result.savePath toDestination:uiPath];
                    } else {
                        isDownloadUI = NO;
                        NSLog(@"downloadUI failed: %@", result.msg);
                    }
                    
                    dispatch_group_leave(group);
                }];
            }
            dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (isDownloadScript && isDownloadUI) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [[BLDeviceService sharedDeviceService] addNewDeivce:subDevice];
                    if ([Tools copyCordovaJsNamed:DNAKIT_CORVODA_JS_FILE forPid:subDevice.pid]) {
                        [self performSegueWithIdentifier:@"DeviceWebControlView" sender:subDevice];
                    }
                    [self hideIndicatorOnWindow];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [BLStatusBar showTipMessageWithStatus:@"Download script or ui failed!!!"];
                        [self hideIndicatorOnWindow];
                    });
                }
            });
        });
        
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
    [self showIndicatorOnWindowWithMessage:@"Get new sub devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self subDevNewListQuery:0];
    });
}

- (IBAction)querySubDevList:(id)sender {
    [self showIndicatorOnWindowWithMessage:@"Get sub devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self subDevListQuery:0];
    });
}


//开始扫描
- (void)subDevStart {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"set the subDevice pid" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Please the subDevice pid";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.spid = alertController.textFields.firstObject.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BLBaseResult *result = [[BLLet sharedLet].controller subDevScanStartWithDid:[Tools controlDidForDevice:self.device] subPid:self.spid];
            dispatch_async(dispatch_get_main_queue(), ^{
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            });
            
        });
        
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)subDevStop {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLBaseResult *result = [[BLLet sharedLet].controller subDevScanStopWithDid:[Tools controlDidForDevice:self.device]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        });
    });
    
    
}

- (void)subDevNewListQuery:(NSUInteger)index {
    if (index == 0) {
        self.isAdd = YES;
        [self.subDevicelist removeAllObjects];
    }
    
    BLSubDevListResult *result = [[BLLet sharedLet].controller subDevNewListQueryWithDid:[Tools controlDidForDevice:self.device] index:index count:10 subPid:self.spid];
    if ([result succeed]) {
        if (result.list.count > 0) {
            [self.subDevicelist addObjectsFromArray:result.list];
        }
        
        if (self.subDevicelist.count < result.total) {
            [self subDevNewListQuery:++index];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.tableView reloadData];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.tableView reloadData];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        });
    }
    
}

- (void)subDevListQuery:(NSUInteger)index  {
    if (index == 0) {
        self.isAdd = NO;
        [self.subDevicelist removeAllObjects];
    }
    
    BLSubDevListResult *result = [[BLLet sharedLet].controller subDevListQueryWithDid:[Tools controlDidForDevice:self.device] index:index count:10];
    if ([result succeed]) {
        if (result.list.count > 0) {
            [self.subDevicelist addObjectsFromArray:result.list];
        }
        
        if (self.subDevicelist.count < result.total) {
            [self subDevListQuery:++index];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                [self.tableView reloadData];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.tableView reloadData];
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        });
    }

}

- (void)addSubDev:(BLDNADevice *)subDevice {
    BLBaseResult *result = [[BLLet sharedLet].controller subDevAddWithDid:[Tools controlDidForDevice:self.device] subDevInfo:subDevice];
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"AddSubDev:%@ success",subDevice.getDid]];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    
    [self showIndicatorOnWindowWithMessage:@"Get sub devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self subDevListQuery:0];
    });
}

- (void)deleteSubDev:(BLDNADevice *)subDevice {
    BLBaseResult *result = [[BLLet sharedLet].controller subDevDelWithDid:[Tools controlDidForDevice:self.device] subDevDid:subDevice.getDid];
    if ([result succeed]) {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"DeleteSubDev:%@ success",subDevice.getDid]];
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
    
    [self showIndicatorOnWindowWithMessage:@"Get sub devices..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self subDevListQuery:0];
    });
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
