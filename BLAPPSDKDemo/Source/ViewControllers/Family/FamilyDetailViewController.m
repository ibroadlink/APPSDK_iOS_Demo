//
//  FamilyDetailViewController.m
//  BLAPPSDKDemo
//
//  Created by zjjllj on 2017/2/17.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "FamilyDetailViewController.h"
#import "BLStatusBar.h"
#import "AppDelegate.h"
#import "DeviceDB.h"
#import "OperateViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ControlViewController.h"

@interface FamilyDetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *familyIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *familyAddressLabel;

@property (weak, nonatomic) IBOutlet UITableView *moduleTable;

@property (nonatomic, strong) BLFamilyAllInfo *familyAllInfo;
@property (nonatomic, weak)NSTimer *stateTimer;

@property (nonatomic, strong, readwrite) NSArray<NSArray<BLModuleInfo *> *> *deviceGroupArray;
@end

@implementation FamilyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.moduleTable.delegate = self;
    self.moduleTable.dataSource = self;
    
    UIBarButtonItem *rButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addModule)];
    [self.navigationItem setRightBarButtonItem:rButton];
    
    [self setExtraCellLineHidden:self.moduleTable];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self queryFamilyAllInfoWithId:self.familyId];
    if (![_stateTimer isValid]) {
        __weak typeof(self) weakSelf = self;
        _stateTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf.moduleTable reloadData];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([_stateTimer isValid]) {
        [_stateTimer invalidate];
        _stateTimer = nil;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (void)queryFamilyAllInfoWithId:(NSString *)queryId {
    NSArray *idlist = @[queryId];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BLFamilyController *manager = delegate.familyController;

    [self showIndicatorOnWindow];
    [manager queryFamilyInfoWithIds:idlist completionHandler:^(BLAllFamilyInfoResult * _Nonnull result) {
        
        if ([result succeed]) {
            self.familyAllInfo = result.allFamilyInfoArray.firstObject;
            //将模块按照房间id分组
            self.deviceGroupArray = [self getDeviceArrayGroupByRoom];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideIndicatorOnWindow];
                self.familyIdLabel.text = [NSString stringWithFormat:@"FamilyID: %@", self.familyId];
                self.familyNameLabel.text = [NSString stringWithFormat:@"FamilyName: %@", self.familyAllInfo.familyBaseInfo.familyName];
                self.familyAddressLabel.text = [NSString stringWithFormat:@"FamilyAddress: %@ %@ %@ %@",
                                                self.familyAllInfo.familyBaseInfo.familyCountry, self.familyAllInfo.familyBaseInfo.familyProvince,
                                                self.familyAllInfo.familyBaseInfo.familyCity, self.familyAllInfo.familyBaseInfo.familyArea];
                self.familyVersionLabel.text = [NSString stringWithFormat:@"FamilyVersion: %@", self.familyAllInfo.familyBaseInfo.familyVersion];
                [self.moduleTable reloadData];
            });
            
            
            NSArray *deviceBaseInfoList = self.familyAllInfo.deviceBaseInfo;
            [self addFamilyDevice:deviceBaseInfoList];
            
            
        } else {
            NSLog(@"error:%ld msg:%@", (long)result.error, result.msg);
            [BLStatusBar showTipMessageWithStatus:[@"Query FamilyAllInfo With Id Failed! " stringByAppendingString:result.msg]];
        }
    }];
}

//把家庭设备add到SDK管理
- (void)addFamilyDevice:(NSArray*)deviceInfoList {
    for (BLFamilyDeviceInfo *familyDevice in deviceInfoList) {
        BLDNADevice *device = [BLDNADevice new];
        [device setDid:familyDevice.did];
        [device setName:familyDevice.name];
        [device setMac:familyDevice.mac];
        [device setPid:familyDevice.pid];
        [device setControlKey:familyDevice.aesKey];
        [device setControlId:familyDevice.terminalId];
        [device setType:familyDevice.type];
        [[BLLet sharedLet].controller addDevice:device];
    }
}


