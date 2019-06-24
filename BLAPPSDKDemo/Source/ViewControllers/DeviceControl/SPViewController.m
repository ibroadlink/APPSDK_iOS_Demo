//
//  SPViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/7/26.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "SPViewController.h"

#import "BLDeviceService.h"
#import "BLStatusBar.h"

@interface SPViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *timerTableView;

@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) NSMutableArray *timerList;
@end

@implementation SPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    
    self.timerList = [[NSMutableArray alloc] init];
    [self GetSpSwitch];
    self.timerTableView.delegate = self;
    self.timerTableView.dataSource = self;
    [self GetTimerList];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timerList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"TIMERCELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.timerList[indexPath.row];
    
    return cell;
}

//获取定时列表
- (void)GetTimerList{
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setParams:@[@"tmrtsk",@"pertsk",@"cyctsk",@"randtsk"] values:@[@[@{@"val":@"", @"idx":@(1)}],@[@{ @"val":@"", @"idx":@(1)}],@[@{ @"val":@"", @"idx":@(1)}],@[@{ @"val":@"", @"idx":@(1)}]]];
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:@"get"];
    if ([result succeed]) {
        NSDictionary *dic = [[result getData] toDictionary];
        NSArray *dicArray = dic[@"vals"];
        for (int j = 0; j< [dicArray count]; j ++) {
            NSArray *switchTimerArray = dicArray[j];
            for (int i = 0;i < switchTimerArray.count; i ++) {
                NSString *tmrtskTimer = dicArray[j][i][@"val"];
                [self.timerList addObject:tmrtskTimer];
            }
        }
        
        
    } else {
        [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
    }
}

//获取开关状态
- (void)GetSpSwitch{
    [self dnaControlWithAction:@"get" param:@"pwr" val:nil];
}

//设置开关
- (IBAction)SPSwitch:(id)sender {
    if ([self.SPswitchtxt.titleLabel.text isEqualToString:@"ON"]) {
        [self dnaControlWithAction:@"set" param:@"pwr" val:@"0"];
    }else{
        [self dnaControlWithAction:@"set" param:@"pwr" val:@"1"];
    }
    
}
- (IBAction)addTimerBtn:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加定时" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    //单次定时
    UIAlertAction *tmrtskAction = [UIAlertAction actionWithTitle:@"单次定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setParams:@[@"tmrtsk"] values:@[@[@{@"val":@"+0800@20180911-151426|1@null|0",@"idx":@(1)}]]];
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:@"set"];
        if ([result succeed]) {
            BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:@"get"];
            if ([result succeed]) {
                NSDictionary *dic = [[result getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                [BLStatusBar showTipMessageWithStatus:switchResult];
            }
        } else {
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        }
    }];
    //周期定时
    UIAlertAction *pertskAction = [UIAlertAction actionWithTitle:@"周期定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setParams:@[@"pertsk"] values:@[@[@{@"val":@"1|+0800-095700@null|null|0|0",@"idx":@(1)},@{@"val":@"1|+0800-164420@null|null|0|0", @"idx":@(1)}]]];
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[self.device getDid] stdData:stdData action:@"set"];
        if ([result succeed]) {
            BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[self.device getDid] stdData:stdData action:@"get"];
            if ([result succeed]) {
                NSDictionary *dic = [[result getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                [BLStatusBar showTipMessageWithStatus:switchResult];
            }
        } else {
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        }
    }];
    //循环定时
    UIAlertAction *cyctskAction = [UIAlertAction actionWithTitle:@"循环定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setParams:@[@"cyctsk"] values:@[@[@{@"val":@"1|+0800-183037@183537|300|300|null",@"idx":@(1)}]]];
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[self.device getDid] stdData:stdData action:@"set"];
        if ([result succeed]) {
            BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[self.device getDid] stdData:stdData action:@"get"];
            if ([result succeed]) {
                NSDictionary *dic = [[result getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                [BLStatusBar showTipMessageWithStatus:switchResult];
            }
        } else {
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        }
    }];
    //防盗定时
    UIAlertAction *randtskAction = [UIAlertAction actionWithTitle:@"防盗定时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setParams:@[@"randtsk"] values:@[@[@{@"val":@"1|+0800-000000@235901|10|12347",@"idx":@(1)}]]];
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[self.device getDid] stdData:stdData action:@"set"];
        if ([result succeed]) {
            BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:[self.device getDid] stdData:stdData action:@"get"];
            if ([result succeed]) {
                NSDictionary *dic = [[result getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                [BLStatusBar showTipMessageWithStatus:switchResult];
            }
        } else {
            [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:tmrtskAction];
    [alertController addAction:pertskAction];
    [alertController addAction:cyctskAction];
    [alertController addAction:randtskAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dnaControlWithAction:(NSString *)action param:(NSString *)param val:(NSString *)val {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BLStdData *stdData = [[BLStdData alloc] init];
        [stdData setValue:val forParam:param];
        
        
        BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:action];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result succeed]) {
                NSDictionary *dic = [[result getData] toDictionary];
                NSString *switchResult = dic[@"vals"][0][0][@"val"];
                if ([switchResult integerValue]) {
                    [self.SPswitchtxt setTitle:@"ON" forState:UIControlStateNormal];
                }else{
                    [self.SPswitchtxt setTitle:@"OFF" forState:UIControlStateNormal];
                }
            } else {
                [BLStatusBar showTipMessageWithStatus:[NSString stringWithFormat:@"Code(%ld) Msg(%@)", (long)result.getError, result.getMsg]];
            }
        });
    });
}

@end
