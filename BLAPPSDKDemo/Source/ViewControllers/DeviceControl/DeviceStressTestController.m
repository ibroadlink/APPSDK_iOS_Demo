//
//  DeviceStressTestController.m
//  BLAPPSDKDemo
//
//  Created by admin on 2019/4/9.
//  Copyright © 2019 BroadLink. All rights reserved.
//

#import "DeviceStressTestController.h"

#import "BLStatusBar.h"
#import "BLDeviceService.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface DeviceStressTestController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITextView *resultText;
@property (nonatomic, strong) UITableView *cmdTable;
@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) BLDNADevice *device;
@property (nonatomic, strong) NSMutableArray *cmdList;
@property (nonatomic, assign) NSUInteger recycleTimes;

@property (nonatomic, strong) NSString *logfile;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation DeviceStressTestController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Stress Test";
    self.view.backgroundColor = [BLTheme backgroundColor];
    self.recycleTimes = 1;
    self.cmdList = [NSMutableArray array];

    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [self.formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];

    [self buildUI];
}

- (void)buildUI {
    UIButton *addButton = [BLTheme makePrimaryButtonWithTitle:@"Add Command"
                                                       target:self
                                                       action:@selector(showDeviceList)];
    UIButton *startButton = [BLTheme makeSecondaryButtonWithTitle:@"Start"
                                                           target:self
                                                           action:@selector(startStressTest)];
    UIButton *stopButton = [BLTheme makeSecondaryButtonWithTitle:@"Stop"
                                                          target:self
                                                          action:@selector(stopStressTest)];
    [BLTheme styleDangerOutlineButton:stopButton];

    UIStackView *actionRow = [[UIStackView alloc] initWithArrangedSubviews:@[addButton, startButton, stopButton]];
    actionRow.axis = UILayoutConstraintAxisHorizontal;
    actionRow.spacing = 10;
    actionRow.distribution = UIStackViewDistributionFillEqually;
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) { make.height.mas_equalTo(44); }];
    [startButton mas_makeConstraints:^(MASConstraintMaker *make) { make.height.mas_equalTo(44); }];
    [stopButton mas_makeConstraints:^(MASConstraintMaker *make) { make.height.mas_equalTo(44); }];

    UILabel *resultTitle = [[UILabel alloc] init];
    resultTitle.text = @"Live Result";
    resultTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    resultTitle.textColor = [BLTheme subtitleColor];

    self.resultText = [[UITextView alloc] init];
    [BLTheme styleResultTextView:self.resultText];
    self.resultText.editable = NO;
    self.resultText.selectable = YES;
    self.resultText.text = @"Stress test result will appear here.";

    UILabel *cmdTitle = [[UILabel alloc] init];
    cmdTitle.text = @"Command Queue";
    cmdTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    cmdTitle.textColor = [BLTheme subtitleColor];

    self.cmdTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.cmdTable.delegate = self;
    self.cmdTable.dataSource = self;
    self.cmdTable.backgroundColor = [UIColor clearColor];
    self.cmdTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.cmdTable.showsVerticalScrollIndicator = NO;
    if (@available(iOS 15.0, *)) {
        self.cmdTable.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.cmdTable];

    [self.view addSubview:actionRow];
    [self.view addSubview:resultTitle];
    [self.view addSubview:self.resultText];
    [self.view addSubview:cmdTitle];
    [self.view addSubview:self.cmdTable];

    [actionRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(12);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.height.mas_equalTo(44);
    }];
    [resultTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(actionRow.mas_bottom).offset(16);
        make.left.right.equalTo(actionRow);
    }];
    [self.resultText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(resultTitle.mas_bottom).offset(8);
        make.left.right.equalTo(actionRow);
        make.height.mas_equalTo(160);
    }];
    [cmdTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resultText.mas_bottom).offset(16);
        make.left.right.equalTo(actionRow);
    }];
    [self.cmdTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cmdTitle.mas_bottom).offset(8);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
    }];

    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"No commands yet\nTap Add Command to build a queue";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.emptyLabel.textColor = [BLTheme subtitleColor];
    [self.view addSubview:self.emptyLabel];
    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cmdTable);
        make.top.equalTo(self.cmdTable).offset(36);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
    [self updateEmptyState];
}

