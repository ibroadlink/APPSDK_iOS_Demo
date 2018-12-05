//
//  S1NetWorkDataParser.h
//  Let
//
//  Created by junjie.zhu on 16/8/4.
//  Copyright © 2016年 BroadLink Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BLLetBase/BLLetBase.h>

#define MAX_EN_NAME_LEN                         30
#define MAX_S1_NAME_LEN                         21
#define MAX_OTHER_NAME_LEN                      13
#define MAX_S1_BARCODE_LEN                      16

@interface BLS1IFTTTInfo: NSObject
@property (nonatomic, assign) uint32_t index;
@property (nonatomic, strong) NSString *taskMD5;
@property (nonatomic, strong) NSDictionary *cloudDic;
@property (nonatomic, assign) float contentHeight;
@property (nonatomic, strong) NSString *ifString;
@property (nonatomic, strong) NSArray *ifImageURLList;
@property (nonatomic, strong) NSArray *enableSensorList;
@property (nonatomic, strong) NSString *thenString;
@property (nonatomic, strong) NSArray *thenImagePathList;
@property (nonatomic, strong) NSArray *enableDeviceList;
@property (nonatomic, strong) NSArray *enableSceneList;
@property (nonatomic, strong) NSString *timerString;
@property (nonatomic, assign) BOOL nextDay;
@property (nonatomic, strong) NSString *repeatString;
@property (nonatomic, strong) NSString *keepString;
@end


@interface BLS1SubSensorInfo : NSObject
@property (nonatomic, assign) uint8_t master;
@property (nonatomic, assign) uint8_t alarm;
@property (nonatomic, assign) uint16_t value;
@property (nonatomic, assign) uint32_t delay;
@end

@interface BLS1SensorInfo: NSObject
@property (nonatomic, assign) uint8_t alarmStatus;
@property (nonatomic, assign) uint8_t index;
@property (nonatomic, assign) uint8_t vendor_id;
@property (nonatomic, assign) uint8_t product_id;
@property (nonatomic, assign) uint32_t device_id;
@property (nonatomic, assign) uint8_t protect;
@property (nonatomic, assign) uint8_t mustAlarm;
@property (nonatomic, assign) uint8_t use;
@property (nonatomic, assign) uint8_t apply;
@property (nonatomic, strong) NSArray *sub;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDictionary *couldDic;
@end

@interface BLS1CommonSettingInfo: NSObject
//0 表示撤防 1表示在家布防 2表示外出布防
@property (nonatomic, assign) uint8_t securityStatus;
@property (nonatomic, assign) uint8_t mcastEnable;
@property (nonatomic, assign) uint8_t mcastTime;
@property (nonatomic, assign) uint8_t mcastRepeat;
@property (nonatomic, assign) uint8_t protectDelayTimeMin;
@property (nonatomic, assign) uint8_t protectDelayTimesec;
@property (nonatomic, assign) uint8_t alarmNoticeDisable;
@property (nonatomic, assign) uint8_t alarmNoticePeriod;
@property (nonatomic, assign) uint8_t dataPostPeriod;
@property (nonatomic, assign) uint8_t buzzingEnable;
@end

@interface BLS1Info: NSObject
//1表示报警 0表示正常
@property (nonatomic, assign) uint8_t alarmStatus;
@property (nonatomic, strong) BLS1CommonSettingInfo *commonSettingInfo;
//S1任务列表
@property (nonatomic, strong) NSArray *s1IFTTTList;
@property (nonatomic, strong) NSArray *sensorList;
@end

@interface BLS1NetWorkDataParser : NSObject

+ (instancetype)sharedInstace;

/**
 *  Add new sensor code
 *
 *  @param info
 *
 *  @return code
 */
- (NSData *)s1AddNewSensor:(BLS1SensorInfo*)info;

/**
 *  Delete old sensor from list with index code
 *
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1DeleteOldSensor:(uint8_t)index;

/**
 *  Get sensor list code
 *
 *  @return code
 */
