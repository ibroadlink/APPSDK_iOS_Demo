//
//  A1ViewController.m
//  BLAPPSDKDemo
//
//  Created by 白洪坤 on 2017/8/17.
//  Copyright © 2017年 BroadLink. All rights reserved.
//

#import "A1ViewController.h"
#import <BLLetPlugins/BLLetPlugins.h>
#import "BLDeviceService.h"
#import "BLTheme.h"
#import "Tools.h"
#import <Masonry/Masonry.h>

@interface A1ViewController () {
    BLeAirNetWorkDataParser *_a1DataParser;
    NSTimer *timer;
}

@property (strong, nonatomic) BLDNADevice *device;
@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic, strong) UILabel *humidityLabel;
@property (nonatomic, strong) UILabel *lightLabel;
@property (nonatomic, strong) UILabel *airLabel;
@property (nonatomic, strong) UILabel *noisyLabel;
@property (nonatomic, strong) UITextView *resultTextView;

@end

@implementation A1ViewController

+ (instancetype)viewController {
    return [[self alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"A1 Device Demo";
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    _a1DataParser = [BLeAirNetWorkDataParser sharedInstace];
    [self buildUI];

    timer = [NSTimer scheduledTimerWithTimeInterval:2.0f repeats:YES block:^(NSTimer * _Nonnull t) {
        [self getA1RefreshInfo];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}

- (void)buildUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.alwaysBounceVertical = YES;
    [self.view addSubview:scroll];

    UIView *content = [[UIView alloc] init];
    [scroll addSubview:content];

    UIView *sensorCard = [[UIView alloc] init];
    [BLTheme styleCardView:sensorCard];
    [content addSubview:sensorCard];

    UIStackView *sensorStack = [[UIStackView alloc] init];
    sensorStack.axis = UILayoutConstraintAxisVertical;
    sensorStack.spacing = 10;
    [sensorCard addSubview:sensorStack];

    self.temperatureLabel = [self metricLabel:@"Temperature: --"];
    self.humidityLabel = [self metricLabel:@"Humidity: --"];
    self.lightLabel = [self metricLabel:@"Light: --"];
    self.airLabel = [self metricLabel:@"Air Quality: --"];
    self.noisyLabel = [self metricLabel:@"Noise: --"];
    [sensorStack addArrangedSubview:self.temperatureLabel];
    [sensorStack addArrangedSubview:self.humidityLabel];
    [sensorStack addArrangedSubview:self.lightLabel];
    [sensorStack addArrangedSubview:self.airLabel];
    [sensorStack addArrangedSubview:self.noisyLabel];

    UIButton *iftttButton = [BLTheme makePrimaryButtonWithTitle:@"Get IFTTT List"
                                                         target:self
                                                         action:@selector(getIFTTTList)];
    [content addSubview:iftttButton];

    UILabel *resultTitle = [[UILabel alloc] init];
    resultTitle.text = @"IFTTT Result";
    resultTitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    resultTitle.textColor = [BLTheme subtitleColor];
    [content addSubview:resultTitle];

    self.resultTextView = [[UITextView alloc] init];
    self.resultTextView.editable = NO;
    [BLTheme styleResultTextView:self.resultTextView];
    [content addSubview:self.resultTextView];

    [scroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scroll);
        make.width.equalTo(scroll);
    }];
    [sensorCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(content).offset(16);
        make.left.equalTo(content).offset(16);
        make.right.equalTo(content).offset(-16);
    }];
    [sensorStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sensorCard).insets(UIEdgeInsetsMake(14, 14, 14, 14));
    }];
    [iftttButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sensorCard.mas_bottom).offset(16);
        make.left.right.equalTo(sensorCard);
        make.height.mas_equalTo(48);
    }];
    [resultTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iftttButton.mas_bottom).offset(20);
        make.left.right.equalTo(sensorCard);
    }];
    [self.resultTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(resultTitle.mas_bottom).offset(8);
        make.left.right.equalTo(sensorCard);
        make.height.mas_equalTo(160);
        make.bottom.equalTo(content).offset(-24);
    }];
}

- (UILabel *)metricLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    label.textColor = [BLTheme titleColor];
    label.numberOfLines = 0;
    return label;
}

