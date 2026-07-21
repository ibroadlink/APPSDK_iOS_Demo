//
//  DNAControlViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/25.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DNAControlViewController.h"
#import "DeviceWebControlViewController.h"

#import "BLDeviceService.h"
#import "DropDownList.h"
#import "SSZipArchive.h"
#import "AppMacro.h"
#import "Tools.h"
#import <BLLetPlugins/BLLetPlugins.h>

@interface DNAControlViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) BLDNADevice *device;

@property (nonatomic, copy)NSString *resultText;
@property (nonatomic, copy)NSArray *keyList;
@property (nonatomic, copy)BLStdData *stdData;

@end

@implementation DNAControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([BLDeviceService sharedDeviceService].gatewayDevice) {
        [BLDeviceService sharedDeviceService].selectDevice = [BLDeviceService sharedDeviceService].gatewayDevice;
        [BLDeviceService sharedDeviceService].gatewayDevice = nil;
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getKeyList];
}

- (void)getKeyList {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:self.device.pid];
    if (![result succeed]) {
        self.keyList = @[];
        return;
    }
    NSString *profileStr = [result getProfile];
    NSDictionary *profileDic = [Tools dictionaryFromJSONString:profileStr];
    NSArray *suids = [profileDic[@"suids"] isKindOfClass:[NSArray class]] ? profileDic[@"suids"] : nil;
    NSDictionary *firstSuid = [suids.firstObject isKindOfClass:[NSDictionary class]] ? suids.firstObject : nil;
    NSDictionary *intfsDic = [firstSuid[@"intfs"] isKindOfClass:[NSDictionary class]] ? firstSuid[@"intfs"] : nil;
    if (!intfsDic) {
        self.keyList = @[];
        return;
    }
    NSMutableArray *keyArray = [NSMutableArray arrayWithCapacity:0];
    [intfsDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableDictionary *keyDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [keyDic setValue:obj forKey:key];
        [keyArray addObject:keyDic];
    }];
    self.keyList = [NSArray arrayWithArray:keyArray];
}

- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 101) {
        NSString *action = @"get";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self dnaControlWithAction:action stdData:self.stdData];
        });
        
    } else if (sender.tag == 102) {
        NSString *action = @"set";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self dnaControlWithAction:action stdData:self.stdData];
        });
    } else if (sender.tag == 103) {
        [self getScriptVersion];
    } else if (sender.tag == 104) {
        [self downloadScript];
    } else if (sender.tag == 105) {
        [self getUIVersion];
    } else if (sender.tag == 106) {
        [self downloadUI];
    } else if (sender.tag == 107) {
        [self getDeviceProfile];
    } else if (sender.tag == 108) {
        [self webViewControl];
    } else if (sender.tag == 110) {
        [self selectParams];
    } else if (sender.tag == 111) {
        [self setParams];
    }
}



