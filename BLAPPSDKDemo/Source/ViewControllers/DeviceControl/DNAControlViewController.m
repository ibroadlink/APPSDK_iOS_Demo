//
//  DNAControlViewController.m
//  BLAPPSDKDemo
//
//  Created by junjie.zhu on 2016/10/25.
//  Copyright © 2016年 BroadLink. All rights reserved.
//

#import "DNAControlViewController.h"
#import "AppDelegate.h"
#import "DropDownList.h"

@interface DNAControlViewController ()<UITextFieldDelegate>
@property (nonatomic, weak)NSTimer *stateTimer;
@end

@implementation DNAControlViewController {
    BLController *_blController;
    NSArray *_keyList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _blController = delegate.let.controller;
    
    _valInputTextField.delegate = self;
    _paramInputTextField.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_stateTimer invalidate];
    _stateTimer = nil;
}
    

- (IBAction)paramSelectedList:(id)sender {
    CGFloat drop_X = self.paramInputTextField.frame.origin.x;
    CGFloat drop_Y = CGRectGetMaxY(self.paramInputTextField.frame);
    CGFloat drop_W = self.paramInputTextField.frame.size.width;
    CGFloat drop_H = _keyList.count * 40 + 10;
    
    DropDownList *dropList = [[DropDownList alloc] initWithFrame:CGRectMake(drop_X, drop_Y, drop_W, drop_H) dataArray:_keyList onTheView:self.view] ;
    
    dropList.myBlock = ^(NSInteger row,NSString *title)
    {
        self.paramInputTextField.text = title;
    };
    
    [self.view addSubview:dropList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BLProfileStringResult *result = [_blController queryProfile:self.device.did];
    NSString *profileStr = [result getProfile];
    NSData *data = [profileStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *profileDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *intfsDic = [[[profileDic valueForKey:@"suids"] objectAtIndex:0] valueForKey:@"intfs"];
    NSMutableArray *keyArray = [NSMutableArray array];
    [intfsDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [keyArray addObject:key];
    }];
    _keyList = [NSArray arrayWithArray:keyArray];
    NSLog(@"keyList:%@",_keyList);
    
    
//    if (![_stateTimer isValid]) {
//        __weak typeof(self) weakSelf = self;
//        _stateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSInteger i = [weakSelf.valInputTextField.text integerValue];
//            if (i == 0) {
//                weakSelf.valInputTextField.text = @"1";
//            }else{
//                weakSelf.valInputTextField.text = @"0";
//            }
//            [weakSelf testDnaControl];
//        }];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 101) {
        NSString *param = _paramInputTextField.text;
        NSString *action = @"get";
        
        [self dnaControlWithAction:action param:param val:nil];
    } else if (sender.tag == 102) {
        NSString *val = _valInputTextField.text;
        NSString *param = _paramInputTextField.text;
        NSString *action = @"set";
        
        [self dnaControlWithAction:action param:param val:val];
    } else if (sender.tag == 103) {
        [self queryTaskList];
    } else if (sender.tag == 104) {
        [self setTask];
    } else if (sender.tag == 105) {
        [self getDeviceProfile];
    } else if (sender.tag == 106) {
        [self getDeviceTaskData];
    }
}

- (void)testDnaControl {
    //dev_ctrl
    NSDictionary *dataDic = @{
                              @"vals": @[
                                       @[@{
                                  @"val": @([_valInputTextField.text integerValue]),
                                  @"idx": @1
                              }]
                                       ],
                              @"did": @"00000000000000000000780f773149c2",
                              @"act": @"set",
                              @"params": @[@"pwr"]
                              };
    //dev_taskdata
//    NSDictionary *dataDic = @{
//                              @"type": @0,
//                              @"index": @0,
//                              @"did": @"00000000000000000000780f773149c2"
//                              };
    
    //dev_taskadd
//    BOOL enable = true;
//    NSDictionary *dataDic = @{
//                              @"did": @"00000000000000000000780f773149c2",
//                              @"enable": @(enable),
//                              @"data": @{
//                                  @"vals": @[
//                                           @[@{
//                                      @"val": @0,
//                                      @"idx": @1
//                                  }]
//                                           ],
//                                  @"params": @[@"pwr"]
//                              },
//                              @"type": @0,
//                              @"time": @"2018-07-18 11:31:00"
//                              };
    NSString *dataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dataDic options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:dataStr command:@"dev_ctrl" scriptPath:nil sendcount:5];
    
    
    _resultTextView.text = result;
}



