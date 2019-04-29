//
//  S1NetWorkDataParser.m
//  Let
//
//  Created by junjie.zhu on 16/8/4.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import "BLS1NetWorkDataParser.h"

enum sensor_s1_command_list_e {
    GET_IFTTT_ID_LIST = 1,
    ADD_NEW_IFTTT = 2,
    DEL_OLD_IFTTT = 3,
    UPD_OLD_IFTTT = 4,
    GET_TASK_STATUS = 5,
    GET_SENSOR_LIST = 6,
    ADD_NEW_SENSOR = 7,
    DEL_OLD_SENSOR = 8,
    SET_SENSOR_FORTIFY = 9,                 // no use
    GET_SENSOR_FORTIFY = 10,                // no use
    SET_SENSOR_DELAY = 11,
    GET_SENSOR_DELAY = 12,
    SET_SENSOR_MASTER = 13,                 // no use
    GET_SENSOR_MASTER = 14,                 // no use
    SET_SENSOR_NAME = 15,
    GET_SYSTEM_ALARM = 16,
    SET_SENSOR_CONFIG = 17,
    GET_SENSOR_CONFIG = 18,
    SET_SENSOR_PROTECT = 19,
    GET_SENSOR_PROTECT = 20,                // no use
    SET_ALARM_NOTICE_ATTR = 21,             // no use
    GET_ALARM_NOTICE_ATTR = 22,             // no use
    SET_SENSOR_PROTECT_LIST = 23,           // no use
    GET_SENSOR_PROTECT_LIST = 24,           // no use
    ELIMINATE_SYSTEM_ALARM = 25,
    SET_SENSOR_USE_INFO = 26,
    GET_SENSOR_USE_INFO = 27,               // no use
}sensor_s1_command_list_e;

#define IFTTT_MAX 16
#define IFTTT_TASK_ID_SIZE 16
#define IFTTT_URL_MAX 64

typedef struct bl2_msg_type_t
{
    u_int32_t msg_type;
}__attribute__((packed)) bl2_msg_type_t;

/* IFTTT task ID info struct (used for APP) */
typedef struct ifttt_id_t {
    uint32_t  index;
    uint8_t  url[IFTTT_URL_MAX];
    uint8_t   md5[IFTTT_TASK_ID_SIZE];
}__attribute__ ((packed))ifttt_id_t;

/* IFTTT tasks id sets info struct (used for APP) */
typedef struct ifttt_id_list_t {
    uint32_t  count;
    ifttt_id_t  taskId[IFTTT_MAX];
}__attribute__ ((packed))ifttt_id_list_t;

/* IFTTT task file status */
/*
 *  IFTTT_DOWNLOAD_SUCCESS    0  //添加或者更新成功
 *  IFTTT_DOWNLOAD_RUN         1  //正在添加或者更新中
 *  IFTTT_DOWNLOAD_FAIL         2  //添加或者更新失败
 */
#define IFTTT_DOWNLOAD_SUCCESS 0
#define IFTTT_DOWNLOAD_RUN 1
#define IFTTT_DOWNLOAD_FAIL 2

#define SENSOR_MAX_COUNT 16
#define SENSOR_NAME_LEN 22
#define SENSOR_AES_LEN 16
#define SENSOR_SUB_NUM 4
#define SENSOR_ATTR_RESERVED     12


/* Sensor attribute info define */
typedef struct sensor_attr_t {
    /*
     * Protect attribute:
     * 00 --- don't protect;
     * 01 --- Indoor protect;
     * 10 --- Outdoor protect;
     * 11 --- Indoor / Outdoor protect;
     * other --- reserve.
     */
    uint8_t protect;
    /*
     * 1: Must alarm, don't rely on protect attribute,
     * 0 -- rely on protect attribute.
     */
    uint8_t alarm;
    uint8_t use;     /* Sensor used to ? the filed only store code */
    uint8_t apply;   /* Sensor apply to ? the filed also only store code */
    uint8_t res[SENSOR_ATTR_RESERVED];
}__attribute__ ((packed))sensor_attr_t;