- (void)dnaControlWithAction:(NSString *)action stdData:(BLStdData *)stdData {
    BLStdControlResult *result = nil;
    if ([BLCommonTools isEmpty:self.device.pDid]) {
        result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:self.device] stdData:stdData action:action];
    }else {
        BLDNADevice *fDevice = [[BLLet sharedLet].controller getDevice:[NSString stringWithFormat:@"%@++%@", self.device.pDid, self.device.ownerId]];
        result = [[BLLet sharedLet].controller dnaControl:[Tools controlDidForDevice:fDevice] subDevDid:[Tools controlDidForDevice:self.device] stdData:stdData action:action];
    }
    
    if ([result succeed]) {
        self.resultText = [Tools jsonStringFromObject:[[result getData] toDictionary]];
    } else {
        self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

- (void)getDeviceProfile {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:[_device getPid]];
    if ([result succeed]) {
        NSString *profile = [result getProfile];
        NSDictionary *dic = [BLCommonTools deserializeMessageJSON:profile];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        self.resultText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    [self.tableView reloadData];
}

- (void)getScriptVersion {
    BLQueryResourceVersionResult *result = [[BLLet sharedLet].controller queryScriptVersion:[self.device getPid]];
    self.resultText = [result BLS_modelToJSONString];
    
    [self.tableView reloadData];
}

- (void)getUIVersion {
    [[BLPicker sharedPicker] trackEvent:@"123"];
    BLQueryResourceVersionResult *result = [[BLLet sharedLet].controller queryUIVersion:[self.device getPid]];
    self.resultText = [result BLS_modelToJSONString];
    
    [self.tableView reloadData];
}

- (void)downloadScript {
    [self showIndicatorOnWindowWithMessage:@"Script Downloading..."];
    NSLog(@"Start downloadScript");
    NSString *pid = self.device.pid;
    
    [[BLLet sharedLet].controller downloadScript:pid completionHandler:^(BLDownloadResult * _Nonnull result) {
        NSLog(@"End downloadScript");
        if ([result succeed]) {
            [self getKeyList];
            self.resultText = [NSString stringWithFormat:@"ScriptPath:%@", [result getSavePath]];
        } else {
            self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.tableView reloadData];
        });
    }];
}

- (void)downloadUI {
    NSString *unzipPath = [[BLLet sharedLet].controller queryUIPath:[_device getPid]];
    [self showIndicatorOnWindowWithMessage:@"UI Downloading..."];
    NSLog(@"Start downloadUI");
    [[BLLet sharedLet].controller downloadUI:[self.device getPid] completionHandler:^(BLDownloadResult * _Nonnull result) {
        NSLog(@"End downloadUI");
        
        if ([result succeed]) {
            BOOL isUnzip = [SSZipArchive unzipFileAtPath:[result getSavePath] toDestination:unzipPath];
            self.resultText = [NSString stringWithFormat:@"isUnzip:%d \nDownload File:%@ \nUIPath:%@", isUnzip, [result getSavePath], unzipPath];
        } else {
            self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            [self.tableView reloadData];
        });
        NSLog(@"End downloadUI zip");
    }];
}

