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
#import "BLStatusBar.h"

@interface A1ViewController (){
    BLeAirNetWorkDataParser *_a1DataParser;
    NSTimer *timer;
}

@property (strong, nonatomic) BLDNADevice *device;

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightLabel;
@property (weak, nonatomic) IBOutlet UILabel *airLabel;
@property (weak, nonatomic) IBOutlet UILabel *noisyLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation A1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.device = [BLDeviceService sharedDeviceService].selectDevice;
    
    _a1DataParser = [BLeAirNetWorkDataParser sharedInstace];
    //获取A1的数据
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self getA1RefreshInfo];
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [timer invalidate];
}

- (void)dealloc {
    timer = nil;
}

- (void)getA1RefreshInfo {
    NSData *data = [_a1DataParser a1RefreshByts];
    BLPassthroughResult *passThroughResult = [[BLLet sharedLet].controller dnaPassthrough:[_device getDid] passthroughData:data];
    BLeAirStatusInfo *a1StatusInfo = [_a1DataParser parseA1RefreshResult:passThroughResult.data];
    
    NSString *temperature = [NSString stringWithFormat:@"温度：%ld.%ld℃",(long)a1StatusInfo.temperature.integer , a1StatusInfo.temperature.decimal ];
    NSString *humidity = [NSString stringWithFormat:@"湿度：%ld.%ld%%",(long)a1StatusInfo.humidity.integer , a1StatusInfo.humidity.decimal];
    //0:暗 1:昏暗 2:正常  3:亮
    NSString *light = [NSString stringWithFormat:@"光照：%ld",(long)a1StatusInfo.light.integer];
    //0:优 1:良 2:正常  3:差
    NSString *air = [NSString stringWithFormat:@"空气质量：%ld",(long)a1StatusInfo.air.integer];
    //0:寂静 1:正常 2:吵闹
    NSString *noisy = [NSString stringWithFormat:@"噪音：%ld",(long)a1StatusInfo.noisy.integer];
    
    _temperatureLabel.text = temperature;
    _humidityLabel.text = humidity;
    _lightLabel.text = light;
    _airLabel.text = air;
    _noisyLabel.text = noisy;
}

- (IBAction)getIFTTTList:(id)sender {
    [self getIFTTT];
}

//结合智慧星APP设置联动，再来获取结果作参考
- (void)getIFTTT {
    NSData *data = [_a1DataParser getIFTTT];
    BLPassthroughResult *passThroughResult = [[BLLet sharedLet].controller dnaPassthrough:[_device getDid] passthroughData:data];
    BLeAirIFTTTList *a1IFTTTInfo = [_a1DataParser parseIFTTTList:passThroughResult.data];
    NSArray *list = a1IFTTTInfo.list;
    if (![list isKindOfClass:[NSNull class]] && list != nil && list.count != 0) {
        BLeAirIFTTTInfo *a1Info = list[0];
        
        BLeAirConditionInfo *condition = a1Info.ifttt.condition;
        
        BLeAirTriggerInfo *trigger = condition.trigger;
        
        
        //当下降到昏暗时，路由器开，时间：08：00-09：00，周期：周日周一周二
        // 0: condition up 1: condition down
        static NSString *conditionText;
        if (trigger.trigger == 0) {
            conditionText = @"上升";
        }else if (trigger.trigger == 1){
            conditionText = @"下降";
        }
        // 0: temperature 1: humidity 2: light 3: air quality 4: noisy
        static NSString *triggerValueText;
        if (trigger.type == 0) {
            triggerValueText = [NSString stringWithFormat:@"温度：%ld.%ld℃",(long)trigger.value.integer , trigger.value.decimal];
        }else if (trigger.type == 1){
            triggerValueText = [NSString stringWithFormat:@"湿度：%ld.%ld%%",(long)trigger.value.integer , trigger.value.decimal];
        }else if (trigger.type == 2){
            //0:暗 1:昏暗 2:正常  3:亮
            triggerValueText = [NSString stringWithFormat:@"光照：%ld",(long)trigger.value.integer];
        }else if (trigger.type == 3){
            //0:优 1:良 2:正常  3:差
            triggerValueText = [NSString stringWithFormat:@"空气质量：%ld",(long)trigger.value.integer];
        }else if (trigger.type == 4){
            //0:寂静 1:正常 2:吵闹
            triggerValueText = [NSString stringWithFormat:@"噪音：%ld",(long)trigger.value.integer];
        }
        NSString *time = [self timeAndWeek:a1Info];
        _resultLabel.text = [NSString stringWithFormat:@"当%@到%@时，%@，生效时间：%@", conditionText,triggerValueText,a1Info.ifttt.name,time];
    }
    
}

- (NSString *)timeAndWeek:(BLeAirIFTTTInfo *)info{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeString = [NSString stringWithFormat:@"%02d-%02d-%02d %02d:%02d",info.ifttt.timeA.year,info.ifttt.timeA.month,info.ifttt.timeA.day,info.ifttt.timeA.hour, info.ifttt.timeA.minute];
    NSDate *startDate = [dateFormatter dateFromString:timeString];
    NSDateComponents *oldComps = [calendar components:unitFlags fromDate:startDate];
    NSDateComponents *startComps = [calendar components:unitFlags fromDate:startDate];
    
    timeString = [NSString stringWithFormat:@"%02d-%02d-%02d %02d:%02d",info.ifttt.timeA.year,info.ifttt.timeA.month,info.ifttt.timeA.day,info.ifttt.timeB.hour, info.ifttt.timeB.minute];
    NSDate *endDate = [dateFormatter dateFromString:timeString];
    NSDateComponents *endComps = [calendar components:unitFlags fromDate:endDate];
    
    uint8_t temprepeatWeeks = info.ifttt.timeA.weekday;
    if (((oldComps.weekday < startComps.weekday) && (startComps.weekday - oldComps.weekday == 1))
        ||((oldComps.weekday > startComps.weekday) && ( oldComps.weekday - startComps.weekday > 1)))
    {
        temprepeatWeeks = info.ifttt.timeA.weekday << 1 | (info.ifttt.timeA.weekday >> 6);
    }
    if (((oldComps.weekday > startComps.weekday) && (oldComps.weekday - startComps.weekday == 1))
        ||((oldComps.weekday < startComps.weekday) && ( startComps.weekday - oldComps.weekday  > 1)))
    {
        temprepeatWeeks = info.ifttt.timeA.weekday >> 1 | (0x40 && (info.ifttt.timeA.weekday << 6));
    }
    NSString *time = [NSString stringWithFormat:@"%02ld:%02ld-%02ld:%02ld,周期：%hhu", (long)[startComps hour], (long)[startComps minute], (long)[endComps hour], (long)[endComps minute],temprepeatWeeks];
    return time;
}
@end