- (void)updateEmptyState {
    self.emptyLabel.hidden = self.cmdList.count > 0;
}

- (BOOL)createStressTestLogFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];
    if (!fileExists) {
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *dateStr = [self.formatter stringFromDate:[NSDate date]];
    self.logfile = [logDirectory stringByAppendingFormat:@"/%@.log", dateStr];

    BOOL isSuccess = [fileManager createFileAtPath:self.logfile contents:nil attributes:nil];
    NSLog(isSuccess ? @"createStressTestLogFile success" : @"createStressTestLogFile fail");
    return isSuccess;
}

- (void)writeLogToFileWithString:(NSString *)log {
    if ([BLCommonTools isEmpty:log]) {
        return;
    }

    NSString *dateStr = [self.formatter stringFromDate:[NSDate date]];
    NSString *input = [NSString stringWithFormat:@"%@ :\n %@\n\n\n", dateStr, log];

    NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:self.logfile];
    if (!outFile) {
        return;
    }
    [outFile seekToEndOfFile];
    [outFile writeData:[input dataUsingEncoding:NSUTF8StringEncoding]];
    [outFile closeFile];
}

- (void)showTextResult:(NSArray *)infos totalString:(NSString *)totalString {
    NSMutableString *showString = [[NSMutableString alloc] initWithString:totalString];
    for (int i = 0; i < infos.count; i++) {
        NSDictionary *cmdResult = infos[i];
        NSString *result = [NSString stringWithFormat:@"\n\nCmd%d : total %d, success %d, failed %d",
                            i, [cmdResult[@"total"] intValue], [cmdResult[@"success"] intValue], [cmdResult[@"failed"] intValue]];
        [showString appendString:result];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultText.text = showString;
    });
}