- (void)dnaControlWithAction:(NSString *)action param:(NSString *)param val:(NSString *)val {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@([val integerValue]) forParam:param];
//    [stdData setValue:val forParam:@"ntlight"];
    
    BLStdControlResult *result = [_blController dnaControl:[_device getDid] stdData:stdData action:action];
    
    if ([result succeed]) {
        NSDictionary *dic = [[result getData] toDictionary];
        
        NSString *resultString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        _resultTextView.text = resultString;
    } else {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
    
}

- (void)getDeviceProfile {
    BLProfileStringResult *result = [_blController queryProfileByPid:[_device getPid]];
    if ([result succeed]) {
        _resultTextView.text = [result getProfile];
    } else {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)queryTaskList {
    BLQueryTaskResult *result = [_blController queryTask:[_device getDid]];
    if ([result succeed]) {
        NSArray *timeTask = [result getTimer];
        NSArray *delayTask = [result getDelay];
        NSArray *PeriodTask = [result getPeriod];
        NSArray *cycleTask = [result getCycle];
        NSArray *randomTask =[result getRandom];
        _resultTextView.text = [NSString stringWithFormat:@"timeTask:%ld   delayTask:%ld   PeriodTask:%ld    cycleTask:%ld    randomTask:%ld", (unsigned long)timeTask.count,(unsigned long)delayTask.count,(unsigned long)PeriodTask.count,(unsigned long)cycleTask.count, (unsigned long)randomTask.count];
    } else {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)setTask {
    BLCycleOrRandomInfo *timerInfo = [[BLCycleOrRandomInfo alloc] init];
    [timerInfo setIndex:0];
    [timerInfo setEnable:YES];
//    [timerInfo setYear:2017];
//    [timerInfo setMonth:10];
//    [timerInfo setDay:1];
    [timerInfo setHour:10];
    [timerInfo setMinute:10];
    [timerInfo setSeconds:00];
    [timerInfo setCmd1duration:1800];
    [timerInfo setEndhour:12];
    [timerInfo setEndminute:10];
    [timerInfo setEndseconds:00];
    [timerInfo setCmd2duration:1800];
    [timerInfo setRepeat:@[@1,@2,@3,@4,@5,@6,@7]];

    
    BLStdData *stdData = [[BLStdData alloc] init];
    NSString *val = @"0";
    NSString *param = @"pwr1";
    [stdData setValue:val forParam:param];
    
    BLStdData *stdData2 = [[BLStdData alloc] init];
    NSString *val2 = @"0";
    NSString *param2 = @"pwr";
    [stdData2 setValue:val2 forParam:param2];
    
//    BLQueryTaskResult *result = [_blController updateTask:[_device getDid] sDid:nil taskType:BL_DELAY_TYPE_LIST isNew:YES timerInfo:timerInfo stdData:stdData];
//    BLQueryTaskResult *result = [_blController updateTask:[_device getDid] sDid:nil taskType:BL_CYCLE_TYPE_LIST isNew:YES cycleInfo:timerInfo stdData1:stdData stdData2:stdData2];
    BLQueryTaskResult *result = [_blController delTask:[_device getDid] sDid:nil taskType:BL_CYCLE_TYPE_LIST index:0];
    if ([result succeed]) {
        NSArray *timeTask = [result getTimer];
        NSArray *delayTask = [result getDelay];
        NSArray *PeriodTask = [result getPeriod];
        NSArray *cycleTask = [result getCycle];
        NSArray *randomTask =[result getRandom];
        _resultTextView.text = [NSString stringWithFormat:@"timeTask:%ld   delayTask:%ld   PeriodTask:%ld    cycleTask:%ld    randomTask:%ld", (unsigned long)timeTask.count,(unsigned long)delayTask.count,(unsigned long)PeriodTask.count,(unsigned long)cycleTask.count, (unsigned long)randomTask.count];
    } else {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

- (void)getDeviceTaskData {
//    BLQueryTaskResult *result = [_blController delTask:[_device getDid] sDid:nil taskType:BL_CYCLE_TYPE_LIST index:0];
    NSString *val = _valInputTextField.text;
    NSString *param = _paramInputTextField.text;

    NSInteger index = [val integerValue];
    NSInteger taskType = [param integerValue];

    BLTaskDataResult *result = [_blController queryTaskData:_device.did sDid:nil taskType:taskType index:index];
    
    if ([result succeed]) {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    } else {
        _resultTextView.text = [NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}


@end