- (void)addModule {
    
    NSArray *myDeviceList = [[DeviceDB sharedOperateDB] readAllDevicesFromSql];

    if (myDeviceList.count != 0) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"添加设备到家庭"
                                                                       message:@"需要先在设备管理里添加设备"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        for (BLDNADevice *device in myDeviceList) {
            if (device) {
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@%@",device.name,device.mac] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    [self addModuleToRoom:device];
                }];
                [alert addAction:defaultAction];
            }
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else {
        [BLStatusBar showTipMessageWithStatus:@"先添加设备"];
    }
}

- (void)addModuleToRoom:(BLDNADevice *)device {
    NSArray<BLRoomInfo *> *roomInfos = self.familyAllInfo.roomBaseInfoArray;

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"添加设备到房间"
                                                                   message:@"需要先在设备管理里添加设备"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (BLRoomInfo *roomInfo in roomInfos) {
        if (roomInfo) {
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",roomInfo.name] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self addModuleDevice:device RoomId:roomInfo.roomId];
            }];
            [alert addAction:defaultAction];
        }
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addModuleDevice:(BLDNADevice *)device RoomId:(NSString *)roomId {
    BLModuleInfo *module = [[BLModuleInfo alloc] init];
    module.familyId = self.familyId;
    module.roomId = roomId;
    module.name = device.name;
    module.order = 1;
    module.flag = 0;
    module.moduleType = BLSDKModuleType_Common;
    module.iconPath = @"http://www.broadlink.com.cn/images/homeFullpage/broadlink.png";
    
    module.followDev = 1;
    
    BLModuleIncludeDev *moduleDev = [BLModuleIncludeDev new];
    moduleDev.did = device.did;
    moduleDev.order = 1;
    moduleDev.content = @"";
    
    NSArray *moduleDevs = @[moduleDev];
    module.moduleDevs = moduleDevs;
    
    BLFamilyDeviceInfo *familyDeviceInfo = [BLFamilyDeviceInfo new];
    familyDeviceInfo.familyId = self.familyId;
    familyDeviceInfo.roomId = roomId;
    familyDeviceInfo.pid = device.pid;
    familyDeviceInfo.did = device.did;
    familyDeviceInfo.name = device.name;
    familyDeviceInfo.mac = device.mac;
    familyDeviceInfo.terminalId = device.controlId;
    familyDeviceInfo.aesKey = device.getControlKey;
    familyDeviceInfo.password = device.password;
    familyDeviceInfo.type = device.type;
    
    [[BLFamilyController sharedManager] addModule:module toFamily:self.familyAllInfo.familyBaseInfo withDevice:familyDeviceInfo subDevice:nil completionHandler:^(BLModuleControlResult * _Nonnull result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result succeed]) {
                NSLog(@"success:%ld Msg:%@", (long)result.error, result.msg);
                [BLStatusBar showTipMessageWithStatus:@"Add Module Success"];
                
                [self queryFamilyAllInfoWithId:self.familyId];
            } else {
                NSLog(@"error:%ld Msg:%@", (long)result.error, result.msg);
                [BLStatusBar showTipMessageWithStatus:[@"Add Module Failed! " stringByAppendingString:result.msg]];
            }
        });
    }];
}

- (NSArray *)getDeviceArrayGroupByRoom {
    NSMutableArray *deviceGroupArray = [NSMutableArray array];
    //将模块按照房间分组
    NSMutableSet *set = [NSMutableSet set];
    [self.familyAllInfo.moduleBaseInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj roomId]) {
            [set addObject:[obj roomId]];
        }
    }];
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {//遍历set数组
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomId=%@", obj];//创建谓词筛选器
        NSArray *group = [self.familyAllInfo.moduleBaseInfo filteredArrayUsingPredicate:predicate];//用数组的过滤方法得到新的数组
        [deviceGroupArray addObject:group];
    }];
    return deviceGroupArray;
}

