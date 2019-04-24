//
//  EAirNetWorkDataParser.m
//  Let
//
//  Created by junjie.zhu on 16/8/3.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLeAirNetWorkDataParser.h"
#import "BLAppConfig.h"

@implementation BLTaskTimerInfo

@end

@implementation BLeAirStatusValueInfo

@end

@implementation BLeAirStatusInfo

@end

@implementation BLeAirTriggerInfo

@end

@implementation BLeAirConditStatusInfo

@end

@implementation BLeAirConditionInfo

@end

@implementation BLeAirIFTTT

@end

@implementation BLeAirIFTTTInfo

@end

@implementation BLeAirIFTTTList

@end

@implementation BL2DeviceAuthInfo

@end

@implementation BLeAirIFTTTSetInfo

@end

@implementation BLeAirIOTInfo

@end

@implementation BLeAirNetWorkDataParser

static BLeAirNetWorkDataParser *sharedNetWorkDataParser = nil;

#pragma mark - instancetype
+ (instancetype)sharedInstace {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedNetWorkDataParser = [[BLeAirNetWorkDataParser alloc] init];
    });
    
    return sharedNetWorkDataParser;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

#pragma mark - Get code string method
/**
 *  Get a1 refresh code
 *
 *  @return code
 */
- (NSData *)a1RefreshByts {
    bl2_msg_type_t type;
    type.msg_type = EAIR_STATUS_GET;
    NSData *sendData = [NSData dataWithBytes:&type length:sizeof(bl2_msg_type_t)];
    return sendData;
}

/**
 *  Add IFTTT to list code
 *
 *  @param ifttt
 *
 *  @return code
 */
- (NSData *)addIFTTT:(BLeAirIFTTTSetInfo *)ifttt {
    bl2_msg_type_t type;
    eair_ifttt_t task;
    
    type.msg_type = EAIR_IFTTT_ADD;
    memset(&task, 0, sizeof(task));
    NSData *macData = [self macToBytes:ifttt.iot.mac];
    memcpy(task.command.mac, [macData bytes], 6);
    task.command.auth.terminal_id = ifttt.iot.authInfo.terminal_id;
    memcpy(task.command.auth.key, [ifttt.iot.authInfo.key bytes], ([ifttt.iot.authInfo.key length] > 16) ? 16 : ifttt.iot.authInfo.key.length);
    task.command.len = (ifttt.iot.data.length > 1000) ? 1000 : ifttt.iot.data.length;
    memcpy(task.command.data, ifttt.iot.data.bytes, (ifttt.iot.data.length > 1000) ? 1000 : ifttt.iot.data.length);
    memcpy(task.ifttt.name, [ifttt.info.name UTF8String], (strlen([ifttt.info.name UTF8String]) > 54) ? 54 : strlen([ifttt.info.name UTF8String]));
    task.ifttt.enable = 0;
    if (ifttt.info.timeEnable)
        task.ifttt.enable |= 0x80;
    if (ifttt.info.iftttEnable)
        task.ifttt.enable |= 0x01;
    task.ifttt.timeA.year = ifttt.info.timeA.year;
    task.ifttt.timeA.month = ifttt.info.timeA.month;
    task.ifttt.timeA.day = ifttt.info.timeA.day;
    task.ifttt.timeA.weekday = ifttt.info.timeA.weekday;
    task.ifttt.timeA.hour = ifttt.info.timeA.hour;
    task.ifttt.timeA.minute = ifttt.info.timeA.minute;
    task.ifttt.timeA.second = ifttt.info.timeA.second;
    task.ifttt.timeB.year = ifttt.info.timeB.year;
    task.ifttt.timeB.month = ifttt.info.timeB.month;
    task.ifttt.timeB.day = ifttt.info.timeB.day;
    task.ifttt.timeB.weekday = ifttt.info.timeB.weekday;
    task.ifttt.timeB.hour = ifttt.info.timeB.hour;
    task.ifttt.timeB.minute = ifttt.info.timeB.minute;
    task.ifttt.timeB.second = ifttt.info.timeB.second;
    task.ifttt.condition.trigger.sensor = ifttt.info.condition.trigger.type;
    task.ifttt.condition.trigger.trigger = ifttt.info.condition.trigger.trigger;
    task.ifttt.condition.trigger.value.integer = ifttt.info.condition.trigger.value.integer;
    task.ifttt.condition.trigger.value.decimal = ifttt.info.condition.trigger.value.decimal;
    for (int i=0; i<EAIR_TYPE_MAX - 1; i++)
    {
        BLeAirConditStatusInfo *st = [ifttt.info.condition.statusArray objectAtIndex:i];
        task.ifttt.condition.status[i].valid = st.valid;
        task.ifttt.condition.status[i].sensor = st.type;
        task.ifttt.condition.status[i].value.integer = st.value.integer;
        task.ifttt.condition.status[i].value.decimal = st.value.decimal;
    }
    
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    [sendData appendData:[NSData dataWithBytes:&task length:sizeof(task)]];
    
    return sendData;
}