- (void)doStressTest {
    BLController *controller = [BLLet sharedLet].controller;
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];

    NSMutableArray *cmdResultArray = [NSMutableArray arrayWithCapacity:self.cmdList.count];
    [self createStressTestLogFile];
    [self writeLogToFileWithString:@"doStressTest start!!!"];

    double successCost = 0;
    int totalTimes = 0;

    for (int k = 0; k < self.recycleTimes; k++) {
        NSString *totalString = [NSString stringWithFormat:@"Recycle Total %ld, now %d, success: %d, cost %lfms", (long)self.recycleTimes, k + 1, totalTimes, successCost];

        for (int i = 0; i < self.cmdList.count; i++) {
            NSDictionary *cmdDic = self.cmdList[i];

            NSString *did = cmdDic[@"did"];
            NSString *cmd = cmdDic[@"cmd"];
            NSString *dataStr = cmdDic[@"data"];
            int count = [cmdDic[@"count"] intValue];
            int interval = [cmdDic[@"interval"] intValue];
            int delay = [cmdDic[@"delay"] intValue];

            BLDNADevice *device = [deviceService.manageDevices objectForKey:did];
            if (!device) {
                [self writeLogToFileWithString:[NSString stringWithFormat:@"Can not find device %@", did]];
                continue;
            }

            NSString *gatewayDid = [Tools controlDidForDevice:device];
            NSString *subDeviceDid;
            if (![BLCommonTools isEmpty:device.pDid]) {
                BLDNADevice *fDevice = [[BLLet sharedLet].controller getDevice:[NSString stringWithFormat:@"%@++%@", device.pDid, device.ownerId]];
                gatewayDid = [Tools controlDidForDevice:fDevice];
                subDeviceDid = [Tools controlDidForDevice:device];

                BLDNADevice *gatewayDevice = [deviceService.manageDevices objectForKey:gatewayDid];
                if (!gatewayDevice) {
                    [self writeLogToFileWithString:[NSString stringWithFormat:@"Can not find gateway device %@", gatewayDid]];
                    continue;
                }
            }

            for (int j = 0; j < count; j++) {
                double start = [[NSDate date] timeIntervalSince1970] * 1000;
                [self writeLogToFileWithString:[NSString stringWithFormat:@"cmd:%@ times:%d", cmdDic, j]];
                NSString *result = [controller dnaControl:gatewayDid subDevDid:subDeviceDid dataStr:dataStr command:cmd scriptPath:nil sendcount:1];
                double end = [[NSDate date] timeIntervalSince1970] * 1000;
                double cost = end - start;
                [self writeLogToFileWithString:[NSString stringWithFormat:@"result:\n%@\ncost: %lfms", result, cost]];

                NSDictionary *retDic = [BLCommonTools deserializeMessageJSON:result];
                int status = [retDic[@"status"] intValue];

                NSDictionary *cmdResult;
                if (i < cmdResultArray.count) {
                    cmdResult = cmdResultArray[i];
                }

                int success = 0;
                int failed = 0;
                if (cmdResult) {
                    success = [cmdResult[@"success"] intValue];
                    failed = [cmdResult[@"failed"] intValue];
                }

                if (status == 0) {
                    success++;
                    totalTimes++;
                    successCost = (successCost * (totalTimes - 1) + cost) / totalTimes;
                } else {
                    failed++;
                }

                int total = success + failed;
                cmdResult = @{
                    @"index": @(i),
                    @"total": @(total),
                    @"success": @(success),
                    @"failed": @(failed)
                };

                if (i < cmdResultArray.count) {
                    cmdResultArray[i] = cmdResult;
                } else {
                    [cmdResultArray addObject:cmdResult];
                }

                [self showTextResult:cmdResultArray totalString:totalString];
                usleep(interval * 1000);
            }
            usleep(delay * 1000);
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self writeLogToFileWithString:self.resultText.text];
        [self writeLogToFileWithString:@"doStressTest over!!!"];
    });
}

- (void)startStressTest {
    if ([BLCommonTools isEmptyArray:self.cmdList]) {
        [BLStatusBar showTipMessageWithStatus:@"Please input command first!!!"];
        return;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Times input" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"1";
        textField.placeholder = @"Recycle Times";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *timesStr = alertController.textFields.firstObject.text;
        if (![BLCommonTools isEmpty:timesStr]) {
            self.recycleTimes = [timesStr integerValue];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self doStressTest];
        });
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)stopStressTest {
    self.recycleTimes = 0;
    [self writeLogToFileWithString:self.resultText.text];
    [self writeLogToFileWithString:@"stopStressTest!!!"];
    self.logfile = nil;
}

