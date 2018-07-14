//
//  GeneralTimerControlView.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2018/3/14.
//  Copyright © 2018年 BroadLink. All rights reserved.
//

#import "GeneralTimerControlView.h"
#import "AppDelegate.h"
#import "BLStatusBar.h"
@interface GeneralTimerControlView (){
    BLController *_blController;
    NSMutableArray *_timeArray;
    NSInteger _nextIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *timerList;

@end

@implementation GeneralTimerControlView

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _blController = delegate.let.controller;
    _timeArray = [NSMutableArray arrayWithCapacity:0];
    [self gettimerDnaControl];
    _nextIndex = -1;
}

- (IBAction)addTimer:(id)sender {
    //新增普通定时
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:@"Select Timer" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *commTimerAction = [UIAlertAction actionWithTitle:@"Comm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Comm" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_26_2_*_2018";
            textField.placeholder = @"time";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *timeStr = alertController.textFields.firstObject.text;
            [self addCommTimerDnaControl:timeStr];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增延时定时
    UIAlertAction *delayTimerAction = [UIAlertAction actionWithTitle:@"delay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"delay" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_26_2_*_2018";
            textField.placeholder = @"time";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *timeStr = alertController.textFields.firstObject.text;
            [self addDelayTimerDnaControl:timeStr];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增周期定时
    UIAlertAction *periodTimerAction = [UIAlertAction actionWithTitle:@"period" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"period" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_0_9_*_*_0,1,3,5_*";
            textField.placeholder = @"time";
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *timeStr = alertController.textFields.firstObject.text;
            [self addPeriodTimerDnaControl:timeStr];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增循环定时
    UIAlertAction *cycleTimerAction = [UIAlertAction actionWithTitle:@"cycle" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"cycle" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_01_*_*_0,1,2,3,4,5_*";
            textField.placeholder = @"stime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_*_*_0,1,2,3,4,5_*";
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
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *stimeStr = alertController.textFields.firstObject.text;
            NSString *etimeStr = alertController.textFields[1].text;
            NSInteger time1Int = [alertController.textFields[2].text integerValue];
            NSInteger time2Int = [alertController.textFields.lastObject.text integerValue];
            [self addCycleTimerDnaControl:stimeStr etime:etimeStr time1:time1Int time2:time2Int];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    //新增随机定时
    UIAlertAction *randTimerAction = [UIAlertAction actionWithTitle:@"rand" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"rand" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_01_*_*_0,1,2,3,4,5_*";
            textField.placeholder = @"stime";
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0_1_22_*_*_0,1,2,3,4,5_*";
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
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *stimeStr = alertController.textFields.firstObject.text;
            NSString *etimeStr = alertController.textFields[1].text;
            NSInteger time1Int = [alertController.textFields[2].text integerValue];
            NSInteger time2Int = [alertController.textFields.lastObject.text integerValue];
            [self addRandTimerDnaControl:stimeStr etime:etimeStr time1:time1Int time2:time2Int];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    [actionSheetController addAction:commTimerAction];
    [actionSheetController addAction:delayTimerAction];
    [actionSheetController addAction:periodTimerAction];
    [actionSheetController addAction:cycleTimerAction];
    [actionSheetController addAction:randTimerAction];
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (IBAction)stopTimerType:(id)sender {
    UIAlertController *timerTypeController = [UIAlertController alertControllerWithTitle:@"startOrstopTimerType" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"Commen";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"delayen";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"perioden";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"cycleen";
    }];
    [timerTypeController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"randen";
    }];
    [timerTypeController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger CommenStr = [timerTypeController.textFields.firstObject.text integerValue];
        NSInteger delayenStr = [timerTypeController.textFields[1].text integerValue];
        NSInteger periodenStr = [timerTypeController.textFields[2].text integerValue];
        NSInteger cycleenStr = [timerTypeController.textFields[3].text integerValue];
        NSInteger randenStr = [timerTypeController.textFields.lastObject.text integerValue];
        [self startOrstopTimerTypeCommen:CommenStr delayen:delayenStr perioden:periodenStr cycleen:cycleenStr randen:randenStr];
    }]];
    [self presentViewController:timerTypeController animated:YES completion:nil];
    
    [self queryTimeType];
}

- (IBAction)next:(id)sender {
    _nextIndex = _nextIndex + 1;
    [self gettimerDnaControl:5 index:_nextIndex];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _timeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"timeInfoCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    NSDictionary *dic = _timeArray[indexPath.row];
    
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
    NSDictionary *dic = _timeArray[indexPath.row];
    NSString *type = dic[@"type"];
    NSInteger sid = [dic[@"id"] integerValue];
    if ([type isEqualToString:@"comm"] || [type isEqualToString:@"delay"] || [type isEqualToString:@"period"]) {
        NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};
        
        NSDictionary *timeInfo = @{
                                   @"type":type,
                                   @"id":@(sid),
                                   @"en":@1,
                                   @"name":dic[@"name"],
                                   @"time":@"0_1_22_26_2_*_2018",
                                   @"cmd":cmd,
                                   };
        NSDictionary *stdData = @{
                                  @"act":@2,
                                  @"timerlist":@[
                                          timeInfo
                                          ]
                                  };
        NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    }else{
        NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};
        
        NSDictionary *cycInfo = @{
                                  @"type":type,
                                  @"id":@(sid),
                                  @"en":@1,
                                  @"name":dic[@"name"],
                                  @"stime":@"0_1_01_*_*_*_*",
                                  @"etime":@"0_1_23_*_*_*_*",
                                  @"time1":@"0_1_05_*_*_*_*",
                                  @"time2":@"0_1_20_*_*_*_*",
                                  @"cmd1":cmd,
                                  @"cmd2":cmd
                                  };
        NSDictionary *stdData = @{
                                  @"act":@2,
                                  @"timerlist":@[
                                          cycInfo
                                          ]
                                  };
        NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *dic = _timeArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deltimerDnaControl:dic[@"type"] sid:[dic[@"id"] integerValue]];
        [_timeArray removeObjectAtIndex:indexPath.row];
        [_timerList deleteRowsAtIndexPaths:@[indexPath]  withRowAnimation:UITableViewRowAnimationNone];
    }
}
//新增普通定时
- (void)addCommTimerDnaControl:(NSString *)time {
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@1,@"idx":@1}]]};
    
    NSDictionary *timeInfo = @{
                               @"did":self.device.did,
                               @"type":@"comm",
                               @"en":@1,
                               @"name":@"普通定时",
                               @"time":time,
                               @"cmd":cmd,
                               };
    NSDictionary *stdData = @{
                              @"act":@0,
                              @"timerlist":@[
                                      timeInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self gettimerDnaControl];
}
//新增延时定时
- (void)addDelayTimerDnaControl:(NSString *)time {
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@1,@"idx":@1}]]};
    
    NSDictionary *timeInfo = @{
                               @"type":@"delay",
                               @"en":@1,
                               @"name":@"延时定时",
                               @"time":time,
                               @"cmd":cmd,
                               };
    NSDictionary *stdData = @{
                              @"act":@0,
                              @"timerlist":@[
                                      timeInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self gettimerDnaControl];
}
//新增周期定时
- (void)addPeriodTimerDnaControl:(NSString *)time {
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@1,@"idx":@1}]]};
    
    NSDictionary *timeInfo = @{
                               @"type":@"period",
                               @"en":@1,
                               @"name":@"period",
                               @"time":time,
                               @"cmd":cmd,
                               };
    NSDictionary *stdData = @{
                              @"act":@0,
                              @"timerlist":@[
                                      timeInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self gettimerDnaControl];
}
//新增随机定时
- (void)addRandTimerDnaControl:(NSString *)stime etime:(NSString *)etime time1:(NSInteger)time1 time2:(NSInteger)time2 {
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@1,@"idx":@1}]]};
    NSDictionary *cmd1 = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};
    
    NSDictionary *cycInfo = @{
                              @"type":@"rand",
                              @"en":@1,
                              @"name":@"随机定时",
                              @"stime":stime,
                              @"etime":etime,
                              @"time1":@(time1),
                              @"time2":@(time2),
                              @"cmd1":cmd,
                              @"cmd2":cmd1
                              };
    NSDictionary *stdData = @{
                              @"act":@0,
                              @"timerlist":@[
                                      cycInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self gettimerDnaControl];
}
//新增循环定时
- (void)addCycleTimerDnaControl:(NSString *)stime etime:(NSString *)etime time1:(NSInteger)time1 time2:(NSInteger)time2 {
    NSDictionary *cmd = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@1,@"idx":@1}]]};
    NSDictionary *cmd1 = @{@"params":@[@"pwr"],@"vals":@[@[@{@"val":@0,@"idx":@1}]]};

    NSDictionary *cycInfo = @{
                              @"type":@"cycle",
                              @"en":@1,
                              @"name":@"循环定时",
                              @"stime":stime,
                              @"etime":etime,
                              @"time1":@(time1),
                              @"time2":@(time2),
                              @"cmd1":cmd,
                              @"cmd2":cmd1
                              };
    NSDictionary *stdData = @{
                              @"act":@0,
                              @"timerlist":@[
                                      cycInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
    [self gettimerDnaControl];
}
//删除定时
- (void)deltimerDnaControl:(NSString *)type sid:(NSInteger)sid {
    NSDictionary *timeInfo = @{
                               @"type":type,
                               @"id":@(sid)
                               };
    NSDictionary *stdData = @{
                              @"act":@1,
                              @"timerlist":@[
                                      timeInfo
                                      ]
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
//    [self gettimerDnaControl];
}

//获取定时列表
- (void)gettimerDnaControl:(NSInteger)count index:(NSInteger)index {
    NSDictionary *stdData = @{
                              @"act":@3,
                              @"type":@"all",
                              @"count":@(count),
                              @"index":@(index)
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"dic%@",dic[@"data"][@"timerlist"]);
    _timeArray = dic[@"data"][@"timerlist"];
    [self.timerList reloadData];
}

- (void)gettimerDnaControl {
    [self gettimerDnaControl:10 index:0];
}

//开启或者禁用某种定时
- (void)startOrstopTimerTypeCommen:(NSInteger)commen delayen:(NSInteger)delayen perioden:(NSInteger)perioden cycleen:(NSInteger)cycleen randen:(NSInteger)randen  {
    NSDictionary *stdData = @{
                              @"did":self.device.did,
                              @"act":@4,
                              @"comm_en":@(commen),
                              @"delay_en":@(delayen),
                              @"period_en":@(perioden),
                              @"cycle_en":@(cycleen),
                              @"rand_en":@(randen)
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
}

//查询定时限制信息
- (void)queryTimeType {
    NSDictionary *stdData = @{
                              @"did":self.device.did,
                              @"act":@5,
                              @"type":@"period|comm|delay|cycle|rand"
                              };
    NSString *stdDataStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:stdData options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *result = [_blController dnaControl:self.device.did subDevDid:nil dataStr:stdDataStr command:@"dev_subdev_timer" scriptPath:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"status%@,did:%@",dic[@"status"],dic[@"did"]);
}

@end