/* Sensor sub class info define */
typedef struct sensor_sub_t { /* Define sensor sub class attribute */
    uint32_t  offset : 4;
    uint32_t  len    : 4;
    uint32_t  master : 1;            /* Is master sensor ? (1 = yes) */
    uint32_t  alarm  : 1;            /* Alarm attribute set */
    uint32_t  alarm_trend : 1;
    uint32_t  alarm_value : 16;
    uint32_t  delay;                 /* State recovery time, unit: sec */
}__attribute__ ((packed))sensor_sub_t;

typedef struct sensor_info_t {
    uint8_t  index;             /* Assigned by the firmware */
    uint8_t  vendor_id;
    uint8_t  product_id;
    uint8_t  name[SENSOR_NAME_LEN];
    uint32_t device_id;
    uint32_t private_key;
    sensor_attr_t attr;
    sensor_sub_t sub[SENSOR_SUB_NUM];
}__attribute__ ((packed))sensor_info_t;

/* Sensor real-time status */
typedef struct sensor_status_t {
    uint16_t value;
    sensor_info_t info;
}__attribute__ ((packed))sensor_status_t;

/* Sensor list struct (used for APP level) */
typedef struct sensor_list_t {
    uint8_t nr;
    sensor_status_t status[SENSOR_MAX_COUNT];
    uint8_t pad[15]; /* reserve zero */
}__attribute__ ((packed))sensor_list_t;

/* Sensor security struct */
typedef struct sensor_sec_t {
    uint8_t  enable;
    uint8_t  trend;
    uint16_t value;
}__attribute__ ((packed))sensor_sec_t;

/* Sensor fortify attribute struct */
typedef struct sensor_fortify_t {
    uint8_t index;
    sensor_sec_t sec[SENSOR_SUB_NUM]; /* Security options */
}__attribute__ ((packed))sensor_fortify_t;

/* Sensor status recovery time struct */
typedef struct sensor_delay_t {
    uint8_t index;
    uint8_t res[3];
    uint32_t delay[SENSOR_SUB_NUM]; /* Unit: sec */
}__attribute__ ((packed))sensor_delay_t;

/* Sensor master subclass */
typedef struct sensor_master_t {
    uint8_t index;
    /* Master subclass index */
    uint8_t subindex;
}__attribute__ ((packed))sensor_master_t;

/* Sensor name info */
typedef struct sensor_name_t {
    uint8_t index;
    uint8_t name[SENSOR_NAME_LEN];
}__attribute__ ((packed))sensor_name_t;

/* Sensor config (global properties) options */
typedef enum sensor_config_e {
    /*
     * SENSOR_PROTECT_ENABLE filed define:
     * 00 --- don't protect;
     * 01 --- Indoor protect;
     * 10 --- Outdoor protect;
     * 11 --- reserve;
     */
    SENSOR_PROTECT_ENABLE = 0,
    SENSOR_MCAST_ENABLE,
    SENSOR_MCAST_TIME,
    SENSOR_MCAST_REPEAT,
    SENSOR_PROTECT_DELAY_TIME_H, /* Unit: min （布防延迟分钟部分）*/
    SENSOR_PROTECT_DELAY_TIME_L, /* Unit: sec  （布防延迟秒钟部分）*/
    /* 举例：23分18秒，那么TIME_H设为23，TIME_L设为18 */
    SENSOR_ALARM_NOTICE_DISABLE, /* 1： Buzzer and LED disable filed (default: enable = 0) */
    SENSOR_ALARM_NOTICE_PERIOD,  /* Buzzer and LED work period, unit: min */
    SENSOR_DATA_POST_PERIOD,
    SENSOR_BUZZING_ENABLE,
    /* ... The late extension */
    SENSOR_CONFIG_SIZE = 32,
}sensor_config_e;

/* Sensor config struct */
typedef struct sensor_config_t {
    uint8_t status[SENSOR_CONFIG_SIZE];
}__attribute__ ((packed))sensor_config_t;

typedef struct sensor_protect_t {
    uint8_t index;
    uint8_t attr;
}__attribute__ ((packed))sensor_protect_t;

