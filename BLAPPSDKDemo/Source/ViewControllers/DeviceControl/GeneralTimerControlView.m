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
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, BLTimerAct) {
    BLTimerActAdd = 0,
    BLTimerActDelete = 1,
    BLTimerActUpdate = 2,
    BLTimerActQuery = 3,
    BLTimerActEnableType = 4,
    BLTimerActQueryLimit = 5,
    BLTimerActSunrise = 6,
};

@interface GeneralTimerControlView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *timerList;
@property (strong, nonatomic) NSMutableArray *timeArray;
@property (assign, nonatomic) NSInteger nextIndex;
@property (strong, nonatomic) BLDNADevice *device;

@end

@implementation GeneralTimerControlView

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Timer Tasks";
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    self.timeArray = [NSMutableArray array];
    self.nextIndex = -1;
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getTimerList];
}

- (void)buildUI {
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTimer)],
        [[UIBarButtonItem alloc] initWithTitle:@"Type" style:UIBarButtonItemStylePlain target:self action:@selector(stopTimerType)],
        [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next)],
    ];

    self.timerList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.timerList.delegate = self;
    self.timerList.dataSource = self;
    self.timerList.backgroundColor = [BLTheme backgroundColor];
    self.timerList.separatorColor = [BLTheme separatorColor];
    if (@available(iOS 15.0, *)) {
        self.timerList.sectionHeaderTopPadding = 0;
    }
    [self setExtraCellLineHidden:self.timerList];
    [self.view addSubview:self.timerList];

    [self.timerList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-8);
    }];
}

#pragma mark - Helpers

- (NSString *)targetDid {
    return [Tools timerTargetDidForDevice:self.device sdid:self.sdid];
}

- (NSString *)controlDid {
    return [Tools controlDidForDevice:self.device];
}

- (NSDictionary *)cmdWithParam:(NSString *)params val:(NSInteger)val {
    return @{@"params": @[params ?: @""], @"vals": @[@[@{@"val": @(val), @"idx": @1}]]};
}

- (NSDictionary *)sendTimerAct:(BLTimerAct)act payload:(NSDictionary *)extra {
    NSMutableDictionary *stdData = [@{@"did": [self targetDid], @"act": @(act)} mutableCopy];
    if (extra) {
        [stdData addEntriesFromDictionary:extra];
    }
    NSString *stdDataStr = [Tools jsonStringFromObject:stdData];
    NSString *result = [[BLLet sharedLet].controller dnaControl:[self controlDid]
                                                      subDevDid:nil
                                                        dataStr:stdDataStr
                                                        command:@"dev_subdev_timer"
                                                     scriptPath:nil];
    return [Tools dictionaryFromJSONString:result] ?: @{};
}

- (void)presentFields:(NSArray<NSDictionary *> *)fields title:(NSString *)title handler:(void (^)(NSArray<UITextField *> *fields))handler {
    [Tools presentAlertOn:self title:title fields:fields handler:handler];
}

#pragma mark - Actions

- (void)addTimer {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Selection Mode" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *simpleTypes = @[
        @{@"title": @"Common Timer", @"type": @"comm", @"name": @"普通定时"},
        @{@"title": @"Delay Timer", @"type": @"delay", @"name": @"延时定时"},
        @{@"title": @"Period Timer", @"type": @"period", @"name": @"周期定时"},
    ];
    for (NSDictionary *item in simpleTypes) {
        [sheet addAction:[UIAlertAction actionWithTitle:item[@"title"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self presentSimpleTimerAlertWithType:item[@"type"] name:item[@"name"] title:item[@"title"]];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cycle Timer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentRangeTimerAlertWithType:@"cycle" name:@"循环定时" title:@"Cycle Timer"];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Random Timer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentRangeTimerAlertWithType:@"rand" name:@"随机定时" title:@"Random Timer"];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Sunrise Timer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentSunriseAlert];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)presentSimpleTimerAlertWithType:(NSString *)type name:(NSString *)name title:(NSString *)title {
    [self presentFields:@[
        @{@"text": @"0_1_22_*_*_0,1,3,5_*", @"placeholder": @"time"},
        @{@"text": @"pwr", @"placeholder": @"params"},
        @{@"text": @"1", @"placeholder": @"val"},
    ] title:title handler:^(NSArray<UITextField *> *fields) {
        NSDictionary *cmd = [self cmdWithParam:fields[1].text val:fields[2].text.integerValue];
        [self addTimerWithType:type name:name time:fields[0].text cmd:cmd];
    }];
}