- (void)webViewControl {
    if ([Tools copyCordovaJsNamed:DNAKIT_CORVODA_JS_FILE forPid:self.device.pid] &&
        [Tools copyCordovaJsNamed:DNAKIT_CORVODA_PLUGIN_JS_FILE forPid:self.device.pid]) {
        DeviceWebControlViewController* vc = [[DeviceWebControlViewController alloc] init];
        vc.selectDevice = _device;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)queryTaskList {
    BLQueryTaskResult *result = [[BLLet sharedLet].controller queryTask:[Tools controlDidForDevice:self.device]];
    if ([result succeed]) {
        NSArray *timeTask = [result getTimer];
        NSArray *delayTask = [result getDelay];
        NSArray *PeriodTask = [result getPeriod];
        NSArray *cycleTask = [result getCycle];
        NSArray *randomTask =[result getRandom];
        self.resultText = [NSString stringWithFormat:@"timeTask:%ld   delayTask:%ld   PeriodTask:%ld    cycleTask:%ld    randomTask:%ld", (unsigned long)timeTask.count,(unsigned long)delayTask.count,(unsigned long)PeriodTask.count,(unsigned long)cycleTask.count, (unsigned long)randomTask.count];
    } else {
        self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    [self.tableView reloadData];
}

- (void)setTask {
    BLTimerOrDelayInfo *timerInfo = [[BLTimerOrDelayInfo alloc] init];
    [timerInfo setIndex:0];
    [timerInfo setEnable:YES];
    [timerInfo setYear:2018];
    [timerInfo setMonth:9];
    [timerInfo setDay:11];
    [timerInfo setHour:16];
    [timerInfo setMinute:56];
    [timerInfo setSeconds:30];
    BLStdData *stdData = [[BLStdData alloc] init];
    NSString *val = @"1";
    NSString *param = @"pwr";
    [stdData setValue:val forParam:param];
    
    BLQueryTaskResult *result = [[BLLet sharedLet].controller updateTask:[Tools controlDidForDevice:self.device] sDid:nil taskType:BL_TIMER_TYPE_LIST isNew:YES timerInfo:timerInfo stdData:stdData];
    if ([result succeed]) {
        NSArray *timeTask = [result getTimer];
        NSArray *delayTask = [result getDelay];
        NSArray *PeriodTask = [result getPeriod];
        NSArray *cycleTask = [result getCycle];
        NSArray *randomTask =[result getRandom];
        self.resultText = [NSString stringWithFormat:@"timeTask:%ld   delayTask:%ld   PeriodTask:%ld    cycleTask:%ld    randomTask:%ld", (unsigned long)timeTask.count,(unsigned long)delayTask.count,(unsigned long)PeriodTask.count,(unsigned long)cycleTask.count, (unsigned long)randomTask.count];
    } else {
        self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    [self.tableView reloadData];
}

- (void)getDeviceTaskData {
    NSString *val = @"";
    NSString *param = @"";
    
    NSInteger index = [val integerValue];
    NSInteger taskType = [param integerValue];
    
    BLTaskDataResult *result = [[BLLet sharedLet].controller queryTaskData:[Tools controlDidForDevice:self.device] sDid:nil taskType:taskType index:index];
    
    if ([result succeed]) {
        self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    } else {
        self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    [self.tableView reloadData];
}

- (void)selectParams {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select Param" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSDictionary *paramDic in self.keyList) {
        NSString *param = paramDic.allKeys[0];
        [alertController addAction:[UIAlertAction actionWithTitle:param style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.stdData setValue:@"" forParam:param];
            [self.tableView reloadData];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setParams {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"set Param" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"param";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *param = alertController.textFields.firstObject.text;
        if ([BLCommonTools isEmpty:param]) {
            self.resultText = [NSString stringWithFormat:@"param can not set nil"];
        }else {
            [self.stdData setValue:@"" forParam:param];
        }
        [self.tableView reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.tableView reloadData];
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.stdData.allParams.count;
    }else if (section == 1) {
        return 1;
    }else if (section == 2) {
        return 1;
    }else {
        return 1;
    }
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* cellIdentifier = nil;
    if (indexPath.section == 0) {
        cellIdentifier = @"PARAMS_CELL";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        UITextField *paramTextView = (UITextField *)[cell viewWithTag:100];
        UITextField *valTextView = (UITextField *)[cell viewWithTag:101];
        NSString *param = self.stdData.allParams[indexPath.row];
        
        paramTextView.text = param;
        valTextView.placeholder = param;
        valTextView.text = nil;
        return cell;
    }else if (indexPath.section == 1) {
        cellIdentifier = @"SELECT_PARAMS_CELL";
    }else if (indexPath.section == 2) {
        cellIdentifier = @"ACTIONS_CELL";
    }else {
        cellIdentifier = @"RESULT_CELL";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        UITextView *resultTextView = (UITextView *)[cell viewWithTag:100];
        resultTextView.text = self.resultText;
        return cell;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == 0) {
            NSMutableArray *params = [NSMutableArray arrayWithArray:self.stdData.allParams];
            NSMutableArray *values = [NSMutableArray arrayWithArray:self.stdData.allValues];
            [params removeObjectAtIndex:indexPath.row];
            [values removeObjectAtIndex:indexPath.row];
            [self.stdData setParams:params values:values];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]  withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
    }else if (indexPath.section == 1) {
        return 80;
    }else if (indexPath.section == 2) {
        return 250;
    }else {
        return 250;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Params and Values";
    }else if (section == 1) {
        return nil;
    }else if (section == 2) {
        return @"Action";
    }else {
        return @"Result";
    }
}



#pragma mark - property
- (BLStdData *)stdData {
    if (!_stdData) {
        _stdData = [[BLStdData alloc] init];
    }
    return _stdData;
}




@end
