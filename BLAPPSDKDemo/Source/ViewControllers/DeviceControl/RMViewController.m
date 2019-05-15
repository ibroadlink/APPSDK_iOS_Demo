//
//  RMViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/1.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "RMViewController.h"
#import <BLLetIRCode/BLLetIRCode.h>

#import "BLDeviceService.h"
#import "BLStatusBar.h"

@interface RMViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) BLDNADevice *device;

@property (strong, nonatomic) NSString *irdaCodeStr;
@property (strong, nonatomic) NSString *irdaUnitCodeStr;
@property (strong, nonatomic) NSMutableArray *timerInfos;
@property (weak, nonatomic) IBOutlet UILabel *IrdaCode;
@property (weak, nonatomic) IBOutlet UITableView *timerTableView;

@end

@implementation RMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    
    self.timerInfos = [NSMutableArray arrayWithCapacity:0];
    self.timerTableView.delegate = self;
    self.timerTableView.dataSource = self;
    [self setExtraCellLineHidden:self.timerTableView];
    
    self.irdaCodeStr = @"26008c00959115351535153515111411141114111411143614361436141114111411141114111436143614361436141114111411141114111411141114111436153515351535150005f295921535153515351510151015101510151015351535153515101510151015101510153515351535153515101510151015101510151015101510153515351535153515000d05000000000000000000000000";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)learnButton:(id)sender {

    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:nil forParam:@"irdastudy"];
    
    BLStdControlResult *studyResult = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:@"get"];
    if ([studyResult succeed]) {
        self.IrdaCode.text = @"Learnning... Please click your remote control button!";
    } else {
        self.IrdaCode.text = [NSString stringWithFormat:@"Start learn ircode failed: (%ld)%@", (long)studyResult.status, studyResult.msg];
    }
}

- (IBAction)GetIrdaCode:(id)sender {
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:nil forParam:@"irda"];
    
    BLStdControlResult *irdaResult = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:@"get"];
    if ([irdaResult succeed]) {
        NSDictionary *dic = [[irdaResult getData] toDictionary];
        if ([dic[@"vals"] count] != 0) {
            self.irdaCodeStr = dic[@"vals"][0][0][@"val"];
        } else {
            self.IrdaCode.text = @"No ircode getted, please click again!";
        }
    } else {
        self.IrdaCode.text = [NSString stringWithFormat:@"Get ircode failed: (%ld)%@", (long)irdaResult.status, irdaResult.msg];
    }
}

- (void)sendCodeWithType:(NSUInteger)type {
    BLStdData *stdData = [[BLStdData alloc] init];

    if (type == 1) {
        
        if ([BLCommonTools isEmpty:self.irdaUnitCodeStr]) {
            [BLStatusBar showTipMessageWithStatus:@"Please change wave code to unit code first!"];
            return;
        }
        
        [stdData setValue:self.irdaUnitCodeStr forParam:@"irda"];
    } else {
        [stdData setValue:self.irdaCodeStr forParam:@"irda"];
    }
    
    BLStdControlResult *sendResult = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:@"set"];
    if ([sendResult succeed]) {
        self.IrdaCode.text = @"Send ircode success!";
    } else {
        self.IrdaCode.text = [NSString stringWithFormat:@"Send ircode failed: (%ld)%@", (long)sendResult.status, sendResult.msg];
    }
}