- (void)showDeviceList {
    BLDeviceService *deviceService = [BLDeviceService sharedDeviceService];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please Select Device" preferredStyle:UIAlertControllerStyleActionSheet];
    [deviceService.manageDevices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull did, BLDNADevice * _Nonnull dev, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@%@", dev.name, did] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.device = dev;
            [self showCmdList];
        }];
        [alert addAction:action];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCmdList {
    NSDictionary *cmdList = @{
        @"dev_ctrl": @"{\"vals\":[[{\"val\":1,\"idx\":1}]],\"act\":\"set\",\"params\":[\"pwr\"],\"prop\":\"stdctrl\"}",
        @"dev_passthrough": @"",
        @"dev_online": @"",
        @"dev_info": @"{\"data\":{\"name\":\"xxx\",\"lock\":false}}",
        @"fw_version": @"",
        @"fw_upgrade": @"{\"hw_url\":\"xxx\"}",
        @"serv_time": @"",
        @"fastcon_no_config": @"{\"did\":\"xxx\",\"act\":1}",
        @"dev_newsubdev_scan_start": @"{\"pid\":\"xxx\"}",
        @"dev_newsubdev_scan_stop": @"",
        @"dev_newsubdevlist": @"{\"count\":5,\"index\":0}",
        @"dev_subdevdel": @"{\"did\":\"xxx\"}",
        @"dev_subdev_backup": @"{\"count\":5,\"index\":0}",
        @"dev_subdev_restore": @"",
        @"dev_subdev_update_version": @"{\"did\":\"xxx\",\"hw_url\":\"xxx\"}",
        @"dev_subdevmodify": @"{\"did\":\"xxx\",\"pid\":\"xxx\",\"name\":\"xxx\",\"lock\":false,\"type\":10024}",
        @"dev_subdev_timer": @"",
        @"dev_subdev_query_version": @"{\"did\":\"xxx\"}",
        @"dev_tasklist": @"",
        @"dev_taskadd": @"",
        @"dev_taskdel": @"",
        @"dev_taskdata": @"",
        @"service_info_get": @"",
        @"dev_data": @"{\"vals\":[[{\"val\":1,\"idx\":1}]],\"act\":\"set\",\"params\":[\"pwr\"],\"prop\":\"stdctrl\"}",
        @"dev_reset": @"",
        @"dev_log_redirect": @""
    };
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Please Select Cmd" preferredStyle:UIAlertControllerStyleActionSheet];
    [cmdList enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:key style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showCmdInputViewWithKey:key Value:obj];
        }];
        [alert addAction:action];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCmdInputViewWithKey:(NSString *)key Value:(NSString *)value {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Cmd input" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.device.did;
        textField.placeholder = @"Device did";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = key;
        textField.placeholder = @"Cmd. Default : dev_ctrl";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = value;
        textField.placeholder = @"Data String";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Send Count. Default : 1";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Interval(/ms). Default : 1000";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.placeholder = @"Delay(/ms). Default : 1000";
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *did = alertController.textFields.firstObject.text;
        NSString *cmdStr = alertController.textFields[1].text;
        NSString *dataStr = alertController.textFields[2].text;
        NSString *sendCountStr = alertController.textFields[3].text;
        NSString *intervalStr = alertController.textFields[4].text;
        NSString *delayStr = alertController.textFields[5].text;

        if ([BLCommonTools isEmpty:cmdStr]) {
            cmdStr = @"dev_ctrl";
        }

        int sendCount = 1;
        if (![BLCommonTools isEmpty:sendCountStr]) {
            sendCount = [sendCountStr intValue];
        }

        int interval = 1000;
        if (![BLCommonTools isEmpty:intervalStr]) {
            interval = [intervalStr intValue];
        }

        int delay = 1000;
        if (![BLCommonTools isEmpty:delayStr]) {
            delay = [delayStr intValue];
        }

        NSDictionary *cmdDic = @{
            @"did": did ?: @"",
            @"cmd": cmdStr,
            @"data": dataStr ?: @"",
            @"count": @(sendCount),
            @"interval": @(interval),
            @"delay": @(delay)
        };

        [self.cmdList addObject:cmdDic];
        [self.cmdTable reloadData];
        [self updateEmptyState];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cmdList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"STRESS_CMD_CARD_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel *label;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];

        UIView *card = [[UIView alloc] init];
        [BLTheme styleCardView:card];
        [cell.contentView addSubview:card];

        label = [[UILabel alloc] init];
        label.tag = 200;
        label.numberOfLines = 0;
        label.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
        label.textColor = [BLTheme titleColor];
        [card addSubview:label];

        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).insets(UIEdgeInsetsMake(6, 16, 6, 16));
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(card).insets(UIEdgeInsetsMake(12, 12, 12, 12));
        }];
    } else {
        label = (UILabel *)[cell.contentView viewWithTag:200];
    }

    NSDictionary *cmdDic = self.cmdList[indexPath.row];
    label.text = [BLCommonTools serializeMessage:cmdDic];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.cmdList removeObjectAtIndex:indexPath.row];
    }
    [self.cmdTable reloadData];
    [self updateEmptyState];
}

@end
