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
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getKeyList];
}

- (void)getKeyList {
    BLProfileStringResult *result = [[BLLet sharedLet].controller queryProfileByPid:self.device.pid];
    NSString *profileStr = [result getProfile];
    NSData *data = [profileStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *profileDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *intfsDic = [[[profileDic valueForKey:@"suids"] objectAtIndex:0] valueForKey:@"intfs"];
    NSMutableArray *keyArray = [NSMutableArray arrayWithCapacity:0];
    [intfsDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableDictionary *keyDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [keyDic setValue:obj forKey:key];
        [keyArray addObject:keyDic];
    }];
    self.keyList = [NSArray arrayWithArray:keyArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:action];
    }else {
        BLDNADevice *fDevice = [[BLLet sharedLet].controller getDevice:[NSString stringWithFormat:@"%@++%@", self.device.pDid, self.device.ownerId]];
        result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? fDevice.deviceId : self.device.pDid subDevDid:self.device.ownerId ? self.device.deviceId :[_device getDid] stdData:stdData action:action];
    }
    
    if ([result succeed]) {
        NSDictionary *dic = [[result getData] toDictionary];
        NSString *result = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
        self.resultText = result;
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
    if ([self copyCordovaJsToUIPathWithFileName:DNAKIT_CORVODA_JS_FILE] && [self copyCordovaJsToUIPathWithFileName:DNAKIT_CORVODA_PLUGIN_JS_FILE]) {
        DeviceWebControlViewController* vc = [[DeviceWebControlViewController alloc] init];
        vc.selectDevice = _device;
        [self.navigationController pushViewController:vc animated:YES];
    }
}



- (void)bindDeviceToServer {
    BLBindDeviceResult *result = [[BLLet sharedLet].controller bindDeviceWithServer:_device];
    if ([result succeed]) {
        self.resultText = [NSString stringWithFormat:@"BindMap : %@", [result getBindmap]];
    } else {
        self.resultText = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    [self.tableView reloadData];
}

- (void)queryTaskList {
    BLQueryTaskResult *result = [[BLLet sharedLet].controller queryTask:[_device getDid]];
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
    //    [timerInfo setCmd1duration:1800];
    //    [timerInfo setEndhour:12];
    //    [timerInfo setEndminute:10];
    //    [timerInfo setEndseconds:00];
    //    [timerInfo setCmd2duration:1800];
    //    [timerInfo setRepeat:@[@1,@2,@3,@4,@5,@6,@7]];
    
    
    BLStdData *stdData = [[BLStdData alloc] init];
    NSString *val = @"1";
    NSString *param = @"pwr";
    [stdData setValue:val forParam:param];
    
    //    BLStdData *stdData2 = [[BLStdData alloc] init];
    //    NSString *val2 = @"0";
    //    NSString *param2 = @"pwr";
    //    [stdData2 setValue:val2 forParam:param2];
    
    BLQueryTaskResult *result = [[BLLet sharedLet].controller updateTask:[_device getDid] sDid:nil taskType:BL_TIMER_TYPE_LIST isNew:YES timerInfo:timerInfo stdData:stdData];
    //    BLQueryTaskResult *result = [_blController updateTask:[_device getDid] sDid:nil taskType:BL_CYCLE_TYPE_LIST isNew:YES cycleInfo:timerInfo stdData1:stdData stdData2:stdData2];
    //    BLQueryTaskResult *result = [_blController delTask:[_device getDid] sDid:nil taskType:BL_CYCLE_TYPE_LIST index:0];
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
    //    BLQueryTaskResult *result = [_blController delTask:[_device getDid] sDid:nil taskType:BL_CYCLE_TYPE_LIST index:0];
    NSString *val = @"";
    NSString *param = @"";
    
    NSInteger index = [val integerValue];
    NSInteger taskType = [param integerValue];
    
    BLTaskDataResult *result = [[BLLet sharedLet].controller queryTaskData:_device.did sDid:nil taskType:taskType index:index];
    
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
            
//            NSDictionary *valueDic = [paramDic objectForKey:param][0];
//            NSMutableArray *parameterList = [NSMutableArray arrayWithArray:valueDic[@"in"]];
//
//            //动作类型act
//            NSInteger act = [valueDic[@"act"] integerValue];
//            NSString *actFunction = nil;
//            if (act == 1) {
//                actFunction = @"only suppot get";
//            }else if (act == 2) {
//                actFunction = @"only suppot set";
//            }else {
//                actFunction = @"suppot get and set";
//            }
//
//            //第一个元素表示参数格式,1 表示枚举型,2 表示连续型,3 表示简单类型
//            NSInteger parameterformat = [parameterList.firstObject integerValue];
//            NSString *parameterType = nil;
//
//            [parameterList removeObjectAtIndex:0];
//            if (parameterformat == 1) {
//                parameterType = [NSString stringWithFormat:@"Enumerate type : %@",[BLCommonTools serializeMessage:parameterList]];
//            }else if (parameterformat == 2) {
//                parameterType = [NSString stringWithFormat:@"Continuous type : [min:%@,max:%@,step:%@,multiple:%@] ", parameterList[0],parameterList[1],parameterList[2],parameterList[3]];
//            }else {
//                parameterType = @"Other type : String";
//            }
//
//            self.resultText = [NSString stringWithFormat:@"%@",@[param,actFunction,parameterType]];
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
//    NSString *param = textField.placeholder;
//    NSMutableArray *parameterList = [NSMutableArray arrayWithCapacity:0];
//    for (NSDictionary *paramDic in self.keyList) {
//        if ([paramDic.allKeys[0] isEqualToString:param]) {
//            NSDictionary *valueDic = [paramDic objectForKey:param][0];
//            parameterList = [NSMutableArray arrayWithArray:valueDic[@"in"]];
//        }
//    }
//    NSInteger parameterformat = [parameterList.firstObject integerValue];
//    [parameterList removeObjectAtIndex:0];
//    if (parameterformat == 1) {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select one value" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        for (NSString *value in parameterList) {
//            [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",value] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                textField.text = [NSString stringWithFormat:@"%@",value];
//                [self.tableView reloadData];
//            }]];
//        }
//        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
//        [self presentViewController:alertController animated:YES completion:nil];
//        return NO;
//    }else if (parameterformat == 2) {
//
//        return YES;
//    }else {
//
//        return YES;
//    }
    
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
        NSString *value = valTextView.text;
        if ([self isNumber:value]) {
            [self.stdData setValue:@([value integerValue]) forParam:param];
        }else {
            [self.stdData setValue:value forParam:param];
        }
        
        paramTextView.text = param;
        valTextView.placeholder = param;
        [valTextView setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
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