- (IBAction)SendIrdaCode:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Code chose" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *waveAction = [UIAlertAction actionWithTitle:@"Wave Code Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendCodeWithType:0];
    }];
    
    UIAlertAction *uintAction = [UIAlertAction actionWithTitle:@"Unit Code Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendCodeWithType:1];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];

    [alert addAction:waveAction];
    [alert addAction:uintAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)waveCode2UnitCode:(UIButton *)sender {
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    NSString *waveCode = self.irdaCodeStr;
    NSString *unitCode = [blircode waveCodeChangeToUnitCode:waveCode];
    
    if (unitCode) {
        NSLog(@"unitCode:%@", unitCode);
        self.irdaUnitCodeStr = unitCode;
        self.IrdaCode.text = unitCode;
    } else {
        self.IrdaCode.text = @"Change Wave Code To Unit Code Failed!";
    }
}

- (IBAction)unitCode2WaveCode:(UIButton *)sender {
    if (!self.irdaUnitCodeStr) {
        [BLStatusBar showTipMessageWithStatus:@"Please get unit code first!"];
        return;
    }
    BLIRCode *blircode = [BLIRCode sharedIrdaCode];
    NSString *waveCode = [blircode unitCodeChangeToWaveCode:self.irdaUnitCodeStr];
    
    if (waveCode) {
        NSLog(@"waveCode:%@", waveCode);
        self.IrdaCode.text = [NSString stringWithFormat:@"%@\n\n%@", self.irdaCodeStr, waveCode];
    } else {
        self.IrdaCode.text = @"Change Unit Code To Wave Code Failed!";
    }
}

- (IBAction)TimerBtn:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please input timer info" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //like @"0|1|19|30|1|打开电视|2|32:100@64:500|"
        textField.text = @"0|1|19|30|1|openTV|2|32:100@64:500|";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *timerInfo = alertController.textFields.firstObject.text;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self setRMTimer:timerInfo];
        });
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)delTimer:(NSString *)timerInfo {
    if ([BLCommonTools isEmpty:timerInfo]) {
        [BLStatusBar showTipMessageWithStatus:@"Please input timer info"];
        return;
    }
    NSInteger index = 0;
    NSArray *infos = [timerInfo componentsSeparatedByString:@"|"];
    if (infos && infos.count > 0) {
        index = [infos[0] integerValue];
    }
    
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@(index) forParam:@"delrmtimer"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showIndicatorOnWindow];
    });
    BLStdControlResult *delResult = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:@"set"];
    if ([delResult succeed]) {
        [self queryTimerList:0];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            self.IrdaCode.text = [NSString stringWithFormat:@"Set RM Timer failed: (%ld)%@", (long)delResult.status, delResult.msg];
        });
    }
}

- (void)setRMTimer:(NSString *)timerInfo {
    if ([BLCommonTools isEmpty:timerInfo]) {
        [BLStatusBar showTipMessageWithStatus:@"Please input timer info"];
        return;
    }
    NSString *value  = [timerInfo stringByAppendingString:self.irdaCodeStr];
    NSLog(@"RM timer value: %@", value);
    
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:value forParam:@"rmtimer"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showIndicatorOnWindow];
    });
    BLStdControlResult *sendResult = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:@"set"];
    if ([sendResult succeed]) {
        [self queryTimerList:0];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideIndicatorOnWindow];
            self.IrdaCode.text = [NSString stringWithFormat:@"Set RM Timer failed: (%ld)%@", (long)sendResult.status, sendResult.msg];
        });
    }
}

- (void)queryTimerList:(NSUInteger)index {
    if (index == 0) {
        [self.timerInfos removeAllObjects];
    }
    
    BLStdData *stdData = [[BLStdData alloc] init];
    [stdData setValue:@(0) forParam:@"rmtimer"];
    [stdData setValue:@(0) forParam:@"count"];
    [stdData setValue:@(index) forParam:@"index"];
    
    BLStdControlResult *result = [[BLLet sharedLet].controller dnaControl:self.device.ownerId ? self.device.deviceId : self.device.did stdData:stdData action:@"get"];
    if ([result succeed]) {
        NSDictionary *dic = [result.data toDictionary];
        NSArray *vals = dic[@"vals"][0];
        if (vals.count > 0) {
            for (NSDictionary *info in vals) {
                NSString *val = info[@"val"];
                [self.timerInfos addObject:val];
            }
            
            NSNumber *totalvals = [result.data valueForParam:@"count"];
            NSInteger total = 0;
            if (totalvals) {
                total = [totalvals integerValue];
            }
            
            if (self.timerInfos.count < total) {
                [self queryTimerList:self.timerInfos.count];
                return;
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideIndicatorOnWindow];
        [self.timerTableView reloadData];
    });
}

- (IBAction)queryTimer:(UIButton *)sender {
    [self showIndicatorOnWindow];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self queryTimerList:0];
    });
}


- (void)setIrdaCodeStr:(NSString *)irdaCodeStr {
    _irdaCodeStr = irdaCodeStr;
    self.IrdaCode.text = irdaCodeStr;
}


#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timerInfos.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"RM_TIMER_CELL";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *timer = self.timerInfos[indexPath.row];
    cell.textLabel.text = timer;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *timerInfo = self.timerInfos[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self delTimer:timerInfo];
        });
    }
}

@end