#pragma mark - 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.deviceGroupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceGroupArray[section].count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"MODULE_TABLE_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    BLModuleInfo *blmoduleInfo = self.deviceGroupArray[indexPath.section][indexPath.row];
    NSString *moduleName = blmoduleInfo.name;
    NSString *moduleId = blmoduleInfo.moduleId;
    NSString *roomId = blmoduleInfo.roomId;
    
    
    BLModuleIncludeDev *moduleDevice = blmoduleInfo.moduleDevs[0];
    BLDNADevice *device = [[BLLet sharedLet].controller getDevice:moduleDevice.did];
    
    NSString *roomName;
    for (BLRoomInfo *roomInfo in self.familyAllInfo.roomBaseInfoArray) {
        if ([roomId isEqualToString:roomInfo.roomId]) {
            roomName = roomInfo.name;
            break;
        }
    }
    
    UILabel *moduleNameLabel = (UILabel *)[cell viewWithTag:300];
    moduleNameLabel.text = moduleName;
    
    UILabel *moduleIdLabel = (UILabel *)[cell viewWithTag:301];
    moduleIdLabel.text = [NSString stringWithFormat:@"%@",[self getstate:device.state]];
    
    UILabel *roomNameLabel = (UILabel *)[cell viewWithTag:302];
    roomNameLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)device.type];
    
    UIImageView *headImageView = (UIImageView *)[cell viewWithTag:304];
    [headImageView sd_setImageWithURL:[NSURL URLWithString:blmoduleInfo.iconPath]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 73;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 40;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = [UIColor colorWithRed:246 green:244 blue:241 alpha:0];
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:14];
    label.frame = CGRectMake(15, 13, 100, 20);
    [headerView addSubview:label];
    
    for (BLRoomInfo *roomInfo in self.familyAllInfo.roomBaseInfoArray) {
        NSString *roomId = self.deviceGroupArray[section][0].roomId;
        if ([roomId isEqualToString:roomInfo.roomId]) {
            label.text = roomInfo.name;
        }
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        BLFamilyController *familyController = delegate.familyController;
        BLModuleInfo *blmoduleInfo = self.deviceGroupArray[indexPath.section][indexPath.row];

        [familyController delModuleWithId:blmoduleInfo.moduleId fromFamilyId:self.familyId familyVersion:self.familyAllInfo.familyBaseInfo.familyVersion completionHandler:^(BLModuleControlResult * _Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([result succeed]) {
                    NSLog(@"Del module success:%ld Msg:%@", (long)result.error, result.msg);
                    [BLStatusBar showTipMessageWithStatus:@"Del Module Success"];
                    [self queryFamilyAllInfoWithId:self.familyId];
                } else {
                    NSLog(@"Del module error:%ld Msg:%@", (long)result.error, result.msg);
                    [BLStatusBar showTipMessageWithStatus:[@"Del Module Failed! " stringByAppendingString:result.msg]];
                }
            });
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BLModuleInfo *blmoduleInfo = self.deviceGroupArray[indexPath.section][indexPath.row];
    BLModuleIncludeDev *moduleDevice = blmoduleInfo.moduleDevs[0];
    BLDNADevice *device = [delegate.let.controller getDevice:moduleDevice.did];
    
    if (blmoduleInfo.moduleType == BLSDKModuleType_RM_AC) {
        NSString *extend = blmoduleInfo.extend;
        NSData *jsonData = [extend dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        NSString *codeUrl = dic[@"codeUrl"];
        NSString *savePath = [delegate.let.controller.queryIRCodeScriptPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gz",blmoduleInfo.moduleId]];
        [[BLLet sharedLet].ircode downloadIRCodeScriptWithUrl:codeUrl savePath:savePath randkey:nil completionHandler:^(BLDownloadResult * _Nonnull result) {
            if ([result succeed]) {
                
            }
        }];
//        [self performSegueWithIdentifier:@"controllerView" sender:savePath];
    } else {
        [self performSegueWithIdentifier:@"OperateView" sender:device];
    }
    
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"OperateView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[OperateViewController class]]) {
            OperateViewController* opVC = (OperateViewController *)target;
            opVC.device = (BLDNADevice *)sender;
        }
    }else if ([segue.identifier isEqualToString:@"controllerView"]) {
        UIViewController *target = segue.destinationViewController;
        if ([target isKindOfClass:[ControlViewController class]]) {
            ControlViewController* opVC = (ControlViewController *)target;
            opVC.savePath = (NSString *)sender;
        }
    }
}


- (NSString *)getstate:(BLDeviceStatusEnum)state{
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
    return stateString;
}
@end