/**
 *  Delete ifttt from list code
 *
 *  @param index - index in ifttt list
 *
 *  @return code
 */
- (NSData *)deleteIFTTT:(NSInteger)index {
    bl2_msg_type_t type;
    UINT32 index_id = (UINT32)index;
    
    type.msg_type = EAIR_IFTTT_DEL;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    [sendData appendData:[NSData dataWithBytes:&index_id length:sizeof(UINT32)]];
    
    return sendData;
}

/**
 *  Get ifttt list code
 *
 *  @return code
 */
- (NSData *)getIFTTT {
    bl2_msg_type_t type;
    
    type.msg_type = EAIR_IFTTT_GET;
    NSData *sendData = [NSData dataWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    return sendData;
}

#pragma mark - Parse method
/**
 *  Parse a1RefreshByts return
 *
 *  @param data
 *
 *  @return a1 status info
 */
- (BLeAirStatusInfo *)parseA1RefreshResult:(NSData *)data {
    eair_status_t *status;
    
    if ([data length] < sizeof(bl2_msg_type_t) + sizeof(eair_status_t)) {
        return nil;
    } else {
        status = (eair_status_t *)([data bytes] + sizeof(bl2_msg_type_t));
        
        BLeAirStatusValueInfo *temp = [[BLeAirStatusValueInfo alloc] init];
        [temp setInteger:status->tempera.integer];
        [temp setDecimal:status->tempera.decimal];
        BLeAirStatusValueInfo *humidity = [[BLeAirStatusValueInfo alloc] init];
        [humidity setInteger:status->humidity.integer];
        [humidity setDecimal:status->humidity.decimal];
        BLeAirStatusValueInfo *light = [[BLeAirStatusValueInfo alloc] init];
        [light setInteger:status->light.integer];
        [light setDecimal:status->light.decimal];
        BLeAirStatusValueInfo *air = [[BLeAirStatusValueInfo alloc] init];
        [air setInteger:status->air_condition.integer];
        [air setDecimal:status->air_condition.decimal];
        BLeAirStatusValueInfo *noisy = [[BLeAirStatusValueInfo alloc] init];
        [noisy setInteger:status->voice.integer];
        [noisy setDecimal:status->voice.decimal];
        
        BLeAirStatusInfo *info = [[BLeAirStatusInfo alloc] init];
        [info setTemperature:temp];
        [info setHumidity:humidity];
        [info setLight:light];
        [info setAir:air];
        [info setNoisy:noisy];
        
        return info;
    }

}

/**
 *  Parse add/del/get ifttt result
 *
 *  @param data
 *
 *  @return ifttt list
 */
- (BLeAirIFTTTList *)parseIFTTTList:(NSData *)data {
    bl2_msg_type_t *callback_type;
    eair_ifttt_list_t *response;
    
    if ([data length] < sizeof(eair_ifttt_list_t) + sizeof(bl2_msg_type_t)) {
        return nil;
    }
    
    callback_type = (bl2_msg_type_t *)[data bytes];
    response = (eair_ifttt_list_t *)([data bytes] + sizeof(bl2_msg_type_t));
    
    BLeAirIFTTTList *list = [[BLeAirIFTTTList alloc] init];
    [list setCount:response->count];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<response->count; i++)
    {
        BLeAirIFTTTInfo *info = [[BLeAirIFTTTInfo alloc] init];
        [info setMac:[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x"\
                      , response->ifttt_info[i].mac[5], response->ifttt_info[i].mac[4]\
                      , response->ifttt_info[i].mac[3], response->ifttt_info[i].mac[2]\
                      , response->ifttt_info[i].mac[1], response->ifttt_info[i].mac[0]]];
        BLeAirIFTTT *taskInfo = [[BLeAirIFTTT alloc] init];
        [taskInfo setName:[NSString stringWithUTF8String:(const char *)response->ifttt_info[i].ifttt.name]];
        [taskInfo setIndex:response->ifttt_info[i].ifttt.index];
        [taskInfo setTimeEnable:((response->ifttt_info[i].ifttt.enable >> 7) & 1)];
        [taskInfo setIftttEnable:((response->ifttt_info[i].ifttt.enable >> 0) & 1)];
        BLTaskTimerInfo *timeA = [[BLTaskTimerInfo alloc] init];
        [timeA setYear:response->ifttt_info[i].ifttt.timeA.year];
        [timeA setMonth:response->ifttt_info[i].ifttt.timeA.month];
        [timeA setDay:response->ifttt_info[i].ifttt.timeA.day];
        [timeA setWeekday:response->ifttt_info[i].ifttt.timeA.weekday];
        [timeA setHour:response->ifttt_info[i].ifttt.timeA.hour];
        [timeA setMinute:response->ifttt_info[i].ifttt.timeA.minute];
        [timeA setSecond:response->ifttt_info[i].ifttt.timeA.second];
        BLTaskTimerInfo *timeB = [[BLTaskTimerInfo alloc] init];
        [timeB setYear:response->ifttt_info[i].ifttt.timeB.year];
        [timeB setMonth:response->ifttt_info[i].ifttt.timeB.month];
        [timeB setDay:response->ifttt_info[i].ifttt.timeB.day];
        [timeB setWeekday:response->ifttt_info[i].ifttt.timeB.weekday];
        [timeB setHour:response->ifttt_info[i].ifttt.timeB.hour];
        [timeB setMinute:response->ifttt_info[i].ifttt.timeB.minute];
        [timeB setSecond:response->ifttt_info[i].ifttt.timeB.second];
        BLeAirConditionInfo *conditionInfo = [[BLeAirConditionInfo alloc] init];
        BLeAirTriggerInfo *triggerInfo = [[BLeAirTriggerInfo alloc] init];
        [triggerInfo setType:response->ifttt_info[i].ifttt.condition.trigger.sensor];
        [triggerInfo setTrigger:response->ifttt_info[i].ifttt.condition.trigger.trigger];
        BLeAirStatusValueInfo *valueInfo = [[BLeAirStatusValueInfo alloc] init];
        [valueInfo setInteger:response->ifttt_info[i].ifttt.condition.trigger.value.integer];
        [valueInfo setDecimal:response->ifttt_info[i].ifttt.condition.trigger.value.decimal];
        [triggerInfo setValue:valueInfo];
        [conditionInfo setTrigger:triggerInfo];
        NSMutableArray *stArray = [[NSMutableArray alloc] init];
        for (int j=0; j<4; j++)
        {
            BLeAirConditStatusInfo *conditStInfo = [[BLeAirConditStatusInfo alloc] init];
            [conditStInfo setType:response->ifttt_info[i].ifttt.condition.status[j].sensor];
            [conditStInfo setValid:response->ifttt_info[i].ifttt.condition.status[j].valid];
            BLeAirStatusValueInfo *stValueInfo = [[BLeAirStatusValueInfo alloc] init];
            [stValueInfo setInteger:response->ifttt_info[i].ifttt.condition.status[j].value.integer];
            [stValueInfo setDecimal:response->ifttt_info[i].ifttt.condition.status[j].value.decimal];
            [conditStInfo setValue:stValueInfo];
            [stArray addObject:conditStInfo];
        }
        [conditionInfo setStatusArray:stArray];
        [taskInfo setTimeA:timeA];
        [taskInfo setTimeB:timeB];
        [taskInfo setCondition:conditionInfo];
        [info setIfttt:taskInfo];
        
        [array addObject:info];
    }
    [list setList:[array copy]];
    return list;
}

#pragma mark - private method
/*mac 字符串转换到二进制*/
- (NSData *)macToBytes:(NSString *)macString
{
    const char *macBytes = [macString UTF8String];
    int macByte[6];
    UINT8 mac[6];
    int i;
    
    sscanf(macBytes, "%02x%02x%02x%02x%02x%02x"\
           , &macByte[5], &macByte[4], &macByte[3]\
           , &macByte[2], &macByte[1], &macByte[0]);
    for (i=0; i<6; i++)
    {
        mac[i] = macByte[i] & 0xff;
    }
    
    return [NSData dataWithBytes:mac length:6];
}

@end