- (NSData *)s1GetSensorList;

/**
 *  Get sensor config code
 *
 *  @return code
 */
- (NSData *)s1GetSystemConfig;

/**
 *  Set sensor config code
 *
 *  @param info
 *
 *  @return code
 */
- (NSData *)s1SetSystemConfig:(BLS1CommonSettingInfo*)info;

/**
 *  Add sensor ifttt with md5
 *
 *  @param MD5
 *
 *  @return code
 */
- (NSData *)s1AddIfttt:(NSString *)MD5;

/**
 *  Update sensor index of ifttt list with MD5 string
 *  No Parser
 *
 *  @param MD5
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1UpdateIfttt:(NSString *)MD5 index:(uint32_t)index;

/**
 *  Get s1 ifttt list conde
 *
 *  @return code
 */
- (NSData *)s1GetIfttt;

/**
 *  Delete s1 ifttt list with index code
 *
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1DeleteIfttt:(uint32_t)index;

/**
 *  Get s1 index of ifttt list status code
 *
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1QueryAddIftttStatus:(uint32_t)index;

/**
 *  Edit sensor name code
 *  NO Parser
 *
 *  @param name
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1EditSensorName:(NSString *)name index:(uint8_t)index;

/**
 *  Set sensor protect type code
 *  NO Parser
 *
 *  @param protect
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1SetSensorProtect:(uint8_t)protect index:(uint8_t)index;

/**
 *  Get sensor alarm state info code
 *
 *  @return code
 */
- (NSData *)s1GetSensorAlarmState;

/**
 *  Eliminate system alarm code
 *  NO Parser
 *
 *  @return code
 */
- (NSData *)s1EliminateSystemAlarm;

/**
 *  Set sensor use info code
 *  NO Parser
 *
 *  @param index
 *  @param use   Sensor used to ? the filed only store code
 *  @param apply Sensor apply to ? the filed also only store code
 *
 *  @return code
 */
- (NSData *)s1SetSensorUseInfo:(uint8_t) index use:(uint8_t)use apply:(uint8_t)apply;

/**
 *  Set sensor delay code
 *  NO Parser
 *
 *  @param delay
 *  @param sensorInfo
 *
 *  @return code
 */
- (NSData *)s1SetSensorDelay:(NSUInteger)delay sensorInfo:(BLS1SensorInfo*)sensorInfo;

/**
 *  Get sensor delay code
 *
 *  @param index
 *
 *  @return code
 */
- (NSData *)s1QuerySensorDelayInfo:(uint8_t)index;

/**
 *  Parse get/add/delete sensor list return data
 *
 *  @param data
 *
 *  @return sensor list
 */
- (NSArray *)s1ParseSensorList:(NSData *)data;

/**
 *  Parse s1GetSystemConfig return data
 *
 *  @param data
 *
 *  @return config info
 */
- (BLS1CommonSettingInfo *)s1ParseSystemConfig:(NSData *)data;

/**
 *  Parse s1AddIfttt:MD5 return data
 *
 *  @param data
 *
 *  @return index
 */
- (uint32_t)s1ParseAddIftttResult:(NSData *)data;

/**
 *  Parse get/delete ifttt list return data
 *
 *  @param data
 *
 *  @return ifttt list
 */
- (NSArray *)s1ParseIftttList:(NSData *)data;

/**
 *  Parse s1QueryAddIftttStatus:index return data
 *
 *  @param data
 *
 *  @return status
 */
- (int32_t)s1ParseAddIftttStatus:(NSData *)data;

/**
 *  Parse s1GetSensorAlarmState return data
 *
 *  @param data
 *
 *  @return info
 */
- (BLS1Info *)s1ParseGetSensorAlarmState:(NSData *)data;

/**
 *  Parse s1QuerySensorDelayInfo return data
 *
 *  @param data
 *
 *  @return info
 */
- (BLS1SensorInfo *)s1SensorDelayParse:(NSData *)data;


@end