- (void)presentRangeTimerAlertWithType:(NSString *)type name:(NSString *)name title:(NSString *)title {
    [self presentFields:@[
        @{@"text": @"0_1_11_*_*_0,1,3,5_*", @"placeholder": @"stime"},
        @{@"text": @"0_1_22_*_*_0,1,3,5_*", @"placeholder": @"etime"},
        @{@"text": @"15", @"placeholder": @"time1"},
        @{@"text": @"15", @"placeholder": @"time2"},
        @{@"text": @"pwr", @"placeholder": @"params"},
    ] title:title handler:^(NSArray<UITextField *> *fields) {
        [self addRangeTimerWithType:type
                               name:name
                              stime:fields[0].text
                              etime:fields[1].text
                              time1:fields[2].text.integerValue
                              time2:fields[3].text.integerValue
                             params:fields[4].text];
    }];
}

- (void)presentSunriseAlert {
    [self presentFields:@[
        @{@"text": @"2018", @"placeholder": @"year"},
        @{@"text": @"120", @"placeholder": @"longitude"},
        @{@"text": @"30", @"placeholder": @"latitude"},
    ] title:@"Sunrise Timer" handler:^(NSArray<UITextField *> *fields) {
        [self addSunriseTime:fields[0].text.integerValue
                   longitude:fields[1].text.doubleValue
                    latitude:fields[2].text.doubleValue];
    }];
}

- (void)stopTimerType {
    [self presentFields:@[
        @{@"placeholder": @"Commen"},
        @{@"placeholder": @"Delayen"},
        @{@"placeholder": @"Perioden"},
        @{@"placeholder": @"Cycleen"},
        @{@"placeholder": @"Randen"},
    ] title:@"StartOrStopTimerType" handler:^(NSArray<UITextField *> *fields) {
        [self sendTimerAct:BLTimerActEnableType payload:@{
            @"comm_en": @(fields[0].text.integerValue),
            @"delay_en": @(fields[1].text.integerValue),
            @"period_en": @(fields[2].text.integerValue),
            @"cycle_en": @(fields[3].text.integerValue),
            @"rand_en": @(fields[4].text.integerValue),
        }];
    }];
    [self queryTimeType];
}