- (void)getA1RefreshInfo {
    NSData *data = [_a1DataParser a1RefreshByts];
    BLPassthroughResult *passThroughResult = [[BLLet sharedLet].controller dnaPassthrough:[Tools controlDidForDevice:self.device] passthroughData:data];
    BLeAirStatusInfo *a1StatusInfo = [_a1DataParser parseA1RefreshResult:passThroughResult.data];

    self.temperatureLabel.text = [NSString stringWithFormat:@"温度：%ld.%ld℃", (long)a1StatusInfo.temperature.integer, a1StatusInfo.temperature.decimal];
    self.humidityLabel.text = [NSString stringWithFormat:@"湿度：%ld.%ld%%", (long)a1StatusInfo.humidity.integer, a1StatusInfo.humidity.decimal];
    self.lightLabel.text = [NSString stringWithFormat:@"光照：%ld", (long)a1StatusInfo.light.integer];
    self.airLabel.text = [NSString stringWithFormat:@"空气质量：%ld", (long)a1StatusInfo.air.integer];
    self.noisyLabel.text = [NSString stringWithFormat:@"噪音：%ld", (long)a1StatusInfo.noisy.integer];
}

- (void)getIFTTTList {
    [self getIFTTT];
}

- (void)getIFTTT {
    NSData *data = [_a1DataParser getIFTTT];
    BLPassthroughResult *passThroughResult = [[BLLet sharedLet].controller dnaPassthrough:[Tools controlDidForDevice:self.device] passthroughData:data];
    BLeAirIFTTTList *a1IFTTTInfo = [_a1DataParser parseIFTTTList:passThroughResult.data];
    NSArray *list = a1IFTTTInfo.list;
    if (![list isKindOfClass:[NSNull class]] && list != nil && list.count != 0) {
        BLeAirIFTTTInfo *a1Info = list[0];
        BLeAirConditionInfo *condition = a1Info.ifttt.condition;
        BLeAirTriggerInfo *trigger = condition.trigger;

        static NSString *conditionText;
        if (trigger.trigger == 0) {
            conditionText = @"上升";
        } else if (trigger.trigger == 1) {
            conditionText = @"下降";
        }
        static NSString *triggerValueText;
        if (trigger.type == 0) {
            triggerValueText = [NSString stringWithFormat:@"温度：%ld.%ld℃", (long)trigger.value.integer, trigger.value.decimal];
        } else if (trigger.type == 1) {
            triggerValueText = [NSString stringWithFormat:@"湿度：%ld.%ld%%", (long)trigger.value.integer, trigger.value.decimal];
        } else if (trigger.type == 2) {
            triggerValueText = [NSString stringWithFormat:@"光照：%ld", (long)trigger.value.integer];
        } else if (trigger.type == 3) {
            triggerValueText = [NSString stringWithFormat:@"空气质量：%ld", (long)trigger.value.integer];
        } else if (trigger.type == 4) {
            triggerValueText = [NSString stringWithFormat:@"噪音：%ld", (long)trigger.value.integer];
        }
        NSString *time = [self timeAndWeek:a1Info];
        self.resultTextView.text = [NSString stringWithFormat:@"当%@到%@时，%@，生效时间：%@", conditionText, triggerValueText, a1Info.ifttt.name, time];
    }
}

- (NSString *)timeAndWeek:(BLeAirIFTTTInfo *)info {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeString = [NSString stringWithFormat:@"%02d-%02d-%02d %02d:%02d", info.ifttt.timeA.year, info.ifttt.timeA.month, info.ifttt.timeA.day, info.ifttt.timeA.hour, info.ifttt.timeA.minute];
    NSDate *startDate = [dateFormatter dateFromString:timeString];
    NSDateComponents *oldComps = [calendar components:unitFlags fromDate:startDate];
    NSDateComponents *startComps = [calendar components:unitFlags fromDate:startDate];

    timeString = [NSString stringWithFormat:@"%02d-%02d-%02d %02d:%02d", info.ifttt.timeA.year, info.ifttt.timeA.month, info.ifttt.timeA.day, info.ifttt.timeB.hour, info.ifttt.timeB.minute];
    NSDate *endDate = [dateFormatter dateFromString:timeString];
    NSDateComponents *endComps = [calendar components:unitFlags fromDate:endDate];

    uint8_t temprepeatWeeks = info.ifttt.timeA.weekday;
    if (((oldComps.weekday < startComps.weekday) && (startComps.weekday - oldComps.weekday == 1))
        || ((oldComps.weekday > startComps.weekday) && (oldComps.weekday - startComps.weekday > 1))) {
        temprepeatWeeks = info.ifttt.timeA.weekday << 1 | (info.ifttt.timeA.weekday >> 6);
    }
    if (((oldComps.weekday > startComps.weekday) && (oldComps.weekday - startComps.weekday == 1))
        || ((oldComps.weekday < startComps.weekday) && (startComps.weekday - oldComps.weekday > 1))) {
        temprepeatWeeks = info.ifttt.timeA.weekday >> 1 | (0x40 && (info.ifttt.timeA.weekday << 6));
    }
    return [NSString stringWithFormat:@"%02ld:%02ld-%02ld:%02ld,周期：%hhu", (long)[startComps hour], (long)[startComps minute], (long)[endComps hour], (long)[endComps minute], temprepeatWeeks];
}

@end
