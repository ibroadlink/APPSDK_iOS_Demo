//
//  GeneralTimerControlView.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2018/3/14.
//  Copyright © 2018年 BroadLink. All rights reserved.
//

#import "GeneralTimerControlView.h"

#import "BLDeviceService.h"
#import "BLStatusBar.h"

@interface GeneralTimerControlView ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *timerList;

@property (strong, nonatomic) NSMutableArray *timeArray;
@property (assign, nonatomic) NSInteger nextIndex;
@property (strong, nonatomic) BLDNADevice *device;

@end

@implementation GeneralTimerControlView

+ (instancetype)viewController {
    GeneralTimerControlView *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.timeArray = [NSMutableArray arrayWithCapacity:0];
    self.nextIndex = -1;
    
    [self setExtraCellLineHidden:self.timerList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getTimerList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)addTimer:(id)sender {
    //新增普通定时
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Selection Mode" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *commTimerAction = [UIAlertAction actionWithTitle:@"Common Timer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Common Timer" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_*_*_0,1,3,5_*";
            textField.placeholder = @"time";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"pwr";
            textField.placeholder = @"params";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"1";
            textField.placeholder = @"val";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *timeStr = alertController.textFields.firstObject.text;
            NSString *params = alertController.textFields[1].text;
            NSInteger val = [alertController.textFields.lastObject.text integerValue];
            [self addCommTimerDnaControl:timeStr params:params val:val];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增延时定时
    UIAlertAction *delayTimerAction = [UIAlertAction actionWithTitle:@"Delay Timer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delay Timer" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_*_*_0,1,3,5_*";
            textField.placeholder = @"time";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"pwr";
            textField.placeholder = @"params";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"1";
            textField.placeholder = @"val";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *timeStr = alertController.textFields.firstObject.text;
            NSString *params = alertController.textFields[1].text;
            NSInteger val = [alertController.textFields.lastObject.text integerValue];
            [self addDelayTimerDnaControl:timeStr params:params val:val];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增周期定时
    UIAlertAction *periodTimerAction = [UIAlertAction actionWithTitle:@"Period Timer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Period Timer" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_*_*_0,1,3,5_*";
            textField.placeholder = @"time";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"pwr";
            textField.placeholder = @"params";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"1";
            textField.placeholder = @"val";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *timeStr = alertController.textFields.firstObject.text;
            NSString *params = alertController.textFields[1].text;
            NSInteger val = [alertController.textFields.lastObject.text integerValue];
            [self addPeriodTimerDnaControl:timeStr params:params val:val];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增循环定时
    UIAlertAction *cycleTimerAction = [UIAlertAction actionWithTitle:@"Cycle Timer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cycle Timer" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_11_*_*_0,1,3,5_*";
            textField.placeholder = @"stime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_*_*_0,1,3,5_*";
            textField.placeholder = @"etime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"15";
            textField.placeholder = @"time1";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"15";
            textField.placeholder = @"time2";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"pwr";
            textField.placeholder = @"params";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *stimeStr = alertController.textFields.firstObject.text;
            NSString *etimeStr = alertController.textFields[1].text;
            NSInteger time1Int = [alertController.textFields[2].text integerValue];
            NSInteger time2Int = [alertController.textFields[3].text integerValue];
            NSString *params = alertController.textFields[4].text;
            [self addCycleTimerDnaControl:stimeStr etime:etimeStr time1:time1Int time2:time2Int params:params];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增随机定时
    UIAlertAction *randTimerAction = [UIAlertAction actionWithTitle:@"Random Timer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Random Timer" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_11_*_*_0,1,3,5_*";
            textField.placeholder = @"stime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_*_*_0,1,3,5_*";
            textField.placeholder = @"etime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"15";
            textField.placeholder = @"time1";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"15";
            textField.placeholder = @"time2";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"pwr";
            textField.placeholder = @"params";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *stimeStr = alertController.textFields.firstObject.text;
            NSString *etimeStr = alertController.textFields[1].text;
            NSInteger time1Int = [alertController.textFields[2].text integerValue];
            NSInteger time2Int = [alertController.textFields[3].text integerValue];
            NSString *params = alertController.textFields[4].text;
            [self addRandTimerDnaControl:stimeStr etime:etimeStr time1:time1Int time2:time2Int params:params];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //配置日出日落信息
    UIAlertAction *sunriseAction = [UIAlertAction actionWithTitle:@"Sunrise Timer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sunrise Timer" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"2018";
            textField.placeholder = @"year";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"120";
            textField.placeholder = @"longitude";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"30";
            textField.placeholder = @"latitude";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSInteger year = [alertController.textFields.firstObject.text integerValue];
            double longitude = [alertController.textFields[1].text doubleValue];
            double latitude = [alertController.textFields[2].text doubleValue];
            [self addSunriseTime:year longitude:longitude latitude:latitude];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
    [actionSheetController addAction:commTimerAction];
    [actionSheetController addAction:delayTimerAction];
    [actionSheetController addAction:periodTimerAction];
    [actionSheetController addAction:cycleTimerAction];
    [actionSheetController addAction:randTimerAction];
    [actionSheetController addAction:sunriseAction];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheetController animated:YES completion:nil];
   
}

- (IBAction)stopTimerType:(id)sender {
    UIAlertController *timerTypeController = [UIAlertController alertControllerWithTitle:@"StartOrStopTimerType" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Commen";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Delayen";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Perioden";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Cycleen";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Randen";
    }];
    [timerTypeController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger CommenStr = [timerTypeController.textFields.firstObject.text integerValue];
        NSInteger delayenStr = [timerTypeController.textFields[1].text integerValue];
        NSInteger periodenStr = [timerTypeController.textFields[2].text integerValue];
        NSInteger cycleenStr = [timerTypeController.textFields[3].text integerValue];
        NSInteger randenStr = [timerTypeController.textFields.lastObject.text integerValue];
        [self startOrstopTimerTypeCommen:CommenStr delayen:delayenStr perioden:periodenStr cycleen:cycleenStr randen:randenStr];
    }]];
    [timerTypeController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:timerTypeController animated:YES completion:nil];
    
    [self queryTimeType];
}

- (IBAction)next:(id)sender {
    self.nextIndex++;
    [self gettimerDnaControl:5 index:self.nextIndex];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"timeInfoCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    NSDictionary *dic = self.timeArray[indexPath.row];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",dic[@"id"]];
    NSString *type = dic[@"type"];
    if ([type isEqualToString:@"comm"] || [type isEqualToString:@"delay"] || [type isEqualToString:@"period"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",dic[@"name"],dic[@"time"]];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@",dic[@"name"],dic[@"stime"],dic[@"etime"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = self.timeArray[indexPath.row];
    NSString *timer = [BLCommonTools serializeMessage:dic];
    UIAlertController *timerTypeController = [UIAlertController alertControllerWithTitle:@"定时信息修改" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = timer;
        textField.placeholder = @"timer";
    }];
    [timerTypeController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *timerStr = timerTypeController.textFields.firstObject.text;
        NSDictionary *timeInfo = [BLCommonTools deserializeMessageJSON:timerStr];
        NSDictionary *stdData = @{
                                  @"did":[BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                                  @"act":@(2),
                                  @"timerlist":@[
                                          timeInfo
                                          ]
                                  };
        NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
        [BLStatusBar showTipMessageWithStatus:result];

    }]];
    [timerTypeController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:timerTypeController animated:YES completion:nil];
    [self getTimerList];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *dic = self.timeArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deltimerDnaControl:dic[@"type"] sid:[dic[@"id"] integerValue]];
        [self.timeArray removeObjectAtIndex:indexPath.row];
        [self.timerList deleteRowsAtIndexPaths:@[indexPath]  withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)timerController:(NSString *)time type:(NSString *)type name:(NSString *)name cmd:(NSDictionary *)cmd {
    NSDictionary *timeInfo = @{
                               @"did": [BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                               @"type":type,
                               @"en":@(1),
                               @"name":name,
                               @"time":time,
                               @"cmd":cmd,
                               };
    NSDictionary *stdData = @{
                              @"did":[BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                              @"act":@(0),
                              @"timerlist":@[
                                      timeInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self getTimerList];
}

//新增普通定时
- (void)addCommTimerDnaControl:(NSString *)time params:(NSString *)params val:(NSInteger)val {
    NSDictionary *cmd = @{@"params":@[params],@"vals":@[@[@{@"val":@(val),@"idx":@1}]]};
    [self timerController:time type:@"comm" name:@"普通定时" cmd:cmd];
}
//新增延时定时
- (void)addDelayTimerDnaControl:(NSString *)time params:(NSString *)params val:(NSInteger)val {
    NSDictionary *cmd = @{@"params":@[params],@"vals":@[@[@{@"val":@(val),@"idx":@1}]]};
    [self timerController:time type:@"delay" name:@"延时定时" cmd:cmd];
}
//新增周期定时
- (void)addPeriodTimerDnaControl:(NSString *)time params:(NSString *)params val:(NSInteger)val{
    NSDictionary *cmd = @{@"params":@[params],@"vals":@[@[@{@"val":@(val),@"idx":@1}]]};
    [self timerController:time type:@"period" name:@"周期定时" cmd:cmd];
}
//新增随机定时
- (void)addRandTimerDnaControl:(NSString *)stime etime:(NSString *)etime time1:(NSInteger)time1 time2:(NSInteger)time2 params:(NSString *)params {
    NSDictionary *cmd = @{@"params":@[params],@"vals":@[@[@{@"val":@1,@"idx":@1}]]};
    NSDictionary *cmd1 = @{@"params":@[params],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};
    
    NSDictionary *cycInfo = @{
                              @"type":@"rand",
                              @"en":@(1),
                              @"name":@"随机定时",
                              @"stime":stime,
                              @"etime":etime,
                              @"time1":@(time1),
                              @"time2":@(time2),
                              @"cmd1":cmd,
                              @"cmd2":cmd1
                              };
    NSDictionary *stdData = @{
                              @"did":[BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                              @"act":@(0),
                              @"timerlist":@[
                                      cycInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self getTimerList];
}
//新增循环定时
- (void)addCycleTimerDnaControl:(NSString *)stime etime:(NSString *)etime time1:(NSInteger)time1 time2:(NSInteger)time2 params:(NSString *)params{
    NSDictionary *cmd = @{@"params":@[params],@"vals":@[@[@{@"val":@1,@"idx":@1}]]};
    NSDictionary *cmd1 = @{@"params":@[params],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};

    NSDictionary *cycInfo = @{
                              @"type":@"cycle",
                              @"en":@(1),
                              @"name":@"循环定时",
                              @"stime":stime,
                              @"etime":etime,
                              @"time1":@(time1),
                              @"time2":@(time2),
                              @"cmd1":cmd,
                              @"cmd2":cmd1
                              };
    NSDictionary *stdData = @{
                              @"did":[BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                              @"act":@(0),
                              @"timerlist":@[
                                      cycInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self getTimerList];
}
//删除定时
- (void)deltimerDnaControl:(NSString *)type sid:(NSInteger)sid {
    NSDictionary *timeInfo = @{
                               @"type":type,
                               @"id":@(sid)
                               };
    NSDictionary *stdData = @{
                              @"did":[BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                              @"act":@(1),
                              @"timerlist":@[
                                      timeInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
//    [self gettimerDnaControl];
}

- (void)getTimerList {
    [self gettimerDnaControl:10 index:0];
}

//获取定时列表
- (void)gettimerDnaControl:(NSInteger)count index:(NSInteger)index {
    NSDictionary *stdData = @{
                              @"did":[BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                              @"act":@(3),
                              @"type":@"all",
                              @"count":@(count),
                              @"index":@(index)
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSInteger status = [dic[@"status"] integerValue];
        if (status == 0) {
            self.timeArray = dic[@"data"][@"timerlist"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.timerList reloadData];
            });
        } else {
            NSString *msg = dic[@"msg"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)status, msg]];
            });
        }
    });
}

//开启或者禁用某种定时
- (void)startOrstopTimerTypeCommen:(NSInteger)commen delayen:(NSInteger)delayen perioden:(NSInteger)perioden cycleen:(NSInteger)cycleen randen:(NSInteger)randen  {
    NSDictionary *stdData = @{
                              @"did":[BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                              @"act":@(4),
                              @"comm_en":@(commen),
                              @"delay_en":@(delayen),
                              @"period_en":@(perioden),
                              @"cycle_en":@(cycleen),
                              @"rand_en":@(randen)
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
}

//查询定时限制信息
- (void)queryTimeType {
    NSDictionary *stdData = @{
                              @"did":[BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                              @"act":@(5),
                              @"type":@""
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
}

- (int)setHour:(int)hour {
    int endHuor = hour + 8;
    if (endHuor > 24) {
        endHuor = endHuor - 24;
    }
    
    return endHuor;
}

//配置日出日落信息
- (void)addSunriseTime:(NSInteger)year longitude:(double)longitude latitude:(double)latitude  {
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"tableList" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    for (int i = 1; i <= 12; i++) {
        NSMutableArray *tableList = [NSMutableArray array];
        BLSunriseResult *sunriseResult = [[BLLet sharedLet].controller calulateSunriseTimeWithData:[NSString stringWithFormat:@"%ld-%d-01",(long)year,i] longitude:longitude latitude:latitude];
        NSString *sunrise = sunriseResult.sunrise;  //01:04:11(UTC)
        NSString *sunset = sunriseResult.sunset;    //19:01:29(UTC)
        
        int sunrise_hour = [[sunrise substringWithRange:NSMakeRange(0,2)] intValue];
        int sunrise_min = [[sunrise substringWithRange:NSMakeRange(3,2)] intValue];
        int sunrise_sec = [[sunrise substringWithRange:NSMakeRange(6,2)] intValue];
        
        int sunset_hour = [[sunset substringWithRange:NSMakeRange(0,2)] intValue];
        int sunset_min = [[sunset substringWithRange:NSMakeRange(3,2)] intValue];
        int sunset_sec = [[sunset substringWithRange:NSMakeRange(6,2)] intValue];
        
        sunrise_hour = [self setHour:sunrise_hour];
        sunset_hour = [self setHour:sunset_hour];
        
        [tableList addObject:@(i)];
        [tableList addObject:@(1)];
        [tableList addObject:@(sunrise_hour)];
        [tableList addObject:@(sunrise_min)];
        [tableList addObject:@(sunrise_sec)];
        [tableList addObject:@(sunset_hour)];
        [tableList addObject:@(sunset_min)];
        [tableList addObject:@(sunset_sec)];
        
        NSString *tableListString = [tableList componentsJoinedByString:@","];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = tableListString;
            textField.placeholder = @"mon,day,sunrise_hour,sunrise_min,sunrise_sec,sunset_hour,sunset_min,sunset_sec";
        }];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray  *tableListArray = [NSMutableArray array];
        for (int i = 0; i < 12; i ++) {
            NSString *table = alertController.textFields[i].text;
            NSArray  *tableList = [table componentsSeparatedByString:@","];
            [tableListArray addObjectsFromArray:tableList];
        }

        NSMutableArray *tableList = [NSMutableArray array];
        for (NSString *table in tableListArray) {
            [tableList addObject:@([table intValue])];
        }
        [self addSunriseTime:year longitude:longitude latitude:latitude table:tableList];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)addSunriseTime:(NSInteger)year longitude:(double)longitude latitude:(double)latitude table:(NSArray *)tableList {
    NSDictionary *stdData = @{
                              @"did":[BLCommonTools isEmpty:self.sdid] ? self.device.did : self.sdid,
                              @"act":@(6),
                              @"year":@(year),
                              @"longitude":[NSString stringWithFormat:@"%f",longitude],
                              @"latitude":[NSString stringWithFormat:@"%f",latitude],
                              @"fmt" :@0,
                              @"table":tableList
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
}

@end