/* Set sensor protect list attribute */
typedef struct sensor_protect_list_t {
    uint8_t type;      /* 0 -- Remove protect,  1 -- Indoor protect, 2 -- Outdoor protect */
    uint8_t delay_min;  /* System protect start delay time (unit: min) */
    uint8_t delay_sec;   /* second part */
    uint8_t count;     /* Sensor count */
    sensor_protect_t point[SENSOR_MAX_COUNT]; /* Protection point */
}__attribute__ ((packed))sensor_protect_list_t;

typedef struct sensor_alarm_status_t {
    uint8_t index;
    uint8_t status; /* 1 -- Alarm 0 -- Normal */
}__attribute__ ((packed))sensor_alarm_status_t;

/* System alarm status */
typedef struct alarm_status_t {
    uint8_t count; /* Current sensor count */
    sensor_alarm_status_t status[SENSOR_MAX_COUNT];
}__attribute__ ((packed))alarm_status_t;

/* The S1 alarm notice attribute struct (used for buzzer and led) */
typedef struct alarm_notice_t {
    uint8_t disable; /* 0 - enable, 1 - disable */
    uint8_t period; /* Unit: min */
}__attribute__ ((packed))alarm_notice_t;

/* Sensor use info define */
typedef struct sensor_use_info_t {
    uint8_t index;
    uint8_t use;     /* Sensor used to ? the filed only store code */
    uint8_t apply;   /* Sensor apply to ? the filed also only store code */
}__attribute__ ((packed))sensor_use_info_t;

#define S1_GET_INFO   @"http://%@-clouddb.ibroadlink.com/sensor/getinfo"
#define S1_GET_HISTORY  @"http://%@-clouddb.ibroadlink.com/sensor/history/query"
#define S1_GET_ALL_HISTORY  @"http://%@-clouddb.ibroadlink.com/sensor/history/allstatus"
#define S1_GET_IFTTLSIT @"http://%@-ifttt.ibroadlink.com/sensor/tasklist/downapp"
#define S1_ADD_IFTTLSIT @"http://%@-ifttt.ibroadlink.com/sensor/tasklist/upload"
#define S1_MOD_IFTTLSIT @"http://%@-ifttt.ibroadlink.com/sensor/tasklist/modify"
#define S1_DOWNLOAD_IFTTLIST @"http://%@-ifttt.ibroadlink.com/sensor/tasklist/download"

@implementation BLS1IFTTTInfo
- (void)dealloc
{
    [self setTaskMD5:nil];
    [self setCloudDic:nil];
    [self setIfImageURLList:nil];
    [self setIfString:nil];
    [self setThenString:nil];
    [self setThenImagePathList:nil];
    [self setTimerString:nil];
    [self setRepeatString:nil];
    [self setKeepString:nil];
    [self setEnableDeviceList:nil];
    [self setEnableSensorList:nil];
}
@end

@implementation BLS1SubSensorInfo

-(void)dealloc
{
    
}

@end

@implementation BLS1SensorInfo
- (void)dealloc
{
    [self setName:nil];
    [self setCouldDic:nil];
    [self setSub:nil];
}

@end

@implementation BLS1CommonSettingInfo
- (void)dealloc
{
    
}
@end

@implementation BLS1Info
- (void)dealloc
{
    [self setSensorList:nil];
    [self setS1IFTTTList:nil];
    [self setCommonSettingInfo:nil];
}
@end

@implementation BLS1NetWorkDataParser

static BLS1NetWorkDataParser *sharedNetWorkDataParser = nil;

uint16_t get_sensor_subdata(uint16_t value, uint8_t offset, uint8_t len)
{
    return (value >> offset) & ((uint16_t)(~0) >> ((sizeof(value) << 3) - len));
}

NSString* getDistrict()
{
    return @"cn";
}