- (void)next {
    self.nextIndex++;
    [self gettimerDnaControl:5 index:self.nextIndex];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"timeInfoCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        cell.textLabel.textColor = [BLTheme titleColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        cell.detailTextLabel.textColor = [BLTheme subtitleColor];
    }
    NSDictionary *dic = self.timeArray[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", dic[@"id"]];
    NSString *type = dic[@"type"];
    if ([type isEqualToString:@"comm"] || [type isEqualToString:@"delay"] || [type isEqualToString:@"period"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", dic[@"name"], dic[@"time"]];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@", dic[@"name"], dic[@"stime"], dic[@"etime"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.timeArray[indexPath.row];
    NSString *timer = [BLCommonTools serializeMessage:dic];
    [self presentFields:@[@{@"text": timer ?: @"", @"placeholder": @"timer"}]
                  title:@"定时信息修改"
                handler:^(NSArray<UITextField *> *fields) {
        NSDictionary *timeInfo = [BLCommonTools deserializeMessageJSON:fields.firstObject.text];
        if (!timeInfo) { return; }
        [self sendTimerAct:BLTimerActUpdate payload:@{@"timerlist": @[timeInfo]}];
        [BLStatusBar showTipMessageWithStatus:@"Updated"];
        [self getTimerList];
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) { return; }
    NSDictionary *dic = self.timeArray[indexPath.row];
    [self sendTimerAct:BLTimerActDelete payload:@{
        @"timerlist": @[@{@"type": dic[@"type"] ?: @"", @"id": dic[@"id"] ?: @0}]
    }];
    [self.timeArray removeObjectAtIndex:indexPath.row];
    [self.timerList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Timer API

- (void)addTimerWithType:(NSString *)type name:(NSString *)name time:(NSString *)time cmd:(NSDictionary *)cmd {
    NSDictionary *timeInfo = @{
        @"did": [self targetDid],
        @"type": type ?: @"",
        @"en": @1,
        @"name": name ?: @"",
        @"time": time ?: @"",
        @"cmd": cmd ?: @{},
    };
    [self sendTimerAct:BLTimerActAdd payload:@{@"timerlist": @[timeInfo]}];
    [self getTimerList];
}

- (void)addRangeTimerWithType:(NSString *)type
                         name:(NSString *)name
                        stime:(NSString *)stime
                        etime:(NSString *)etime
                        time1:(NSInteger)time1
                        time2:(NSInteger)time2
                       params:(NSString *)params {
    NSDictionary *info = @{
        @"type": type ?: @"",
        @"en": @1,
        @"name": name ?: @"",
        @"stime": stime ?: @"",
        @"etime": etime ?: @"",
        @"time1": @(time1),
        @"time2": @(time2),
        @"cmd1": [self cmdWithParam:params val:1],
        @"cmd2": [self cmdWithParam:params val:0],
    };
    [self sendTimerAct:BLTimerActAdd payload:@{@"timerlist": @[info]}];
    [self getTimerList];
}

- (void)getTimerList {
    [self gettimerDnaControl:10 index:0];
}

- (void)gettimerDnaControl:(NSInteger)count index:(NSInteger)index {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *dic = [self sendTimerAct:BLTimerActQuery payload:@{
            @"type": @"all",
            @"count": @(count),
            @"index": @(index),
        }];
        NSInteger status = [dic[@"status"] integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == 0) {
                self.timeArray = [dic[@"data"][@"timerlist"] mutableCopy] ?: [NSMutableArray array];
                [self.timerList reloadData];
            } else {
                [self showErrorCode:status msg:dic[@"msg"]];
            }
        });
    });
}

- (void)queryTimeType {
    [self sendTimerAct:BLTimerActQueryLimit payload:@{@"type": @""}];
}

- (int)setHour:(int)hour {
    int endHour = hour + 8;
    return endHour > 24 ? endHour - 24 : endHour;
}

- (void)addSunriseTime:(NSInteger)year longitude:(double)longitude latitude:(double)latitude {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"tableList" message:nil preferredStyle:UIAlertControllerStyleAlert];
    for (int i = 1; i <= 12; i++) {
        BLSunriseResult *sunriseResult = [[BLLet sharedLet].controller calulateSunriseTimeWithData:[NSString stringWithFormat:@"%ld-%d-01", (long)year, i]
                                                                                         longitude:longitude
                                                                                          latitude:latitude];
        NSString *sunrise = sunriseResult.sunrise ?: @"00:00:00";
        NSString *sunset = sunriseResult.sunset ?: @"00:00:00";
        int sunriseHour = [self setHour:[[sunrise substringWithRange:NSMakeRange(0, 2)] intValue]];
        int sunsetHour = [self setHour:[[sunset substringWithRange:NSMakeRange(0, 2)] intValue]];
        NSString *tableListString = [@[
            @(i), @1,
            @(sunriseHour), @([[sunrise substringWithRange:NSMakeRange(3, 2)] intValue]), @([[sunrise substringWithRange:NSMakeRange(6, 2)] intValue]),
            @(sunsetHour), @([[sunset substringWithRange:NSMakeRange(3, 2)] intValue]), @([[sunset substringWithRange:NSMakeRange(6, 2)] intValue]),
        ] componentsJoinedByString:@","];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = tableListString;
            textField.placeholder = @"mon,day,sunrise...,sunset...";
        }];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *tableList = [NSMutableArray array];
        for (UITextField *field in alert.textFields) {
            for (NSString *part in [field.text componentsSeparatedByString:@","]) {
                [tableList addObject:@([part intValue])];
            }
        }
        [self sendTimerAct:BLTimerActSunrise payload:@{
            @"year": @(year),
            @"longitude": [NSString stringWithFormat:@"%f", longitude],
            @"latitude": [NSString stringWithFormat:@"%f", latitude],
            @"fmt": @0,
            @"table": tableList,
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