#pragma mark - instancetype
+ (instancetype)sharedInstace {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedNetWorkDataParser = [[BLS1NetWorkDataParser alloc] init];
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
 *  Add new sensor code
 *
 *  @param info
 *
 *  @return code
 */
- (NSData *)s1AddNewSensor:(BLS1SensorInfo*)info {
    if (nil == info.couldDic)
    {
        return nil;
    }
    
    bl2_msg_type_t type;
    type.msg_type = ADD_NEW_SENSOR;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    sensor_info_t sendInfo = {0};
    sendInfo.device_id = info.device_id;
    sendInfo.product_id = info.product_id;
    sendInfo.vendor_id = info.vendor_id;
    NSString *privateKeyString = [info.couldDic objectForKey:@"s1_pwd"];
    sendInfo.private_key = (int)strtoul([privateKeyString cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
    if (0x91 == info.product_id)
    {
        sendInfo.attr.protect = 0;
    }
    else
    {
        sendInfo.attr.protect = 2;
    }
    NSString *tempName = [info.couldDic objectForKey:@"product_name"];
    NSData *dataName = [tempName dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger length  = dataName.length > (SENSOR_NAME_LEN - 1) ? (SENSOR_NAME_LEN - 1) : dataName.length;
    memset(sendInfo.name, 0, SENSOR_NAME_LEN);
    memcpy(sendInfo.name, dataName.bytes, length);
    NSArray *sensorInfos = [info.couldDic objectForKey:@"sensor"];
    if (nil != sensorInfos)
    {
        NSMutableArray *subInfos = [[NSMutableArray alloc] init];
        for (int i = 0; i < sensorInfos.count; i++)
        {
            BLS1SubSensorInfo *subInfo = [[BLS1SubSensorInfo alloc] init];
            NSDictionary *dic = [sensorInfos objectAtIndex:i];
            if ([[dic objectForKey:@"master"] integerValue])
            {
                sendInfo.attr.alarm = info.mustAlarm = [[dic objectForKey:@"protect_set"] unsignedIntValue];
            }
            sendInfo.sub[i].master = subInfo.master = [[dic objectForKey:@"master"] unsignedIntValue];
            sendInfo.sub[i].alarm = subInfo.alarm = [[dic objectForKey:@"s1_alarm"] unsignedIntValue];
            sendInfo.sub[i].alarm_value  = [[dic objectForKey:@"s1_alarm_value"] unsignedIntValue];
            sendInfo.sub[i].alarm_trend  = [[dic objectForKey:@"s1_alarm_trend"] unsignedIntValue];
            sendInfo.sub[i].offset  = [[dic objectForKey:@"s1_offset"] unsignedIntValue];
            sendInfo.sub[i].len  = [[dic objectForKey:@"s1_len"] unsignedIntValue];
            sendInfo.sub[i].delay  = [[dic objectForKey:@"s1_delay"] unsignedIntValue];
            [subInfos addObject:subInfo];
        }
        info.sub = subInfos;
    }
    [sendData appendBytes:&sendInfo length:sizeof(sensor_info_t)];
    
    return sendData;
}
/**
 *  Delete old sensor from list with index code string
 *
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1DeleteOldSensor:(uint8_t)index {
    bl2_msg_type_t type;
    type.msg_type = DEL_OLD_SENSOR;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    [sendData appendBytes:&index length:sizeof(uint8_t)];
    return sendData;
}

/**
 *  Get sensor list code string
 *
 *  @return code
 */
- (NSData *)s1GetSensorList {
    bl2_msg_type_t type;
    type.msg_type = GET_SENSOR_LIST;
    NSData *sendData = [[NSData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    return sendData;
}

/**
 *  Get sensor config code string
 *
 *  @return code
 */
- (NSData *)s1GetSystemConfig {
    bl2_msg_type_t type;
    type.msg_type = SET_SENSOR_CONFIG;
    NSData *sendData = [[NSData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    return sendData;
}

/**
 *  Set sensor config code string
 *
 *  @param info
 *
 *  @return code
 */
- (NSData *)s1SetSystemConfig:(BLS1CommonSettingInfo*)info {
    bl2_msg_type_t type;
    type.msg_type = GET_SENSOR_CONFIG;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    sensor_config_t sendInfo = {0};
    sendInfo.status[SENSOR_PROTECT_ENABLE] = info.securityStatus;
    sendInfo.status[SENSOR_MCAST_ENABLE] = info.mcastEnable;
    sendInfo.status[SENSOR_MCAST_TIME] = info.mcastTime;
    sendInfo.status[SENSOR_MCAST_REPEAT] = info.mcastRepeat;
    sendInfo.status[SENSOR_PROTECT_DELAY_TIME_H] = info.protectDelayTimeMin;
    sendInfo.status[SENSOR_PROTECT_DELAY_TIME_L] = info.protectDelayTimesec;
    sendInfo.status[SENSOR_ALARM_NOTICE_DISABLE] = info.alarmNoticeDisable;
    sendInfo.status[SENSOR_ALARM_NOTICE_PERIOD] = info.alarmNoticePeriod;
    sendInfo.status[SENSOR_DATA_POST_PERIOD] = info.dataPostPeriod;
    sendInfo.status[SENSOR_BUZZING_ENABLE] = info.buzzingEnable;
    
    [sendData appendBytes:&sendInfo length:sizeof(sensor_config_t)];
    return sendData;
}

/**
 *  Add sensor ifttt with md5 string
 *
 *  @param MD5
 *
 *  @return code
 */
- (NSData *)s1AddIfttt:(NSString *)MD5 {
    bl2_msg_type_t type;
    type.msg_type = ADD_NEW_IFTTT;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    uint8_t url[IFTTT_URL_MAX] = {0};
    NSString *urlString = [NSString stringWithFormat:S1_DOWNLOAD_IFTTLIST,getDistrict()];
    NSData *urlData = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    uint32_t length = urlData.length > (IFTTT_URL_MAX - 1) ? (IFTTT_URL_MAX - 1) : (unsigned int)urlData.length;
    memcpy(url, urlData.bytes, length);
    [sendData appendBytes:url length:IFTTT_URL_MAX];
    
    NSData *md5Data = [BLCommonTools hexString2Bytes:MD5];
    uint8_t md5ID[IFTTT_TASK_ID_SIZE] = {0};
    length = MD5.length > IFTTT_TASK_ID_SIZE ? IFTTT_TASK_ID_SIZE : (unsigned int)MD5.length;
    memcpy(md5ID, md5Data.bytes, length);
    [sendData appendBytes:md5ID length:IFTTT_TASK_ID_SIZE];
    return sendData;
}

/**
 *  Update sensor index of ifttt list with MD5 string
 *  No Parser
 *
 *  @param MD5
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1UpdateIfttt:(NSString *)MD5 index:(uint32_t)index {
    bl2_msg_type_t type;
    type.msg_type = UPD_OLD_IFTTT;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    NSString *urlString = [NSString stringWithFormat:S1_DOWNLOAD_IFTTLIST,getDistrict()];
    NSData *urlData = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    uint32_t length = urlData.length > (IFTTT_URL_MAX - 1) ? (IFTTT_URL_MAX - 1) : (unsigned int)urlData.length;
    
    ifttt_id_t setInfo = {0};
    setInfo.index = index;
    memcpy(setInfo.url, urlData.bytes, length);
    
    NSData *md5Data = [BLCommonTools hexString2Bytes:MD5];
    length = MD5.length > IFTTT_TASK_ID_SIZE ? IFTTT_TASK_ID_SIZE : (unsigned int)MD5.length;
    memcpy(setInfo.md5, md5Data.bytes, length);
    [sendData appendBytes:&setInfo length:sizeof(ifttt_id_t)];
    return sendData;
}

/**
 *  Get s1 ifttt list conde string
 *
 *  @return code
 */
- (NSData *)s1GetIfttt {
    bl2_msg_type_t type;
    type.msg_type = GET_IFTTT_ID_LIST;
    NSData *sendData = [[NSData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    return sendData;
}

/**
 *  Delete s1 ifttt list with index code string
 *
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1DeleteIfttt:(uint32_t)index {
    bl2_msg_type_t type;
    type.msg_type = DEL_OLD_IFTTT;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    [sendData appendBytes:&index length:sizeof(uint32_t)];
    return sendData;
}

/**
 *  Get s1 index of ifttt list status code string
 *
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1QueryAddIftttStatus:(uint32_t)index {
    bl2_msg_type_t type;
    type.msg_type = GET_TASK_STATUS;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    [sendData appendBytes:&index length:sizeof(uint32_t)];
    return sendData;
}

/**
 *  Edit sensor name code string
 *  NO Parser
 *
 *  @param name
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1EditSensorName:(NSString *)name index:(uint8_t)index {
    bl2_msg_type_t type;
    type.msg_type = SET_SENSOR_NAME;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    sensor_name_t sendInfo = {0};
    sendInfo.index = index;
    NSData *tempData = [name dataUsingEncoding:NSUTF8StringEncoding];
    memset(sendInfo.name, 0, SENSOR_NAME_LEN);
    if (tempData.length >= SENSOR_NAME_LEN)
    {
        memcpy(sendInfo.name,[name dataUsingEncoding:NSUTF8StringEncoding].bytes, SENSOR_NAME_LEN - 1);
    }
    else
    {
        memcpy(sendInfo.name,[name dataUsingEncoding:NSUTF8StringEncoding].bytes, tempData.length);
    }
    [sendData appendBytes:&sendInfo length:sizeof(sensor_name_t)];
    return sendData;
}

/**
 *  Set sensor protect type code string
 *  NO Parser
 *
 *  @param protect
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1SetSensorProtect:(uint8_t)protect index:(uint8_t)index {
    bl2_msg_type_t type;
    type.msg_type = SET_SENSOR_PROTECT;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    sensor_protect_t sendInfo = {0};
    sendInfo.index = index;
    sendInfo.attr = protect;
    [sendData appendBytes:&sendInfo length:sizeof(sensor_protect_t)];
    return sendData;
}

/**
 *  Get sensor alarm state info code string
 *
 *  @return code
 */
- (NSData *)s1GetSensorAlarmState {
    bl2_msg_type_t type;
    type.msg_type = GET_SYSTEM_ALARM;
    NSData *sendData = [[NSData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    return sendData;
}

/**
 *  Eliminate system alarm code string
 *  NO Parser
 *
 *  @return code
 */
- (NSData *)s1EliminateSystemAlarm {
    bl2_msg_type_t type;
    type.msg_type = ELIMINATE_SYSTEM_ALARM;
    NSData *sendData = [[NSData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    return sendData;
}

/**
 *  Set sensor use info code string
 *  NO Parser
 *
 *  @param index
 *  @param use   Sensor used to ? the filed only store code
 *  @param apply Sensor apply to ? the filed also only store code
 *
 *  @return code
 */
- (NSData *)s1SetSensorUseInfo:(uint8_t) index use:(uint8_t)use apply:(uint8_t)apply {
    bl2_msg_type_t type;
    type.msg_type = SET_SENSOR_USE_INFO;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    sensor_use_info_t sendInfo = {0};
    sendInfo.index = index;
    sendInfo.use = use;
    sendInfo.apply = apply;
    [sendData appendBytes:&sendInfo length:sizeof(sensor_use_info_t)];
    return sendData;
}

/**
 *  Set sensor delay code string
 *  NO Parser
 *
 *  @param delay
 *  @param sensorInfo
 *
 *  @return code
 */
- (NSData *)s1SetSensorDelay:(NSUInteger)delay sensorInfo:(BLS1SensorInfo*)sensorInfo {
    bl2_msg_type_t type;
    type.msg_type = SET_SENSOR_DELAY;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    
    sensor_delay_t sendInfo = {0};
    sendInfo.index = sensorInfo.index;
    for (int i = 0; i < SENSOR_SUB_NUM; i++)
    {
        BLS1SubSensorInfo *subInfo = [sensorInfo.sub objectAtIndex:i];
        sendInfo.delay[i] = subInfo.delay;
        if (1 == subInfo.master)
        {
            sendInfo.delay[i] = (unsigned int)delay;
        }
    }
    [sendData appendBytes:&sendInfo length:sizeof(sensor_delay_t)];
    return sendData;
}


/**
 *  Get sensor delay code string
 *
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1QuerySensorDelayInfo:(uint8_t)index {
    bl2_msg_type_t type;
    type.msg_type = GET_SENSOR_DELAY;
    NSMutableData *sendData = [[NSMutableData alloc] initWithBytes:&type length:sizeof(bl2_msg_type_t)];
    [sendData appendBytes:&index length:sizeof(uint8_t)];
    return sendData;
}

#pragma mark - Parse method
/**
 *  Parse get/add/delete sensor list return data
 *
 *  @param data
 *
 *  @return sensor list
 */
- (NSArray *)s1ParseSensorList:(NSData *)data {
    if (data.length < sizeof(sensor_list_t) + sizeof(bl2_msg_type_t))
    {
        return nil;
    }
    sensor_list_t getInfo = {0};
    memcpy(&getInfo, data.bytes + sizeof(bl2_msg_type_t), sizeof(sensor_list_t));
    NSMutableArray *sensorList = [[NSMutableArray alloc] init];
    for (int i = 0; i < getInfo.nr; i++)
    {
        BLS1SensorInfo *sensorInfo = [[BLS1SensorInfo alloc] init];
        sensorInfo.index = getInfo.status[i].info.index;
        sensorInfo.vendor_id = getInfo.status[i].info.vendor_id;
        sensorInfo.product_id = getInfo.status[i].info.product_id;
        sensorInfo.device_id = getInfo.status[i].info.device_id;
        sensorInfo.protect = (uint8_t)getInfo.status[i].info.attr.protect;
        sensorInfo.mustAlarm = (uint8_t)getInfo.status[i].info.attr.alarm;
        sensorInfo.use = (uint8_t)getInfo.status[i].info.attr.use;
        sensorInfo.apply = (uint8_t)getInfo.status[i].info.attr.apply;
        NSMutableArray *sub = [[NSMutableArray alloc] init];
        for (int j = 0; j < SENSOR_SUB_NUM; j++)
        {
            BLS1SubSensorInfo *subInfo = [[BLS1SubSensorInfo alloc] init];
            subInfo.alarm = getInfo.status[i].info.sub[j].alarm;
            subInfo.value = get_sensor_subdata(getInfo.status[i].value, getInfo.status[i].info.sub[j].offset, getInfo.status[i].info.sub[j].len);
            subInfo.master = getInfo.status[i].info.sub[j].master;
            subInfo.delay = getInfo.status[i].info.sub[j].delay;
            [sub addObject:subInfo];
        }
        sensorInfo.sub = sub;
        NSInteger length = strlen((char*)getInfo.status[i].info.name) >= SENSOR_NAME_LEN ? SENSOR_NAME_LEN :strlen((char*)getInfo.status[i].info.name);
        sensorInfo.name = [[NSString alloc] initWithBytes:getInfo.status[i].info.name length:length encoding:NSUTF8StringEncoding];
        if (nil == sensorInfo.name)
        {
            sensorInfo.name = @"";
        }
        [sensorList addObject:sensorInfo];
    }
    return sensorList;
}

/**
 *  Parse s1GetSystemConfig return data
 *
 *  @param data
 *
 *  @return config info
 */
- (BLS1CommonSettingInfo *)s1ParseSystemConfig:(NSData *)data {
    if (data.length < sizeof(sensor_config_t) + sizeof(bl2_msg_type_t))
    {
        return nil;
    }
    sensor_config_t getInfo = {0};
    memcpy(&getInfo, data.bytes + sizeof(bl2_msg_type_t), sizeof(sensor_config_t));
    BLS1CommonSettingInfo *info = [[BLS1CommonSettingInfo alloc] init];
    info.securityStatus = getInfo.status[SENSOR_PROTECT_ENABLE];
    info.mcastEnable = getInfo.status[SENSOR_MCAST_ENABLE];
    info.mcastTime = getInfo.status[SENSOR_MCAST_TIME];
    info.mcastRepeat = getInfo.status[SENSOR_MCAST_REPEAT];
    info.protectDelayTimeMin = getInfo.status[SENSOR_PROTECT_DELAY_TIME_H];
    info.protectDelayTimesec = getInfo.status[SENSOR_PROTECT_DELAY_TIME_L];
    info.alarmNoticeDisable = getInfo.status[SENSOR_ALARM_NOTICE_DISABLE];
    info.alarmNoticePeriod = getInfo.status[SENSOR_ALARM_NOTICE_PERIOD];
    info.dataPostPeriod = getInfo.status[SENSOR_DATA_POST_PERIOD];
    info.buzzingEnable = getInfo.status[SENSOR_BUZZING_ENABLE];
    return info;
}

/**
 *  Parse s1AddIfttt:MD5 return data
 *
 *  @param data
 *
 *  @return index
 */
- (uint32_t)s1ParseAddIftttResult:(NSData *)data {
    if (data.length < sizeof(bl2_msg_type_t) + sizeof(uint32_t))
    {
        return NO;
    }
    bl2_msg_type_t msg_type = {0};
    int index = 0;
    memcpy(&msg_type, data.bytes, sizeof(bl2_msg_type_t));
    memcpy(&index, data.bytes + sizeof(bl2_msg_type_t), sizeof(uint32_t));
   
    return index;
}

/**
 *  Parse get/delete ifttt list return data
 *
 *  @param data
 *
 *  @return ifttt list
 */
- (NSArray *)s1ParseIftttList:(NSData *)data {
    if (data.length < sizeof(ifttt_id_list_t) + sizeof(bl2_msg_type_t))
    {
        return nil;
    }
    bl2_msg_type_t msg_type = {0};
    memcpy(&msg_type, data.bytes, sizeof(bl2_msg_type_t));
    ifttt_id_list_t getInfo = {0};
    memcpy(&getInfo, data.bytes + sizeof(bl2_msg_type_t), sizeof(ifttt_id_list_t));
    NSMutableArray *IFTTTList = [[NSMutableArray alloc] init];
    for (int i = 0; i < getInfo.count; i++)
    {
        BLS1IFTTTInfo *info = [[BLS1IFTTTInfo alloc] init];
        info.index = getInfo.taskId[i].index;
        info.taskMD5 = [BLCommonTools data2hexString:[NSData dataWithBytes:getInfo.taskId[i].md5 length:IFTTT_TASK_ID_SIZE]];
        [IFTTTList addObject:info];
    }
    return IFTTTList;
}

/**
 *  Parse s1QueryAddIftttStatus:index return data
 *
 *  @param data
 *
 *  @return status
 */
- (int32_t)s1ParseAddIftttStatus:(NSData *)data {
    if (data.length < sizeof(bl2_msg_type_t) + sizeof(uint32_t))
    {
        return -1;
    }
    
    bl2_msg_type_t msg_type = {0};
    memcpy(&msg_type, data.bytes, sizeof(bl2_msg_type_t));
    int32_t status = 0;
    memcpy(&status, data.bytes + sizeof(bl2_msg_type_t), sizeof(int32_t));
    return status;
}

/**
 *  Parse s1GetSensorAlarmState return data
 *
 *  @param data
 *
 *  @return info
 */
- (BLS1Info *)s1ParseGetSensorAlarmState:(NSData *)data {
    if (data.length < sizeof(alarm_status_t) + sizeof(bl2_msg_type_t))
    {
        return nil;
    }
    alarm_status_t getInfo = {0};
    BLS1Info *s1Info = [[BLS1Info alloc] init];
    
    memcpy(&getInfo, data.bytes + sizeof(bl2_msg_type_t), sizeof(alarm_status_t));
    int count = getInfo.count < s1Info.sensorList.count ? getInfo.count : (int)s1Info.sensorList.count;
    int status = 0;
    for (int i = 0; i < count; i++)
    {
        BLS1SensorInfo *info = [s1Info.sensorList objectAtIndex:i];
        info.alarmStatus = getInfo.status[i].status;
        if (1 == info.alarmStatus)
        {
            status = 1;
        }
    }
    s1Info.alarmStatus = status;
    
    return s1Info;
}

/**
 *  Parse s1QuerySensorDelayInfo return data
 *
 *  @param data
 *
 *  @return info
 */
- (BLS1SensorInfo *)s1SensorDelayParse:(NSData *)data {
    if (data.length < sizeof(sensor_delay_t) + sizeof(bl2_msg_type_t))
    {
        return nil;
    }
    BLS1SensorInfo *sensorInfo = [[BLS1SensorInfo alloc] init];
    sensor_delay_t getInfo = {0};
    memcpy(&getInfo, data.bytes + sizeof(bl2_msg_type_t), sizeof(sensor_delay_t));
    for (int i = 0; i < SENSOR_SUB_NUM; i++)
    {
        BLS1SubSensorInfo *subInfo = [sensorInfo.sub objectAtIndex:i];
        subInfo.delay =  getInfo.delay[i];
    }
    
    return sensorInfo;
}

@end
